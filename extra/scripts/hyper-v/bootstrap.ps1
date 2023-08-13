# This script is called from the answerfile

# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx

#Write-Host "Copy unattend.xml to C:\Windows\Panther\Unattend\"
#New-Item C:\Windows\Panther\Unattend -Type Directory

# Get network connections
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'))
$connections = $networkListManager.GetNetworkConnections()

$connections |ForEach-Object {
    Write-Host "Setting network config"
    $_.GetNetwork().GetName() + 'category was previously set to' + $_.GetNetwork().GetCategory() | Out-File c:\windows\temp\logfile.txt
    $_.GetNetwork().SetCategory(1)
    $_.GetNetwork().GetName() + 'change to ' + $_.GetNetwork().GetCategory() | Out-File C:\windows\temp\logfile.txt -Append
}
