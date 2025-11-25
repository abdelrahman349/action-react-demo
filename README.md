# React Vite App - Docker & CI/CD Setup

## 📋 Overview
This project is a React application built with Vite, featuring a complete Docker setup and GitHub Actions Workflow for automatic deployment to Docker Hub.

---

## 🐳 Dockerfile Explanation

### Multi-Stage Build

#### Stage 1: Build (Builder)
```dockerfile
FROM node:18-alpine AS builder
```
- Uses `node:18-alpine` image (small and lightweight)
- Names this stage `builder` for later reference

**Build Steps:**
```dockerfile
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```
- Copies `package.json` and `package-lock.json`
- Installs dependencies with `npm ci` (faster and more secure than npm install)
- Copies all project files
- Builds the application and generates `dist/` folder

#### Stage 2: Runtime (Server)
```dockerfile
FROM node:18-alpine
```
- Clean new image to reduce final image size

**Runtime Steps:**
```dockerfile
RUN npm install -g serve
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
```
- Installs `serve` to serve static files
- Copies only `dist/` folder from builder stage (not all files)
- Exposes port 3000
- Runs `serve` command to serve the application

### Benefits:
✅ **Smaller Size**: Build dependencies are not included in final image  
✅ **Better Security**: Only necessary files are shipped  
✅ **Better Performance**: Production-ready application

---

## 🔄 GitHub Actions Workflow Explanation

### Workflow Name
```yaml
name: docker build and test
```

### Triggers
```yaml
on:
  push:
    branches:
      - Master
```
- The Workflow automatically runs when code is pushed to the `Master` branch

### Jobs

#### Job: build_and_test
```yaml
runs-on: ubuntu-latest
```
- Runs on the latest version of Ubuntu

#### Steps:

1️⃣ **Checkout Repository**
```yaml
uses: actions/checkout@v4
```
- Downloads the project code from the repository

2️⃣ **Login to Docker Hub**
```yaml
uses: docker/login-action@v3
with:
  username: ${{ secrets.DOCKERHUB_USERNAME }}
  password: ${{ secrets.DOCKERHUB_TOKEN }}
```
- Logs in using credentials stored in GitHub Secrets
- Allows pushing the image to Docker Hub after building

3️⃣ **Set up QEMU (for different architectures)**
```yaml
uses: docker/setup-qemu-action@v3
```
- Enables building Docker images for different systems (ARM, x86, etc.)

4️⃣ **Set up Docker Buildx**
```yaml
uses: docker/setup-buildx-action@v3
```
- Advanced tool for building Docker images with additional features

5️⃣ **Build and Push**
```yaml
uses: docker/build-push-action@v6
with:
  push: true
  tags: 3booda24/secure-nodejs:latest
```
- Builds the image using the Dockerfile
- Pushes it directly to Docker Hub with tag `3booda24/secure-nodejs:latest`
- Every push to Master updates the image on Docker Hub

---

## 🔑 Required Configuration

Before running the Workflow, make sure to add these Secrets to GitHub:

1. **DOCKERHUB_USERNAME**: Your Docker Hub account username
2. **DOCKERHUB_TOKEN**: Access Token from Docker Hub

### How to Add Secrets:
```
Settings → Secrets and variables → Actions → New repository secret
```

---

## 🚀 Usage

### Local Development:
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Running with Docker:
```bash
# Build the image
docker build -t my-react-app .

# Run the container
docker run -p 3000:3000 my-react-app
```

### Access the Application:
Open your browser and go to: `http://localhost:3000`

---

## 📁 Project Structure
```
.
├── Dockerfile              # Multi-stage Docker configuration
├── .github/workflows/
│   └── test.yaml          # GitHub Actions CI/CD Workflow
├── src/
│   ├── App.jsx
│   ├── main.jsx
│   ├── index.css
│   ├── components/        # React components
│   └── assets/
├── package.json
├── vite.config.js
└── index.html
```

---

## 📝 Important Notes

⚠️ **Branch Name**: The Workflow runs on the `Master` branch - make sure the branch name matches your actual GitHub branch

⚠️ **Docker Hub Username**: Replace `3booda24/secure-nodejs` with `your-username/your-repo` in the Workflow

---

## 📚 Useful References
- [Docker Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Vite Documentation](https://vitejs.dev/)