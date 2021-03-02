Что бы коммиты имели правильное название можно задать шаблон, например: BMW_FRONT-985 - Изменение главной страницы.
В папке .git\hooks локально или глобально нужно удалить файл commit-msg.sample и сделать commit-msg. В нем прописать:
#!/bin/sh
c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -Command '.git\hooks\commit-msg.ps1' $1
Это нужно для запуска PowerShell и выполнение команд в файле commit-msg.ps1, который то же нужно создать в этой папке и в нем прописать код ниже.
Этот код берет префикс $ProjectName-<number> из имени ветки и автоматически добавляет к названию коммита который вводится. Так же делает название коммита с заглавной буквы.
[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $CommitFile
)

# Конвертер кодировок.
   function ConvertTo-Encoding ([string]$From, [string]$To){
        Begin{
            $encFrom = [System.Text.Encoding]::GetEncoding($from)
            $encTo = [System.Text.Encoding]::GetEncoding($to)
        }
        Process{
            $bytes = $encTo.GetBytes($_)
            $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
            $encTo.GetString($bytes)
        }
    }

$CommitMessage = Get-Content -Path $CommitFile
$ProjectName = "BMW_FRONT"

$CommitMessage = $CommitMessage | ConvertTo-Encoding "UTF-8" "windows-1251"
Write-Host $CommitMessage
if ($CommitMessage -match '\S.') {

  $CommitMessage = (Get-Culture).TextInfo.ToTitleCase($CommitMessage)
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