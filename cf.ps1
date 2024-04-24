<#PSScriptInfo
.VERSION 1
.GUID 31695060-ef7e-4162-b992-2a2894c0feb4
.AUTHOR Eric Duncan
.COMPANYNAME kalyeri
.COPYRIGHT
MIT License

Copyright (c) 2024 Eric Duncan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
.TAGS
.LICENSEURI https://mit-license.org/
.PROJECTURI https://github.com/EricBDuncan/SendTo-Combine
.RELEASENOTES
	20240424 Initial Public Rlease.
.TODO
	Add to Windows 11 context menus.
#>
<#
.SYNOPSIS Add to Windows Context SendTo Menu, Combine Files. This will merge all selected files into one.
#>

#Environment checks
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8 #Console output encoding
$Script:IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
[string]$Script:ScriptFile=$MyInvocation.MyCommand.name
[string]$Script:ScriptName=($ScriptFile).replace(".ps1",'')
[string]$Script:ScriptPath=($MyInvocation.MyCommand.Source).replace("\$ScriptFile",'')

#Install
$destination="$env:programdata\SendTo-Combine"
if (!(test-path $destination)) {
	if ($IsElevated) {
		Set-Location $ScriptPath
		mkdir $destination
		copy-item .\cf.ps1 -destination $destination
		copy-item .\"Combine Files.lnk" -destination C:\Users\Default\AppData\Roaming\Microsoft\Windows\SendTo
		copy-item .\"Combine Files.lnk" -destination "$env:userprofile\AppData\Roaming\Microsoft\Windows\SendTo"
		#New-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Combine'
		#New-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Combine\command'
		#set-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Combine' -Value "Combine Files" -Type string
		#set-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\Combine\command' -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file c:\programdata\SendTo-Combine\cf.ps1" -Type string
		write-host "Installed."
		pause
		break
	} else {write-host 'Please run this script "As Administrator" the first time for installation.' ;pause; break}
}

#date
$date=get-date -Format yyyyMdd

#get dir & basename
if (!($args)) {write-host "No files selected..."; pause; break}
$list=$args
$dir=@(Get-ChildItem $list | foreach directoryname)[0]
$base=(Get-ChildItem @($list)[0]).basename[0..10] -join ""

#new single file name
$prefix="Combined-"
$extension=(Get-ChildItem $args[0]).extension
$name="$prefix"+"$base"+"$date"+"$extension"
$fullname= "$dir"+"\"+"$name"

#check file sizes & count
[int]$size=(Get-ChildItem $list | Measure-Object -Property Length -Sum).sum

#concatenate files
get-content $list | set-content "$fullname"

#measure new file
[int]$newsize = Get-ChildItem "$fullname" | Measure-Object  -Property Length -Sum | foreach Sum

#Output to screen
foreach ($file in $list) {"File selected: $file"}
write-host "Total files selected: $($size | foreach count)"
write-host "Total size of files selected: $($size | foreach sum)"
write-host "New combined file: $fullname" -ForegroundColor Yellow -BackgroundColor Blue
write-host "New File Size: $newsize "
If ($size -eq $newsize) {Write-Host "Success!" -ForegroundColor Red -BackgroundColor Yellow} ELSE {Write-Host "File size does not match! $size vs. $newsize" -ForegroundColor black -BackgroundColor Red}

pause