# If folder tmp-build exists, delete the folder
if (Test-Path "tmp-build") {
    Remove-Item -Path "tmp-build" -Recurse -Force
}

$env:HELM_REPO_URL = "https://azure-javaee.github.io/cargotracker-liberty-aks"
$env:HELM_REPO_NAME = "cargotracker-liberty-aks"
$env:ACR_NAME = (az acr list -g $env:RESOURCE_GROUP_NAME --query "[0].name" -o tsv)
$env:ACR_SERVER = (az acr show -n $env:ACR_NAME -g $env:RESOURCE_GROUP_NAME --query "loginServer" -o tsv)
$env:AKS_NAME = (az aks list -g $env:RESOURCE_GROUP_NAME --query "[0].name" -o tsv)

# Enable Helm support
azd config set alpha.aks.helm on

# Check if the repo exists before removing
$helmRepos = helm repo list
if ($helmRepos -match $env:HELM_REPO_NAME) {
    Write-Host "Removing Repo '$env:HELM_REPO_NAME'"
    helm repo remove $env:HELM_REPO_NAME
}
else {
    Write-Host "Repo '$env:HELM_REPO_NAME' not found in the list."
}

helm repo add $env:HELM_REPO_NAME $env:HELM_REPO_URL

az aks enable-addons `
    --addons monitoring `
    --name $env:AKS_NAME `
    --resource-group $env:RESOURCE_GROUP_NAME `
    --workspace-resource-id $env:WORKSPACE_ID

az postgres flexible-server parameter set --name max_prepared_transactions --value 10 -g $env:RESOURCE_GROUP_NAME --server-name $env:DB_RESOURCE_NAME
az postgres flexible-server restart -g $env:RESOURCE_GROUP_NAME --name $env:DB_RESOURCE_NAME

function Run-MavenCommand {
    param([string]$property)
    $result = mvn help:evaluate -D"expression=$property" -q -DforceStdout
    return $result.Trim()
}

$IMAGE_NAME = Run-MavenCommand 'project.artifactId'
$IMAGE_VERSION = Run-MavenCommand 'project.version'

##########################################################
# Create the custom-values.yaml file
##########################################################
@"
appInsightConnectionString: $env:APP_INSIGHTS_CONNECTION_STRING
loginServer: $env:ACR_SERVER
imageName: $IMAGE_NAME
imageTag: $IMAGE_VERSION
azureOpenAIClientId:
azureOpenAIEndpoint: $env:AZURE_OPENAI_ENDPOINT
azureOpenAIDeploymentName: $env:AZURE_OPENAI_MODEL_NAME

"@ | Set-Content -Path "custom-values.yaml"

##########################################################
# DB
##########################################################
@"
namespace: $env:AZURE_AKS_NAMESPACE
db:
  ServerName: $env:DB_RESOURCE_NAME.postgres.database.azure.com
  PortNumber: 5432
  Name: $env:DB_NAME
  User: $env:DB_USER_NAME
  Password: $env:DB_USER_PASSWORD
"@ | Add-Content -Path "custom-values.yaml" 