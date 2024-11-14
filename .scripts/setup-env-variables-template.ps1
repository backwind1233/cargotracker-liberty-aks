# PostgreSQL server name, customize this
$env:DB_RESOURCE_NAME = "libertydb1110"
# customize this
$env:RESOURCE_GROUP_NAME = "abc1110rg"
# customize this, if desired
$env:LOCATION = "eastus"

$env:APPINSIGHTS_NAME = "appinsights$([DateTimeOffset]::Now.ToUnixTimeSeconds())"
$env:DB_NAME = "libertydb"
# PostgreSQL database password
$env:DB_PASSWORD = "Secret123456"
$env:DB_PORT_NUMBER = "5432"
# PostgreSQL host name
$env:DB_SERVER_NAME = "$($env:DB_RESOURCE_NAME).postgres.database.azure.com"
$env:DB_USER = "liberty"
# WASdev/azure.liberty.aks
$env:LIBERTY_AKS_REPO_REF = "5886de1248e1cdcc891c1135d6ad3ae6660f0adf"
$env:NAMESPACE = "default"
$env:WORKSPACE_NAME = "$($env:RESOURCE_GROUP_NAME)ws"

# Optional variables for OpenAI shortest path feature.
# Uncomment and set values as described in README.md.

# $env:AZURE_OPENAI_KEY = "<your key>"
# $env:AZURE_OPENAI_ENDPOINT = "https://<yourdeployment>.openai.azure.com/"
# $env:AZURE_OPENAI_DEPLOYMENT_NAME = "gpt-4" 