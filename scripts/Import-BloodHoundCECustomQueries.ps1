#
# Import-BloodHoundCECustomQueries.ps1
#
# Script to import BloodHound CE Custom Queries
#

$markdownFilePath = "../custom_queries/BloodHound_CE_Custom_Queries.md"
$markdownParsed = ConvertFrom-Markdown $markdownFilePath

$category = ""
$name = ""
$query = ""
$counter = 1000

Write-Host "[*] Removing all queries starting with [C-..." -ForegroundColor green
Get-BHQuery -Name "[C-*" | Remove-BHQuery -Force
Write-Host

Write-Host "[*] Importing queries ..." -ForegroundColor green
foreach ($token in $markdownParsed.Tokens) {
  if ($token.Level -eq 2){
    $counter = [math]::Ceiling($counter/100)*100 # Go to next number divisible by 100
    $name = $token.Inline.Content.ToString()
    Write-Host "[*] Found category [C-$counter] $name..." -ForegroundColor green
    New-BHQuery -Name "[C-$counter] ########## $name ##########"  -Query "MATCH (n) WHERE false RETURN n"
  }
  elseif ($token.Level -eq 3){
    $counter++
    $name = $token.Inline.Content.ToString()
  }
  elseif ($token.FencedChar -eq "``" ){
    $query = ""
    foreach ($line in $token.Lines){
      $query += "$line `n"
    }
    Write-Host "[*] Importing query [C-$counter] $name..."
    New-BHQuery -Name "[C-$counter] $name"  -Query "$query"
  }
}
