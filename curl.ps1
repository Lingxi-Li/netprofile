param (
    [Parameter(Mandatory)][string]$URL
)

$keys =
    'namelookup',
    'connect',
    'appconnect',
    'pretransfer',
    'starttransfer',
    'total'
$options = ($keys | ForEach-Object { "%{time_$($_)}" }) -join ' '
[double[]]$times = (curl -o NUL -w $options $URL) -split ' '

''
'{0,-15} {1,10} {2,10}' -f '', 'time', 'delta'
'-------------------------------------'
foreach ($i in 0..($keys.Length - 1)) {
    '{0,-15} {1,10:F3} {2,10:F3}' -f $keys[$i], $times[$i], `
        ($i -eq 0 ? $times[$i] : $times[$i] - $times[$i - 1])
}

# start
#   ├─ DNS lookup        %{time_namelookup}
#   ├─ TCP connect       %{time_connect}
#   ├─ TLS handshake     %{time_appconnect}
#   ├─ request prepared  %{time_pretransfer}
#   ├─ first byte in     %{time_starttransfer}
#   └─ done              %{time_total}
