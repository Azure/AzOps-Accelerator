param(
    $DiffFilePath = '/tmp/diff.txt'
)

# IF $ENV:CI exists, we assume we are in GitHub, otherwise Azure DevOps
$StartGroup = $ENV:CI ? '::group::' : '##[group]'
$EndGroup = $ENV:CI ? '::endgroup::' : '##[endgroup]'

$diff = Get-Content -Path $DiffFilePath

Write-Host "${StartGroup}Files found in diff:"

$diff | Write-Host
$diffTable = @{}
$diff | ForEach-Object -Process {
    $change = $_
    $path = ($change -split "`t")[-1]
    $entry = [pscustomobject]@{
        fileName   = Split-Path -Path $path -Leaf
        directory  = Split-Path -Path $path -Parent
        diffString = $change
    }
    if ($null -eq $diffTable[$entry.directory]) {
        $diffTable[$entry.directory] = @{}
    }
    if ($entry.fileName -ne '.order') {
        $diffTable[$entry.directory][$entry.fileName] = $entry
    }
}
$sortedDiff = foreach ($directoryPath in ($diffTable.Keys | Sort-Object)) {
    $orderPath = [System.IO.Path]::Combine($directoryPath,'.order')
    if (Test-Path -Path $orderPath) {
        $order = Get-Content -Path $orderPath | ForEach-Object { $_.Trim() }
        foreach ($orderName in $order) {
            if ($null -ne $diffTable.$directoryPath.$orderName) {
                Write-Output -InputObject $diffTable.$directoryPath.$orderName.diffString
                $diffTable.$directoryPath.Remove($orderName)
            }
        }
    }
    Write-Output ($diffTable.$directoryPath.Values.diffString | Sort-Object)
}
Write-Host "$EndGroup"
Write-Host "${StartGroup}Sorted files:"

$sortedDiff | Write-Host

Write-Host "$EndGroup"

$sortedDiff | Out-File -Path $DiffFilePath