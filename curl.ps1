param (
    [Parameter(Mandatory)][string]$URL,
    [string]$TLSMax = '1.3'
)

$keys =
    'namelookup',
    'connect',
    'appconnect',
    'starttransfer',
    'total'
$options = ($keys | ForEach-Object { "%{time_$($_)}" }) -join ' '
$out = (curl -o NUL -w "%{size_download} %{speed_download} $options" --tls-max $TLSMax $URL || &{ exit }) -split ' '
[double[]]$times = $out[2..($out.Length - 1)]

'-------------------------------------'
'{0,-15} {1,10} {2,10}' -f 'event', 'time', 'delta'
'-------------------------------------'
foreach ($i in 0..($keys.Length - 1)) {
    '{0,-15} {1,10:F3} {2,10:F3}' -f $keys[$i], $times[$i], `
        ($i -eq 0 ? $times[$i] : $times[$i] - $times[$i - 1])
}
'-------------------------------------'
'{0,-18} {1,18:N0}' -f 'size (K)',         ($out[0] / 1KB)
'{0,-18} {1,18:N0}' -f 'throughput (K/s)', ($out[1] / 1KB)

# start                                        round-trip count
#   ├─ DNS lookup      %{time_namelookup}      1
#   ├─ TCP connect     %{time_connect}         1
#   ├─ TLS connect     %{time_appconnect}      2/1 (TLS 1.2/1.3)
#   ├─ first byte in   %{time_starttransfer}   1
#   └─ done            %{time_total}
