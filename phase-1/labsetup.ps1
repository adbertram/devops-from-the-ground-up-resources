param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string]$AzureRegion = 'East US'
)


## Download the main lab setup script
$labSetupPath = "$env:TEMP\phase1-labsetup.ps1"
$url = 'https://raw.githubusercontent.com/adbertram/devops-from-the-ground-up-resources/master/labsetup.ps1'
Invoke-WebRequest -Uri $url -OutFile $labSetupPath

## Execute the lab setup script for the phase
& $labSetupPath -AzureRegion $AzureRegion -CoursePhase 1 -RequiredRdpVM 'WIN10'