grab_clipboard <- function(filepath) {
  platform <- Sys.info()[1]
  if (platform == "Darwin") {
    script <- paste0(
      "osascript -e \'
          set theFile to (open for access POSIX file \"",
      filepath, "\" with write permission)
      try
      write (the clipboard as «class PNGf») to theFile
      end try
      close access theFile'"
    )
    system(script)
  } else if (platform == "Windows") {
    script <- paste0(
      "powershell -sta \"\n",
      "Add-Type -AssemblyName System.Windows.Forms;\n",
      "if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {\n",
      "  [System.Drawing.Bitmap][System.Windows.Forms.Clipboard]::GetDataObject(
        ).getimage().Save('",
      paste0(filepath, "', [System.Drawing.Imaging.ImageFormat]::Png) \n"),
      "  }\""
    )
    system(script)
  } else if (grepl("linux-gnu", R.version$os)) {
    # Executing on Linux! -> use xclip
    tryCatch(
      targets <- tolower(
        system("xclip -selection clipboard -t TARGETS -o", intern = T)
      ),
      error = function(e) {
        stop("Please install the required system dependency xclip")
      }
    ) # Validate xclip is installed and get targets from clipboard
    if (any(grepl(".*png$", targets))) {
      system(paste0("xclip -selection clipboard -t image/png -o > ", filepath))
    }
  }

  # in mac os, if no image in clipboard, exec script will create a empty image
  # in window, no image be create
  if (!file.exists(filepath) || file.size(filepath) == 0) {
    stop("Clipboard data is not an image.")
  }
  filepath
}

is_blogdown_post <- function() {
  ## current rmd is a blogdown post?
  ## Criteria:
  ## - is a project and .Rproj have something like BuildType: Website
  ## - filepath like **/post/***

  proj_root <- rstudioapi::getActiveProject()
  if (is.null(proj_root)) {
    return(FALSE)
  }

  proj_settings <- list.files(proj_root, pattern = ".Rproj", full.names = TRUE)
  currpath <- rstudioapi::getSourceEditorContext()$path
  if (any(grep("BuildType: Website", readLines(proj_settings)) > 0) &&
    basename(dirname(currpath)) == "post") {
    return(TRUE)
  }
  FALSE
}

generate_filepath <- function() {
  ## filepath: absolute path,
  ## filepath_insert: path in rmd, like ![](filepath_insert),
  ## for a blogdown post, filepath_insert is different from filepath
  ## https://lcolladotor.github.io/2018/03/07/blogdown-insert-image-addin/#.XrZ9dxMzbjA

  filename <- format(Sys.time(), "rmd-img-paste-%Y%m%d%H%M%s.png")
  currpath <- rstudioapi::getSourceEditorContext()$path
  if (!nchar(currpath)) stop("Please save the file before pasting an image.")

  if (is_blogdown_post()) {
    proj_root <- rstudioapi::getActiveProject()
    post_files <- paste0(tools::file_path_sans_ext(basename(currpath)), "_files")
    dir <- file.path(proj_root, "static", "post", post_files)
    dir_insert <- strsplit(dir, "static")[[1]][2] # path like /post/...
  } else {
    dir <- file.path(dirname(currpath), ".asserts")
    dir_insert <- ".asserts"
  }

  if (!file.exists(dir)) dir.create(dir)
  list(
    filepath = file.path(dir, filename),
    filepath_insert = file.path(dir_insert, filename)
  )
}

insert_image_code <- function() {
  docId <- rstudioapi::getSourceEditorContext()$id
  if (docId %in% c("#console", "#terminal")) {
    stop("You can`t insert an image in the console nor in the terminal.
         Please select a line in the source editor.")
  }
  res <- generate_filepath()
  grab_clipboard(res$filepath)
  position <- rstudioapi::getSourceEditorContext()$selection[[1]]$range$start

  func <- function(filepath) paste0("![](", filepath, ")")
  rstudioapi::insertText(position, func(res$filepath_insert), id = docId)
}
