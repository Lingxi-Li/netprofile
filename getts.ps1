param (
    [Parameter(Mandatory)][string]$Path
)

$json = Get-Content $Path -Raw | ConvertFrom-Json
if (-not $json.intervals.Length) { return }

$time = [DateTimeOffset]::Parse($json.start.timestamp.time).ToOffset([TimeSpan]::FromHours(8)).ToString('HHmm')
$activer = ($json.intervals | Where-Object { $_.sum.bytes -gt 0 }).Count / $json.intervals.Length
$efficiency = $json.end.sum_received.bytes / $json.end.sum_sent.bytes
$retransr = $json.end.sum_sent.retransmits / ($json.end.sum_received.bytes / 1MB)

'# timestamp    {0}'     -f $time
'# sndbuf       {0:N0}K' -f ($json.start.sndbuf_actual / 1KB)
'# rcvbuf       {0:N0}K' -f ($json.start.rcvbuf_actual / 1KB)
'# throughput   {0:N1}M' -f ($json.end.sum_received.bits_per_second / 8 / 1MB)
'# active       {0:P0}'  -f $activer
'# sent/recv    {0:P0}'  -f $efficiency
'# retrans/M    {0:N0}'  -f $retransr

$json.intervals | Select-Object -ExpandProperty 'sum' | ForEach-Object {
    '{0:F3} {1:F1}' -f $_.end, ($_.bytes / $_.seconds / 1MB)
}
