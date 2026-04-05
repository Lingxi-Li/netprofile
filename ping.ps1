param (
    [Parameter(Mandatory)][int]$n,
    [Parameter(Mandatory)][string]$ip
)

$sum = 0
foreach ($i in 1..$n) {
    $rtt = (Measure-Command { tnc $ip -Port 443 -InformationLevel Quiet }).Milliseconds
    '{0,3}: {1,5:N0} ms' -f $i, $rtt
    $sum += $rtt
    Start-Sleep 1
}
'-------------'
'avg: {0,5:N0} ms' -f ($sum / $n)
