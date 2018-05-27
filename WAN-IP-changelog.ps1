# Get IP Address from api.ipify.org and store in log File
#
# This script is provided as-is.  Use at your own risk.
# This script is provided for educational purposes only.
# This script is not associated with SolarWinds or SoalrWinds MSP in any way.


# Variable Definitions
$LogPath = "C:\Logs" #Path to store the log file
$LogName = "IP-Change-Log.txt" #Filename of the log file
$Debug = $TRUE #Set to TRUE to write the IP to the log file everytime it runs
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss") #DateTime stamp string

# Function to write to a logfile
# USAGE: Write-Log($Level, $Message, $Logfile)
Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $Logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp--$Level--$Message"
    If($Logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

# Check for existing log file
$LogFile = "$LogPath\$LogName"
if(!(Test-Path $LogFile)){
    New-Item -ItemType "directory" -Path $LogPath | Out-Null
    New-Item -ItemType "file" -Path $LogFile -Value "-------------- Log File Created --------------`r`n" | Out-Null
    Write-Host("No Log File Found - Created a new log file: $LogFile")
}

# Get Current IP Address
$IP = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'

# Get last WAN IP Address from log file
$LastLine = Get-Content -Path $LogFile | Select -Last 1
If ($LastLine -ne "-------------- Log File Created --------------"){
  $Elements = $LastLine -split "--"
  $LastIP = $Elements[2]
}else{
  $LastIP = "$($IP.ip)"
}

# Check Last IP against New IP and write to log file
if ($IP.ip -ne $LastIP){
  Write-Host("WARNING - IP Address changed from $LastIP to $($IP.ip)")
  Write-Log "WARN" "$($IP.ip)--OLDIP=$LastIP" $Logfile
  Exit 1001
}else{
  if ($Debug -eq $TRUE){
    Write-Host("WAN IP: $($IP.ip)")
    Write-Log "INFO" "$($IP.ip)" $Logfile
    Exit 0
  }
}
