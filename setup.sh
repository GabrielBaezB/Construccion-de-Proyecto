#!/bin/bash
# Llama al script de instalación de dependencias
#./install_dependencies.sh #en caso que no este nada instalado
# Configura tus variables
BACKEND_REPO_URL="https://github.com/GabrielBaezB/eventmanagerfinal.git"  # URL del repositorio backend
FRONTEND_REPO_URL="https://github.com/PaarXul/Front-End-Reservas.git"  # URL del repositorio frontend
PROJECT_NAME="eventmanager"

# Crear carpeta del proyecto si no existe
if [ ! -d "$PROJECT_NAME" ]; then
    mkdir $PROJECT_NAME
else
    echo "La carpeta '$PROJECT_NAME' ya existe. Por favor, elimina la carpeta o cambia el nombre del proyecto."
    exit 1
fi

# Clonar el repositorio backend
echo "Clonando el repositorio backend..."
git clone -b main2 $BACKEND_REPO_URL "$PROJECT_NAME/backend" || { echo "Error al clonar el repositorio backend."; exit 1; }

# Clonar el repositorio frontend
echo "Clonando el repositorio frontend..."
git clone -b Nicolas $FRONTEND_REPO_URL "$PROJECT_NAME/frontend" || { echo "Error al clonar el repositorio frontend."; exit 1; }

# Crear carpeta para Kubernetes
mkdir -p "$PROJECT_NAME/k8s"

# Mover archivos de Kubernetes desde el backend
if [ -d "$PROJECT_NAME/backend/k8s" ]; then
    mv "$PROJECT_NAME/backend/k8s/"* "$PROJECT_NAME/k8s/" || { echo "Error al mover los archivos de Kubernetes."; exit 1; }
    echo "Archivos de Kubernetes movidos exitosamente."
else
    echo "No se encontraron archivos de Kubernetes en el backend."
fi

# Mover docker-compose.yml desde la carpeta del backend a la raíz del proyecto
if [ -f "$PROJECT_NAME/backend/docker-compose.yml" ]; then
    mv "$PROJECT_NAME/backend/docker-compose.yml" "$PROJECT_NAME/" || { echo "Error al mover docker-compose.yml."; exit 1; }
    echo "docker-compose.yml ha sido movido a la raíz del proyecto."
else
    echo "docker-compose.yml no encontrado en la carpeta del backend."
fi

# Mensaje de éxito
echo "Estructura del proyecto creada con éxito en la carpeta '$PROJECT_NAME'."
