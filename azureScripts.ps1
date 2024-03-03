Connect-AzAccount

$context = Get-AzSubscription -SubscriptionName PAYG-Sandboxes

Set-AzContext $context


Set-AzDefault -ResourceGroupName rg_sb_eastus_89803_1_17094983788

$githubOrganizationName = 'nenad0707'

$githubRepositoryName = 'toy-website-test'


$applicationRegistration = New-AzADApplication -DisplayName 'toy-website-test'

New-AzADAppFederatedCredential `
   -Name 'toy-website-test' `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):environment:Website"

New-AzADAppFederatedCredential `
   -Name 'toy-website-test-branch' `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"
   
$resoursegroup = Get-AzResourceGroup -Name rg_sb_eastus_89803_1_17094983788

Write-Host $resoursegroup.ResourceId

New-AzADServicePrincipal -AppId $applicationRegistration.AppId
New-AzRoleAssignment `
   -ApplicationId $($applicationRegistration.AppId) `
   -RoleDefinitionName Contributor `
   -Scope $resoursegroup.ResourceId


$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)" ## write these secrets to github secrets
