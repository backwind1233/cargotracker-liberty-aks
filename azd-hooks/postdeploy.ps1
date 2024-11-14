#!/usr/bin/env pwsh

$GATEWAY_PUBLICIP_ID = az network application-gateway list `
    --resource-group $env:RESOURCE_GROUP_NAME `
    --query '[0].frontendIPConfigurations[0].publicIPAddress.id' -o tsv

$GATEWAY_HOSTNAME = az network public-ip show --ids $GATEWAY_PUBLICIP_ID --query 'dnsSettings.fqdn' -o tsv
$CARGO_TRACKER_URL = "http://$GATEWAY_HOSTNAME/cargo-tracker/"
Write-Host "Cargo Tracker URL: $CARGO_TRACKER_URL"

# Check if deployment exists and restart if it does
$deploymentExists = kubectl get deployment cargo-tracker-cluster 2>$null
if ($LASTEXITCODE -eq 0) {
    kubectl rollout restart deployment/cargo-tracker-cluster
} 