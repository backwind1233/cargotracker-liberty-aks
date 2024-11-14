#!/bin/bash

# Function to check if a command exists
check_command() {
    local cmd=$1
    local install_msg=$2

    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd is not installed"
        echo "To install $cmd: $install_msg"
        error=1
    else
        echo "✅ $cmd is installed"
    fi
}

# Check Maven
check_command "mvn" "Visit https://maven.apache.org/install.html for installation instructions"

# Check Azure CLI
check_command "az" "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"

# Check Git
check_command "git" "sudo apt-get install git # For Ubuntu/Debian\nbrew install git # For macOS"

# Check kubectl
check_command "kubectl" "Visit https://kubernetes.io/docs/tasks/tools/install-kubectl/ for installation instructions"

# Check helm
check_command "helm" "Visit https://helm.sh/docs/intro/install/ for installation instructions"

# Exit with error if any tool is missing
if [ $error -eq 1 ]; then
    echo -e "\n⚠️  Please install the missing tools before proceeding."
    exit 1
fi

echo -e "\n✅ All required tools are installed!"

az extension add --upgrade -n application-insights
source .scripts/setup-env-variables-template.sh

mkdir tmp-build
DIR=$(pwd)/tmp-build
echo "Current directory: $DIR"

cd ${DIR}
git clone https://github.com/WASdev/azure.liberty.aks ${DIR}/azure.liberty.aks

cd ${DIR}/azure.liberty.aks
git checkout ${LIBERTY_AKS_REPO_REF}
export VERSION=1.0.22

cd ${DIR}
curl -L -o ${DIR}/azure-javaee-iaas-parent-${VERSION}.pom  \
     https://github.com/azure-javaee/azure-javaee-iaas/releases/download/azure-javaee-iaas-parent-${VERSION}/azure-javaee-iaas-parent-${VERSION}.pom


mvn install:install-file -Dfile=${DIR}/azure-javaee-iaas-parent-${VERSION}.pom \
                         -DgroupId=com.microsoft.azure.iaas \
                         -DartifactId=azure-javaee-iaas-parent \
                         -Dversion=${VERSION} \
                         -Dpackaging=pom

cd ${DIR}/azure.liberty.aks
mvn clean package -DskipTests

mkdir -p ${DIR}/../infra/azure.liberty.aks
cp -r ${DIR}/azure.liberty.aks/target/bicep/* ${DIR}/../infra/azure.liberty.aks

# shell sleep 5 seconds
sleep 5

rm -rf ${DIR}
