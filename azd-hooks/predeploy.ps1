#!/usr/bin/env pwsh

$env:ACR_NAME = az acr list -g $env:RESOURCE_GROUP_NAME --query [0].name -o tsv
$env:ACR_SERVER = az acr show -n $env:ACR_NAME -g $env:RESOURCE_GROUP_NAME --query 'loginServer' -o tsv
$env:ACR_USER_NAME = az acr credential show -n $env:ACR_NAME -g $env:RESOURCE_GROUP_NAME --query 'username' -o tsv
$env:ACR_PASSWORD = az acr credential show -n $env:ACR_NAME -g $env:RESOURCE_GROUP_NAME --query 'passwords[0].value' -o tsv

# Build and push docker image to ACR
Write-Host "Get image name and version......"

$IMAGE_NAME = mvn help:evaluate "-Dexpression=project.artifactId" -q -DforceStdout
$IMAGE_VERSION = mvn help:evaluate "-Dexpression=project.version" -q -DforceStdout

Write-Host "Docker build and push to ACR Server $env:ACR_SERVER with image name $IMAGE_NAME and version $IMAGE_VERSION"

mvn clean package -DskipTests
Set-Location -Path target

docker login -u $env:ACR_USER_NAME -p $env:ACR_PASSWORD $env:ACR_SERVER

$env:DOCKER_BUILDKIT = 1
docker buildx create --use
docker buildx build --platform linux/amd64 -t "$env:ACR_SERVER/${IMAGE_NAME}:${IMAGE_VERSION}" --pull --file=Dockerfile . --load
docker push "$env:ACR_SERVER/${IMAGE_NAME}:${IMAGE_VERSION}"