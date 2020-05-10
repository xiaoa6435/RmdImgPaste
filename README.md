## RmdImgPaste

RStudio Addin: Copy images from clipboard into .Rmd files or a blogdown post, this is a usage from Timag
![Usage, image from Timag/imageclipr](https://github.com/Timag/imageclipr/blob/master/usage.gif)

## Installation
`devtools::install_github('xiaoa6435/RmdImgPaste')`

## Dependencies
no Dependencies except rstudioapi. for Linux user, install xclip first (I don't test on Linux)

## Technical walkthrough

### how to read image from clipboard?
in macos, exec script like this:
```
osascript -e "
  set theFile to (open for access POSIX file 'test.png' with write permission)
  try
    write (the clipboard as «class PNGf») to theFile
  end try
  close access theFile"
```

in window
```
powershell -sta "
  Add-Type -AssemblyName System.Windows.Forms;,
  if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {
    [System.Drawing.Bitmap][System.Windows.Forms.Clipboard]::GetDataObject(
      ).getimage().Save('test.png', [System.Drawing.Imaging.ImageFormat]::Png)
  }
```

in linux (not test):
```
xclip -selection clipboard -t image/png -o > 'test.png'
```

if this Addin not work, you can test if this scipt can can generate test.png file when
you have a image on clipboard

### where is paste image?

for a general Rmd files, all paste image in curr_path/.assets/, named like rmd-img-paste-%Y%m%d%H%M%s.png

for a blogdown post(.Rproj have somethin like BuildType: Website and in content/post), all paste image in static/post/postname_files/, and
insert code like `![](/post/postname_files/rmd-img-paste-%Y%m%d%H%M%s.png)`

## Usage
Tools -> Modify Keyboard Shortcuts -> RmdImgPaste，Customize a shortcut, for example, ctrl + v

## Acknowledgements

this code is based on https://github.com/Timag/imageclipr and make some changes:

- remove python dependency
- remove shiny, only shortcut
- add support for blogdown post

