# 🔐 Instrucciones para Configurar GitHub Secrets

## 📋 Para el Propietario del Repositorio

Necesitas configurar estos secrets en GitHub para que los workflows de CI/CD funcionen con GCP:

### **Paso 1: Ir a Settings del Repositorio**
1. Ve a tu repositorio en GitHub
2. Click en **"Settings"** (tab superior)
3. En el menú lateral izquierdo: **"Secrets and variables"** → **"Actions"**

### **Paso 2: Crear el primer secret**
1. Click **"New repository secret"**
2. **Name**: `GCP_PROJECT_ID`
3. **Value**: `microservices-devops-0923`
4. Click **"Add secret"**

### **Paso 3: Crear el segundo secret**
1. Click **"New repository secret"** otra vez
2. **Name**: `GCP_SA_KEY`
3. **Value**: (Pega TODO el JSON que está en `gcp-sa-key.json`)
4. Click **"Add secret"**

### **Paso 4: Verificar que los secrets estén configurados**
Deberías ver en la lista:
- ✅ `GCP_PROJECT_ID`
- ✅ `GCP_SA_KEY`

## 📁 Archivo de Clave

El archivo `gcp-sa-key.json` contiene la clave del service account. 
**NO COMMITEAR** este archivo - ya está en `.gitignore`.

## 🚀 Una vez configurados los secrets

Los workflows de GitHub Actions podrán:
- Autenticarse con GCP
- Crear recursos en Google Cloud
- Desplegar a GKE
- Usar Container Registry

## ⚠️ Importante

- Solo el propietario del repositorio puede configurar secrets
- Los secrets están encriptados en GitHub
- No son visibles para otros colaboradores
- Se pueden usar en workflows públicos sin exponerse
