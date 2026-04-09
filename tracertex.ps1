param(
	[string][Parameter(Mandatory)]$Dst,
	[int]$Hop = 32,
	[string][ValidateSet('4', '6')]$Ipv
)

$ErrorActionPreference = 'Stop'

function FetchInfo {
	param(
		[string][Parameter(Mandatory)]$Ip
	)
    $info = Invoke-RestMethod "http://ipinfo.io/$Ip" -TimeoutSec 5
	if ($info.bogon) { return 'LAN' }
    "$($info.country), $($info.city), $($info.org ?? 'Unknown ISP')"
}

function ProcessLine {
	param(
		[string][Parameter(Mandatory)]$Line
	)
	$TIMEOUT = 'Timeout'
	$Line = $Line.TrimEnd().Replace('Request timed out.', $TIMEOUT)
	$segs = $Line.TrimStart() -split '\s{2,}'
    ($segs.Length -ne 5) -or ($segs[-1] -eq $TIMEOUT) ?
        $Line : "$Line`t$(FetchInfo $segs[-1])"
}

try {
	$tracertArgs = '-d', '-h', $Hop
    if ($Ipv) { $tracertArgs += "-$Ipv" }
	$tracertArgs += $Dst
	"tracert $($tracertArgs -join ' ')"
	& tracert @tracertArgs | ForEach-Object {
		if ($_) { ProcessLine $_ }
	}
}
catch [System.Management.Automation.PipelineStoppedException] {
} # user interrupted the pipeline, e.g., Ctrl+C
catch {
	Write-Error "$($_.Exception.GetType().Name): $($_.Exception.Message)"
}
