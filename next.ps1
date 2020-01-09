# function fetch from https://github.com/Sauler/PowershellUtils
# found on this blog : https://www.reddit.com/r/PowerShell/comments/5fglby/powershell_to_set_windows_10_lockscreen/
function Set-LockscreenWallpaper($path) {
    Add-Type -Path (Join-Path $PSScriptRoot "PoshWinRT.dll")
	[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
	$asyncOp = [Windows.Storage.StorageFile]::GetFileFromPathAsync($path)
	$wrapper = new-object 'PoshWinRT.AsyncOperationWrapper[Windows.Storage.StorageFile]' -Arg $asyncOp
	$file = $wrapper.AwaitResult()
	[Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
	$asyncAction = [Windows.System.UserProfile.LockScreen]::SetImageFileAsync($file)
	$wrapper = new-object 'PoshWinRT.AsyncActionWrapper' -Arg $asyncAction
	$wrapper.AwaitResult()
}

# read pictures
$srcFolder = Get-Content (Join-Path $PSScriptRoot "slideshow.config")
$pictures = Get-ChildItem $srcFolder

# read current state
$dataRoot = Join-Path $PSScriptRoot "data"
if (!(Test-Path $dataRoot)) {
	New-Item -Path $PSScriptRoot -Name "data" -ItemType "directory" | Out-Null
}

$currentIndexFile = Join-Path $dataRoot "current.txt"
$currentIndex = 0
if (Test-Path $currentIndexFile) {
	$currentIndex = Get-Content $currentIndexFile
}

# select next picture
$newIndex = 1 + $currentIndex
if ($newIndex -ge $pictures.Length) {
	$newIndex = 0
}
$sourceFile = $pictures[$newIndex]
Copy-Item $sourceFile.FullName -Destination (Join-Path $dataRoot "current.jpg")

# apply change
Set-LockscreenWallpaper $sourceFile.FullName
$newIndex | out-file $currentIndexFile