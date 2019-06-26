param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$AzureRegion = 'East US'
)

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
(Get-AzResourceGroupDeployment -ResourceGroupName $rgName -Name $deploymentName).Outputs.resourceID.value