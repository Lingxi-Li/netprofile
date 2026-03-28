param (
    [Parameter(Mandatory)][string]$Path
)

$json = Get-Content $Path -Raw | ConvertFrom-Json
$time = [DateTimeOffset]::Parse($json.start.timestamp.time).ToOffset([TimeSpan]::FromHours(8)).ToString('HHmm')
'# timestamp    {0}' -f $time
'# rcvbuf       {0:D0}K' -f ($json.start.rcvbuf_actual / 1KB)
'# retransmits  {0:D}' -f $json.end.sum_sent.retransmits
$json.intervals | Select-Object -ExpandProperty 'sum' | ForEach-Object {
    '{0:F3} {1:F1}' -f $_.end, ($_.bytes / $_.seconds / 1MB)
}
