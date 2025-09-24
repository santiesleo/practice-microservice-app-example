# 🔐 Cómo dar permisos para configurar GitHub Secrets

## Para tu compañero (propietario del repositorio):

### **Dar permisos de Admin:**
1. Ve a tu repositorio en GitHub
2. **Settings** → **Manage access** (en el menú lateral)
3. Encuentra tu usuario en la lista
4. Click en **"..."** al lado de tu nombre
5. Selecciona **"Admin"** en lugar de "Write" o "Maintain"
6. Click **"Change to admin"**

### **Con permisos de Admin podrás:**
- ✅ Configurar Secrets and variables
- ✅ Modificar Settings del repositorio
- ✅ Gestionar workflows
- ✅ Configurar branches protegidos
- ✅ Todo lo que necesita un DevOps

## Alternativa: Tu compañero configura los secrets

Si prefiere no dar permisos de Admin, puede configurar los secrets él mismo:

### **Secrets necesarios:**
1. **GCP_PROJECT_ID**: `microservices-devops-0923`
2. **GCP_SA_KEY**: (El JSON completo del archivo `gcp-sa-key.json`)

### **Ubicación en GitHub:**
- **Settings** → **Secrets and variables** → **Actions** → **"New repository secret"**

## ⚠️ Importante

- Solo los **propietarios** y **admins** pueden configurar secrets
- Los secrets están encriptados y no son visibles para otros
- Una vez configurados, los workflows pueden usarlos automáticamente
