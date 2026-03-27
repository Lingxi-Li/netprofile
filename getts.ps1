param (
    [Parameter(Mandatory)][string]$Path
)

$json = Get-Content $Path -Raw | ConvertFrom-Json
$json.intervals | Select-Object -ExpandProperty 'sum' | ForEach-Object {
    '{0:F3} {1:F1}' -f $_.end, ($_.bytes / $_.seconds / 1MB)
}
