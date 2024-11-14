# Install/upgrade application-insights extension
az extension add --upgrade -n application-insights

# Source environment variables (PowerShell equivalent)
. .\.scripts\setup-env-variables-template.ps1

# Create temporary directory
$DIR = Join-Path (Get-Location) "tmp-build"
New-Item -ItemType Directory -Path $DIR -Force
Write-Host "Current directory: $DIR"

# Clone repository
Set-Location $DIR
git clone https://github.com/WASdev/azure.liberty.aks (Join-Path $DIR "azure.liberty.aks")

# Checkout specific branch and get version
Set-Location (Join-Path $DIR "azure.liberty.aks")
git checkout $env:LIBERTY_AKS_REPO_REF
$VERSION = Select-String -Path "pom.xml" -Pattern "<version>" | 
           Select-Object -Skip 1 -First 1 | 
           ForEach-Object { $_.Line.Trim() -replace "<version>|</version>","" }

# Download POM file
Set-Location $DIR
$pomUrl = "https://github.com/azure-javaee/azure-javaee-iaas/releases/download/azure-javaee-iaas-parent-${VERSION}/azure-javaee-iaas-parent-${VERSION}.pom"
$pomFile = Join-Path $DIR "azure-javaee-iaas-parent-${VERSION}.pom"
Invoke-WebRequest -Uri $pomUrl -OutFile $pomFile

# Install Maven file
mvn install:install-file "-Dfile=$pomFile" `
                        "-DgroupId=com.microsoft.azure.iaas" `
                        "-DartifactId=azure-javaee-iaas-parent" `
                        "-Dversion=$VERSION" `
                        "-Dpackaging=pom"

# Build project
Set-Location (Join-Path $DIR "azure.liberty.aks")
mvn clean package -DskipTests

# Copy bicep files
$targetDir = Join-Path $DIR "..\infra\azure.liberty.aks"
New-Item -ItemType Directory -Path $targetDir -Force
Copy-Item -Path (Join-Path $DIR "azure.liberty.aks\target\bicep\*") -Destination $targetDir -Recurse

# Wait 5 seconds
Start-Sleep -Seconds 5

# Cleanup
Remove-Item -Path $DIR -Recurse -Force 