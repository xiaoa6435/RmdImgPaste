is_macos <- function () unname(Sys.info()["sysname"] == "Darwin")
is_windows <- function () .Platform$OS.type == "windows"
is_linux <- function () unname(Sys.info()["sysname"] == "Linux")

normalize_path <- function (path, winslash = "/", must_work = FALSE) {
  res <- normalizePath(path, winslash = winslash, mustWork = must_work)
  if (is_windows())
    res[is.na(path)] <- NA
  res
}

