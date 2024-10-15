#!/bin/bash

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Por favor, instálalo y vuelve a intentar."
    exit 1
fi

# Verificar si Kind está instalado
if ! command -v kind &> /dev/null; then
    echo "Kind no está instalado. Instalando Kind..."
    curl -sLo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
else
    echo "Kind ya está instalado."
fi

# Verificar si kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "kubectl no está instalado. Instalando kubectl..."
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
else
    echo "kubectl ya está instalado."
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose no está instalado. Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose ya está instalado."
fi

# Verificar si OpenJDK 17 está instalado
if ! java -version 2>&1 | grep "17" &> /dev/null; then
    echo "OpenJDK 17 no está instalado. Instalando OpenJDK 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
    source ~/.bashrc
else
    echo "OpenJDK 17 ya está instalado."
fi

# Mostrar el valor de JAVA_HOME
echo "JAVA_HOME está configurado en: $JAVA_HOME"

echo "Configuración completa. Puedes proceder a ejecutar el script de despliegue."
