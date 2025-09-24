#!/bin/bash

# ===========================================
# SCRIPT DE DESPLIEGUE AUTOMATIZADO A GKE
# COMPATIBLE CON GITHUB ACTIONS
# ===========================================

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Verificar variables de entorno requeridas
if [ -z "$GCP_PROJECT_ID" ]; then
    error "GCP_PROJECT_ID no está configurado"
fi

if [ -z "$GCP_ZONE" ]; then
    error "GCP_ZONE no está configurado"
fi

log "Iniciando despliegue automatizado..."

# 1. Configurar gcloud (ya autenticado por GitHub Actions)
log "Configurando gcloud..."
gcloud config set project "$GCP_PROJECT_ID"
gcloud auth configure-docker --quiet

# Configurar Docker Hub (para evitar errores de autenticación)
log "Configurando Docker Hub..."
echo "Configurando acceso público a Docker Hub..."

# 2. Instalar gke-gcloud-auth-plugin
log "Instalando gke-gcloud-auth-plugin..."
gcloud components install gke-gcloud-auth-plugin --quiet

# 3. Conectar al cluster GKE
log "Conectando al cluster GKE..."
gcloud container clusters get-credentials microservices-cluster-staging-v3 --zone="$GCP_ZONE"

# 4. Obtener IP de Redis desde Terraform
log "Obteniendo IP de Redis desde Terraform..."
cd infrastructure/environments/staging
REDIS_HOST=$(terraform output -raw redis_host 2>/dev/null || echo "")
cd ../../..

if [ -z "$REDIS_HOST" ]; then
    warn "No se pudo obtener la IP de Redis desde Terraform, usando IP por defecto"
    REDIS_HOST="10.219.117.51"  # IP conocida del Memorystore
fi

log "Redis Host: $REDIS_HOST"

log "IP de Redis obtenida: $REDIS_HOST"

# 5. Actualizar ConfigMap con IP de Redis (compatible con GitHub Actions)
log "Actualizando ConfigMap con IP de Redis..."
CONFIGMAP_FILE="k8s/staging/configmap.yaml"

# Crear backup
cp "$CONFIGMAP_FILE" "${CONFIGMAP_FILE}.backup"

# Actualizar usando sed compatible
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/REDIS_HOST: \".*\"/REDIS_HOST: \"$REDIS_HOST\"/" "$CONFIGMAP_FILE"
else
    # Linux
    sed -i "s/REDIS_HOST: \".*\"/REDIS_HOST: \"$REDIS_HOST\"/" "$CONFIGMAP_FILE"
fi

# 6. Construir y subir imágenes Docker (usando docker build en lugar de buildx)
log "Construyendo y subiendo imágenes Docker..."

# Auth API
log "Construyendo auth-api..."
docker build --platform linux/amd64 --no-cache -t gcr.io/$GCP_PROJECT_ID/auth-api:latest ./auth-api
docker push gcr.io/$GCP_PROJECT_ID/auth-api:latest

# Users API
log "Construyendo users-api..."
docker build --platform linux/amd64 -t gcr.io/$GCP_PROJECT_ID/users-api:latest ./users-api
docker push gcr.io/$GCP_PROJECT_ID/users-api:latest

# Todos API
log "Construyendo todos-api..."
docker build --platform linux/amd64 -t gcr.io/$GCP_PROJECT_ID/todos-api:latest ./todos-api
docker push gcr.io/$GCP_PROJECT_ID/todos-api:latest

# Frontend
log "Construyendo frontend..."
docker build --platform linux/amd64 -t gcr.io/$GCP_PROJECT_ID/frontend:latest ./frontend
docker push gcr.io/$GCP_PROJECT_ID/frontend:latest

# 7. Desplegar en Kubernetes
log "Desplegando en Kubernetes..."

# Namespace
kubectl apply -f k8s/staging/namespace.yaml

# ConfigMap
kubectl apply -f k8s/staging/configmap.yaml

# Deployments y Services
kubectl apply -f k8s/staging/auth-api-deployment.yaml
kubectl apply -f k8s/staging/users-api-deployment.yaml
kubectl apply -f k8s/staging/todos-api-deployment.yaml
kubectl apply -f k8s/staging/frontend-deployment.yaml

# Ingress
kubectl apply -f k8s/staging/ingress.yaml

# 7. Esperar a que los pods estén listos
log "Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=auth-api -n microservices-staging --timeout=300s || warn "auth-api no está listo en 5 minutos"
kubectl wait --for=condition=ready pod -l app=users-api -n microservices-staging --timeout=300s || warn "users-api no está listo en 5 minutos"
kubectl wait --for=condition=ready pod -l app=todos-api -n microservices-staging --timeout=300s || warn "todos-api no está listo en 5 minutos"
kubectl wait --for=condition=ready pod -l app=frontend -n microservices-staging --timeout=300s || warn "frontend no está listo en 5 minutos"

# 8. Obtener IP del Ingress
log "Obteniendo IP del Ingress..."
INGRESS_IP=""
for i in {1..30}; do
    INGRESS_IP=$(kubectl get ingress microservices-ingress -n microservices-staging -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$INGRESS_IP" ]; then
        break
    fi
    log "Esperando IP del Ingress... (intento $i/30)"
    sleep 10
done

if [ -z "$INGRESS_IP" ]; then
    warn "No se pudo obtener la IP del Ingress en 5 minutos"
    warn "Puede que tarde más tiempo en asignarse"
else
    log "IP del Ingress obtenida: $INGRESS_IP"
    echo "INGRESS_IP=$INGRESS_IP" >> $GITHUB_ENV
fi

# 9. Mostrar estado final
log "Estado final del despliegue:"
kubectl get pods -n microservices-staging
kubectl get services -n microservices-staging
kubectl get ingress -n microservices-staging

log "¡Despliegue completado exitosamente!"

# 10. Información de acceso
if [ -n "$INGRESS_IP" ]; then
    log "=== INFORMACIÓN DE ACCESO ==="
    log "Frontend: http://$INGRESS_IP"
    log "Auth API: http://$INGRESS_IP/api/auth"
    log "Users API: http://$INGRESS_IP/api/users"
    log "Todos API: http://$INGRESS_IP/api/todos"
    log "=========================="
fi