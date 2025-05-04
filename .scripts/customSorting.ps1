param(
    $DiffFilePath = '/tmp/diff.txt'
)

# IF $ENV:CI exists, we assume we are in GitHub, otherwise Azure DevOps
$StartGroup = $ENV:CI ? '::group::' : '##[group]'
$EndGroup = $ENV:CI ? '::endgroup::' : '##[endgroup]'

$diff = Get-Content -Path $DiffFilePath

Write-Host "${StartGroup}Files found in diff:"
$diff | Write-Host
Write-Host "$EndGroup"

$diffTable = @{}
$diff | ForEach-Object -Process {
    $change = $_
    # there can be 2 elements for Add, Delete, Modify operations
    # there can be 3 elements if it's a rename
    $changeParts = ($change -split "`t")
    $operation = $changeParts[0]
    $path = $changeParts[-1]
    
    $entry = [pscustomobject]@{
        fileName   = Split-Path -Path $path -Leaf
        directory  = Split-Path -Path $path -Parent
        operation  = $operation
        diffString = $change
    }
    if ($null -eq $diffTable[$entry.directory]) {
        $diffTable[$entry.directory] = @{}
    }
    if ($entry.fileName -ne '.order') {
        $diffTable[$entry.directory][$entry.fileName] = $entry
    }
}
$sortedDiff = $(foreach ($directoryPath in ($diffTable.Keys | Sort-Object)) {
    $orderPath = [System.IO.Path]::Combine($directoryPath,'.order')
    if (Test-Path -Path $orderPath) {
        $order = Get-Content -Path $orderPath | ForEach-Object { $_.Trim() }
        $deleteSortedDiffs = @()
        $addSortedDiffs = foreach ($orderName in $order) {
            if ($null -ne $diffTable.$directoryPath.$orderName) {
                $diffString = $diffTable.$directoryPath.$orderName.diffString
                $operation = $diffTable.$directoryPath.$orderName.operation
                $diffTable.$directoryPath.Remove($orderName)
                if ($operation -eq 'D') {
                    $deleteSortedDiffs += $diffString
                    continue
                }
                elseif ($operation -in 'A', 'M', 'R' -or $operation -match '^R0[0-9][0-9]$') {
                    Write-Output -InputObject $diffString
                }
                else {
                    Write-Error -Message "Invalid changeset type '$operation' for $diffString"
                }
            }
        }
        # Deletes should happen in reverse order to add/modifys
        [array]::Reverse($deleteSortedDiffs)

        Write-Output -InputObject $addSortedDiffs
        Write-Output -InputObject $deleteSortedDiffs
    }
    # make sure to return unaddressed diffs too
    Write-Output -InputObject ($diffTable.$directoryPath.Values.diffString | Sort-Object)
}) | Where-Object { $_ }

Write-Host "${StartGroup}Sorted files:"

$sortedDiff | Write-Host

Write-Host "$EndGroup"

$sortedDiff | Out-File -Path $DiffFilePath