## RmdImgPaste

RStudio Addin: Copy images from clipboard into .Rmd files or a blogdown post.

## Installation
`devtools::install_github('xiaoa6435/RmdImgPaste')`

## Dependencies
- rstudioapi
- for linux user, xlip is needed
- for windows 7, powershell need updated to 5.1 

## Technical walkthrough

### how to read image from clipboard?
in macos, exec script like this:
```
osascript -e '
  set theFile to (open for access POSIX file "test.png" with write permission)
  try
    write (the clipboard as «class PNGf») to theFile
  end try
  close access theFile'
```

in window
```
powershell -sta '
  Add-Type -AssemblyName System.Windows.Forms;,
  if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {
    [System.Drawing.Bitmap][System.Windows.Forms.Clipboard]::GetDataObject(
      ).getimage().Save("test.png", [System.Drawing.Imaging.ImageFormat]::Png)
  }'
```

in linux (not test):
```
xclip -selection clipboard -t image/png -o > "test.png"
```

if this Addin not work, you can test if this scipt can can generate test.png file when
you have a image on clipboard

### where is paste image?

for a general Rmd files, all paste image in curr_path/.assets/, named like rmd-img-paste-%Y%m%d%H%M%s.png. If you don't like it, you can specify a subfloder by `options(rmarkdown.paste_image_dir = 'you_floder')`.

for a blogdown post(.Rproj have attr like 'BuildType: Website' and in content/../.., you can override it by `options(rmarkdown.is_blogdown_post = FALSE`), all paste image in static/post/postname_files/, and
insert code like `![](/post/postname_files/rmd-img-paste-%Y%m%d%H%M%s.png)`.

you can specify a baseurl by `options(rmarkdown.blogdown_baseurl = 'you_baseurl')`.

## Usage
Tools -> Modify Keyboard Shortcuts -> RmdImgPaste，Customize a shortcut (for example, cmd + v), then you can just use 'cmd + v' paste image into a blogdown post or a Rmd file

## Acknowledgements
this code is based on https://github.com/Timag/imageclipr and make some changes:

- remove python dependency
- remove shiny, only shortcuts
- add support for blogdown post



