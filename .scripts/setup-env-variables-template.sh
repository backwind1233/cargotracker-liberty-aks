export DB_RESOURCE_NAME="libertydb1110" # PostgreSQL server name, customize this
export RESOURCE_GROUP_NAME="abc1110rg" # customize this
export LOCATION=eastus # customize this, if desired

export APPINSIGHTS_NAME="appinsights$(date +%s)"
export DB_NAME=${DB_RESOURCE_NAME}
export DB_PASSWORD="Secret123456" # PostgreSQL database password
export DB_PORT_NUMBER=5432
export DB_SERVER_NAME="${DB_RESOURCE_NAME}.postgres.database.azure.com" # PostgreSQL host name
export DB_USER=liberty${DB_RESOURCE_NAME}
export LIBERTY_AKS_REPO_REF="5886de1248e1cdcc891c1135d6ad3ae6660f0adf" # WASdev/azure.liberty.aks
export NAMESPACE=default
export WORKSPACE_NAME="${RESOURCE_GROUP_NAME}ws"
