# 🚀 Configuración GCP - Microservices DevOps Workshop

## 📋 Información del Proyecto

### **Proyecto GCP**
- **Project ID**: `microservices-devops-0923`
- **Project Name**: "Microservices DevOps Workshop"
- **Billing Account**: `019405-5761D4-C499A5`
- **Status**: ✅ Activo con billing habilitado

### **Service Account para GitHub Actions**
- **Email**: `github-actions-sa@microservices-devops-0923.iam.gserviceaccount.com`
- **Key File**: `infrastructure/environments/dev/gcp-sa-key.json`
- **Roles Asignados**:
  - `roles/container.admin` - Gestión de GKE
  - `roles/storage.admin` - Gestión de Cloud Storage
  - `roles/compute.admin` - Gestión de Compute Engine

### **APIs Habilitadas**
- ✅ `container.googleapis.com` - Google Kubernetes Engine
- ✅ `compute.googleapis.com` - Compute Engine
- ✅ `containerregistry.googleapis.com` - Container Registry

## 🔐 GitHub Secrets Requeridos

Para que GitHub Actions funcione, necesitas configurar estos secrets en tu repositorio:

1. **GCP_PROJECT_ID**: `microservices-devops-0923`
2. **GCP_SA_KEY**: Contenido completo del archivo `gcp-sa-key.json`

### Cómo configurar GitHub Secrets:
1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Agrega cada secret con su valor

## 🏗️ Próximos Pasos

1. ✅ Configurar GitHub Secrets
2. ⏳ Migrar Terraform a GCP providers
3. ⏳ Crear manifiestos de Kubernetes
4. ⏳ Probar CD Pipeline en GCP

## 📁 Estructura de Archivos

```
infrastructure/environments/dev/
├── gcp-sa-key.json          # 🔐 ARCHIVO SENSIBLE (en .gitignore)
├── .gitignore               # ✅ Protege archivos sensibles
└── main.tf                  # ⏳ Migrar a GCP providers
```

## ⚠️ Seguridad

- **NUNCA** commitear `gcp-sa-key.json` a Git
- El archivo está protegido por `.gitignore`
- Usar GitHub Secrets para CI/CD
- Rotar claves periódicamente
