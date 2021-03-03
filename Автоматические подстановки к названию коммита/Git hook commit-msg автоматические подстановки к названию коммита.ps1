[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $CommitFile
)

# Конвертер кодировок.
function ConvertTo-Encoding ([string]$From, [string]$To) {
  Begin {
    $encFrom = [System.Text.Encoding]::GetEncoding($from)
    $encTo = [System.Text.Encoding]::GetEncoding($to)
  }
  Process {
    $bytes = $encTo.GetBytes($_)
    $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
    $encTo.GetString($bytes)
  }
}

$CommitMessage = Get-Content -Path $CommitFile
$ProjectName = "TRACKERX"

$CommitMessage = $CommitMessage | ConvertTo-Encoding "UTF-8" "windows-1251"
Write-Host $CommitMessage

if ($CommitMessage -match '\S.') {

  $CommitMessage = $CommitMessage.substring(0, 1).ToUpper() + $CommitMessage.Remove(0, 1)
  $CurrentBranch = (git rev-parse --abbrev-ref HEAD)
  $HasMatch = $CurrentBranch -match "(.+_" + $ProjectName + "-)(\d+)"

  if ($HasMatch) {
    
    $IssueNumber = $Matches[2]
    $CommitMessage = $ProjectName + '-' + $IssueNumber + ' - ' + $CommitMessage

    $CommitMessage = $CommitMessage  | ConvertTo-Encoding "windows-1251" "UTF-8"
    Set-Content -Path $CommitFile -Value $CommitMessage

    exit 0
  }
}
else {
 	Write-Host "Enter the name of the commit"
  exit 1
}