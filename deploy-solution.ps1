$tenantName = "saxony1"

# $sshkey = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAklvcJCA1K82mjlxM1ZHP1PF7eqKZ5KcmxLeNSJ7vMLD1/XUMZ667P2Ep7iu/J4Ci4u6V4LyYDodhRRFZaaxMFHTUVTwcApuh0fl4UJY/Evd6R+A66zxG8oSG75KQTiOYsV4cZ1PnMfg1Y014n814VGKd68ZHKc2KQFLGfsBZ7Hqc2NIU1Y0AxNaeHG8i9FlhSSCDuk/Lyh3o+vJl3GKFMezua5+rFG+H8wPSCN9tkrf+zpW1ynyXC+xEn9eenLcryyqa9G2MYR1FgClxLTgZzAHYCnmMgsMxxvMVOlI6nLS3sFh4+14j8wgPbv4TzH3AI7PxcGbOvWGvlTsLRL/nmQ=="
$authorizedKeyFilename = "C:\Users\chgeuer\puttykeys\authorizedkeys.txt"
$githubUser = "chgeuer"
$githubProject = "td"

$_ignore = & git commit -am "." -q
$branch =  & git rev-parse HEAD
$repositoryUrl = "https://raw.githubusercontent.com/$($githubUser)/$($githubProject)/$($branch)/"

Write-Host "Pusing to '$($repositoryUrl)'"
$_ignore = & git push origin master -q

$location="West Europe"
$resourceGroupName="rg-$($tenantName)"

$commonSettings = @{
	tenantName=$tenantName
	adminUsername=$env:USERNAME.ToLower()
	adminSecureShellKey=$(Get-Content -Path $authorizedKeyFilename).Trim()
	longtermResourceGroupName="longterm-$($tenantName)"
	deployRegServer="Enabled"
	regServerInstanceCount=2
	deployPortalServer="Enabled"
	repositoryUrl=$repositoryUrl
}

New-AzureRmResourceGroup `
 	-Name $resourceGroupName `
 	-Location $location `
	-Force

#	-TemplateParameterObject @{ commonSettings=$commonSettings } `
$deploymentResult = New-AzureRmResourceGroupDeployment `
	-ResourceGroupName $resourceGroupName `
	-TemplateUri "$($repositoryUrl)/ARM/azuredeploy.json" `
	-TemplateParameterObject $commonSettings `
	-Mode Complete  `
	-Force `
	-Verbose

Write-Host "Deployment to $($commonSettings['resourceGroupName']) is $($deploymentResult.ProvisioningState)"
