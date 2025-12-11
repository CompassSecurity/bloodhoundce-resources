#
# Create-BloodHoundOperatorSession.ps1
#
# Connect to BloodHound API using BloodHoundOperator.
#

param(
    [string]$Username = "admin",

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [string]$Hostname = "127.0.0.1",

    [int]$Port = 8080
)

Write-Host "[*] Authenticate..." -ForeGroundColor Green
$body = @{
    login_method = "secret"
    username     = $Username
    secret       = $Password
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://$Hostname`:$Port/api/v2/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

$token = $response.data.session_token
#$token = ($response.Content | ConvertFrom-Json).data.session_token

Import-Module /opt/BloodHoundOperator/BloodHoundOperator.ps1

Write-Host "[*] Logging in..." -ForeGroundColor Green
New-BHSession -Server $Hostname -Port $Port -JWT $token

Write-Host "[*] Your session:" -ForeGroundColor Green
Get-BHSession

Write-Host "[*] Ready to use BloodHoundOperator!" -ForeGroundColor Green
