#
# Create-BloodHoundOperatorSession.ps1
#
# Connect to BloodHound API using BloodHoundOperator.
#

Write-Host "[*] Loading BloodHoundOperator..." -ForeGroundColor Green
Import-Module /opt/BloodHoundOperator/BloodHoundOperator.ps1

$BHTokenKey = "WW91ciBCbG9vZEhvdW5kIEFQSSBLZXkgY29tZXMgaGVyZSA6KQ=="
$BHTokenID = "596F7572-2054-6F6B-656E-204944203A29"
$BHServer = "127.0.0.1"
$BHPort = "8080"

Write-Host "[*] Logging in..." -ForeGroundColor Green
New-BHSession -Server $BHServer -Port $BHPort -TokenID $BHTokenID -Token (ConvertTo-SecureString -AsPlainText -Force $BHTokenKey)

Write-Host "[*] Your session:" -ForeGroundColor Green
Get-BHSession

Write-Host "[*] Ready to use BloodHoundOperator!" -ForeGroundColor Green
