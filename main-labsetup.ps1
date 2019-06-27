param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$AzureRegion = 'East US',

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[int]$CoursePhase,

	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$RequiredRdpVM
)

## Download the ARM template
$templatePath = "$env:TEMP\phase$($CoursePhase)lab.json"
$url = "https://raw.githubusercontent.com/adbertram/devops-from-the-ground-up-resources/master/phase-$($CoursePhase)/phase1lab.json"
Invoke-WebRequest -Uri $url -OutFile $templatePath

$rgName = "DevOpsFromTheGroundUpCourse-Phase$($CoursePhase)"

## Create the phase's resource group
if (-not (Get-AzResourceGroup -Name $rgName -Location $AzureRegion -ErrorAction Ignore)) {
	$null = New-AzResourceGroup -Name $rgName -Location $AzureRegion
}

## Deploy phase 1 lab
$deploymentName = "DFTGU-Phase$($CoursePhase)"
$null = New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $rgName -TemplateFile $templatePath -Verbose

$deploymentResult = (Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName).Outputs

Write-Host "Your phase $($CoursePhase) lab VM IPs to RDP to are:"
$vmIps = @()
foreach ($val in $deploymentResult.Values.Value) {
	$pubIp = Get-AzResource -ResourceId $val
	$vmName = $pubIp.Id.split('/')[-1].Replace('-pubip', '')
	$ip = (Get-AzPublicIpAddress -Name $pubip.Name).IpAddress
	$vmIps += [pscustomobject]@{
		Name = $vmName
		IP   = $ip
	}
	Write-Host "VM: $vmName IP: $ip"
}

if ($env:OS -eq 'Windows_NT') {
	$rdpNow = Read-Host -Prompt "RDP to the required host ($RequiredRdpVM) now (Y,N)?"
	if ($rdpNow -eq 'Y') {
		$requiredVM = $vmIps.where({ $_.Name -eq $RequiredRdpVM })
		$ip = $requiredVM.IP
		$null = cmdkey /generic:$ip /user:"devops" /pass:"D3v0psAllTheThings!"
		mstsc /v:$ip
		#$null = cmdkey /delete:$ip
	} else {
		Write-Host "Please RDP to the VM [$($RequiredRdpVM) : $ip] now to begin course."
	}
} else {
	Write-Host "Please RDP to the VM [$($RequiredRdpVM) : $ip] now to begin course."
}