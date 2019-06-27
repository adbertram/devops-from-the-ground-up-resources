param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$AzureRegion = 'East US'
)

$requiredRdpVM = 'WIN10'

## Download the ARM template
$templatePath = "$env:TEMP\phase1lab.json"
$url = 'https://raw.githubusercontent.com/adbertram/devops-from-the-ground-up-resources/master/phase-1/phase1lab.json'
Invoke-WebRequest -Uri $url -OutFile $templatePath

$rgName = 'DevOpsFromTheGroundUpCourse-Phase1'

## Create the phase's resource group
if (-not (Get-AzResourceGroup -Name $rgName -Location $AzureRegion -ErrorAction Ignore)) {
	$null = New-AzResourceGroup -Name $rgName -Location $AzureRegion
}

## Deploy phase 1 lab
$deploymentName = 'DFTGU-Phase1'
$null = New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $rgName -TemplateFile $templatePath -Verbose

Write-Host 'Your phase 1 lab VM IPs to RDP to are:'
$deploymentResult = (Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName).Outputs

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

$rdpNow = Read-Host -Prompt "RDP to the required host ($requiredRdpVM) now (Y,N)?"
if ($rdpNow -eq 'Y') {
	$requiredVM = $vmIps.where({ $_.Name -eq $requiredRdpVM })
	$ip = $requiredVM.IP
	mstsc /v:$ip
}