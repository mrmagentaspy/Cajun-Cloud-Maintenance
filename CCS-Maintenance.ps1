<#
Does the routine Cajun Cloud Services maintenance tasks

Run this with Powershell as Administrator
#>


# Flush DNS cache 
ipconfig /flushdns

# Run Malwarebytes threat scan -- this may pop up the threat scan progress on the endpoint's GUI
if (Test-Path -Path "C:\Program Files\Malwarebytes Endpoint Agent\UserAgent\") {
		
Set-Location "$env:ProgramFiles\Malwarebytes Endpoint Agent\UserAgent\"
.\EACMD.exe -threatscan
} else {
	"Directory $env:ProgramFiles\Malwarebytes Endpoint Agent\UserAgent\ not found!!!"
}

<#
Goes down every drive in the machine and runs "Optimize-Volume" on them.
Per MS's documentation:

If no parameter is specified, then the default operation will be performed per the drive type as follows:
	HDD, Fixed VHD, Storage Space. -Analyze -Defrag.
	Tiered Storage Space. -TierOptimize.
	SSD with TRIM support. -Retrim.
	Storage Space (Thinly provisioned), SAN Virtual Disk (Thinly provisioned), Dynamic VHD, Differencing VHD. -Analyze -SlabConsolidate -Retrim.
	SSD without TRIM support, Removable FAT, Unknown. No operation.

TLDR: defrags HDDS, trims SSDs and thin client storage.
#>
Get-Volume | 
  Where-Object DriveLetter | 
  Where-Object DriveType -eq Fixed | 
  Optimize-Volume
  
<# Set vars to paths to temp directories that are addressed in "Disk Cleanup #>
$Path1 = "$env:WINDIR\Temp" # Windows temp files
$Path2 = "$env:WINDIR\Prefetch" # Prefetch files
$Path3 = "$env:TEMP" # User temp files
$Path4 = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache" # Internet cache

<# Remove Windows temp files #>
Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

<# Remove prefetch files #> 
Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

<# Remove user's temp files #>
Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

<# Remove temporary Internet files #>
Get-ChildItem $Path4 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Deletes Delivery Optimization cache w/o a prompt
Delete-DeliveryOptimizationCache -Force

<# 
Run with the default settings, no user prompts.
Automatically deletes the files that are left behind after you upgrade Windows.
 #>
cleanmgr.exe /autoclean /verylowdisk

# Clear Recycle Bin
Clear-RecycleBin -force -ErrorAction SilentlyContinue

# Run DISM
DISM /Online /Cleanup-Image /RestoreHealth

<# 
# Kill cleanmgr "done!" window
Get-Process cleanmgr | Stop-Process
# Can bring this back if we want
#>

# Run sfc /scannow
cmd /c "sfc /scannow"