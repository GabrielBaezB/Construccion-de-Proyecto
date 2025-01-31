#!/bin/bash

# Función para manejar errores
error_exit() {
  echo "Error: $1"
  exit 1
}

# Configura tus variables
PROJECT_NAME="eventmanager"
BACKEND_IMAGE_NAME="${PROJECT_NAME}-backend"
FRONTEND_IMAGE_NAME="${PROJECT_NAME}-frontend"

# Paso 1: Crear el clúster de kind si no existe
if ! kind get clusters | grep -q $PROJECT_NAME; then
  echo "Creando un clúster de Kubernetes..."
  kind create cluster --name $PROJECT_NAME || error_exit "No se pudo crear el clúster de Kubernetes."
else
  echo "El clúster '$PROJECT_NAME' ya existe."
fi

# Paso 2: Compilar el proyecto backend
echo "Construyendo la imagen del backend..."
if cd "$PROJECT_NAME/backend"; then
  ./mvnw clean package || error_exit "Falló la compilación del backend."
else
  error_exit "No se pudo cambiar al directorio del backend."
fi

# Paso 3: Construir la imagen Docker del backend
echo "Construyendo la imagen Docker del backend..."
docker build -t $BACKEND_IMAGE_NAME . || error_exit "No se pudo construir la imagen del backend."

# Paso 4: Compilar el proyecto frontend y construir su imagen Docker
echo "Construyendo la imagen del frontend..."
if cd "../frontend"; then
  docker build -t $FRONTEND_IMAGE_NAME . || error_exit "No se pudo construir la imagen del frontend."
else
  error_exit "No se pudo cambiar al directorio del frontend."
fi

# Paso 5: Cargar imágenes en el clúster de kind
echo "Cargando la imagen del backend en el clúster..."
kind load docker-image $BACKEND_IMAGE_NAME --name $PROJECT_NAME || error_exit "No se pudo cargar la imagen del backend."

echo "Cargando la imagen del frontend en el clúster..."
kind load docker-image $FRONTEND_IMAGE_NAME --name $PROJECT_NAME || error_exit "No se pudo cargar la imagen del frontend."

# Paso 6: Aplicar configuraciones de Kubernetes (PV, PVC, MySQL, Backend y Frontend)
echo "Aplicando configuraciones de MySQL..."
kubectl apply -f "../k8s/mysql-pv.yaml" || error_exit "No se pudo aplicar el Persistent Volume."
kubectl apply -f "../k8s/mysql-pvc.yaml" || error_exit "No se pudo aplicar el Persistent Volume Claim."
kubectl apply -f "../k8s/mysql-deployment.yaml" || error_exit "No se pudo desplegar MySQL."
kubectl apply -f "../k8s/mysql-service.yaml" || error_exit "No se pudo aplicar el servicio de MySQL."

echo "Desplegando el front-end y backend..."
kubectl apply -f "../k8s/eventmanager-deployment.yaml" || error_exit "No se pudo desplegar el backend."
kubectl apply -f "../k8s/eventmanager-service.yaml" || error_exit "No se pudo aplicar el servicio del backend."

# Paso 7: Verificar el despliegue
echo "Verificando el estado de los pods..."
kubectl get pods

# Paso 8: Mensaje de éxito
echo "Despliegue completado. Accede a tu aplicación en http://localhost:8080"
