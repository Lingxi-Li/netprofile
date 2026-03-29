param (
    [Parameter(Mandatory)][string]$ServerIP,
    [Parameter(Mandatory)][string]$FileName,
    [Parameter(Mandatory)][string]$BufSize # like '1M'
)

$null = New-Item -ItemType Directory -Path 'iperf' -Force
iperf3 -c $ServerIP -w $BufSize -R -t 30 -i 0.1 --json > "iperf/$FileName.json"
.\getts.ps1 "iperf/$FileName.json" > "iperf/$FileName"