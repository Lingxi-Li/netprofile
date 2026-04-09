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
    # $info = Invoke-RestMethod "http://ipinfo.io/$Ip" -TimeoutSec 5
	# if ($info.bogon) { return 'LAN' }
    # "$($info.country), $($info.city), $($info.org ?? 'Unknown ISP')"
	$info = Invoke-RestMethod "http://ipwho.is/$Ip" -TimeoutSec 5
	if (-not $info.success) { return $info.message -eq 'Reserved range' ? '--' : $info.message }
	$conn = $info.connection
	'{0} AS{1},  {2}' -f `
		$info.country_code,
		($conn.asn -ne 0 ? $conn.asn : '----'),
		$conn.org
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
