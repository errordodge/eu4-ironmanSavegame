# input parameter for the name of the source file

param (
	[Parameter()]
	[String]
	$fileName = "achievments"
)

$ErrorActionPreference = 'Stop'

$srcFile = "${Home}\Documents\Paradox Interactive\Europa Universalis IV\save games\" + $fileName + ".eu4"
$destFile = ("${Home}\Documents\Paradox Interactive\Europa Universalis IV\save games\ironman\" + $fileName + ' ')

# function to get time stamp
function getTimeStamp {
	$date = Get-Date
	$time = $date.ToString("dd-MM-yyyy HH-mm")
	return $time
}

# function to copy source file to destination directory and rename it with added time stamp
function copyFile {
	param (
		[String]$srcFile,
		[String]$destFile
	)
	Copy-Item $srcFile -Destination ($destFile + (getTimeStamp) + '.eu4')  -Force -ErrorAction Stop
}

# function to check if source file has been modified last 10 minutes
function checkFile {
	param (
		[String]$srcFile
	)
	$file = Get-Item $srcFile
	$lastModified = $file.LastWriteTime
	$now = Get-Date
	$diff = $now - $lastModified
	if ($diff.TotalSeconds -gt 600) {
		return $false
	} else {
		return $true
	}
}

# check if source file exists
if (!(Test-Path $srcFile)) {
	Write-Error "Source file does not exist"
	exit 1
}
# check if destination file exists and if source file has been modified last 10 minutes
if (Test-Path ($destFile + (getTimeStamp))) {
	if (checkFile $srcFile) {
		Write-Host "Destination file exists but source file is newer, copying source file"
		copyFile $srcFile $destFile
	}
} else {
	Write-Host "Destination file doesn´t exist, copying source file to destination file"
	copyFile $srcFile $destFile
}

# check if source file has changed since last copy every 10 minutes
# if source file has changed, copy sorce file to destination file
# if source file hasn´t changed, do nothing

while ($true) {
	if (Test-Path $srcFile) {
			# check if source file has been modified last 10 seconds
			try {
				if (checkFile $srcFile) {
					Write-Host "Source file has changed, copying source file to destination file: $($destFile + (getTimeStamp))"
					copyFile $srcFile $destFile
				}
			} catch {
				Write-Error "Error checking source file"
				exit 1
			}
	}
	else {
		Write-Error "Source file doesn´t exist"
		exit 1
	}
	
	Start-Sleep -Seconds 600
}
