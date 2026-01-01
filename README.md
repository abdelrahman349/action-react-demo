# 🚀 React Vite App - Complete CI/CD & Cloud Deployment Guide

> **A production-ready React application with Docker containerization, GitHub Actions CI/CD, Kubernetes deployment, and Infrastructure as Code using Terraform**

---

## 📋 Table of Contents
1. [Project Overview](#-project-overview)
2. [Architecture](#-architecture)
3. [Technology Stack](#-technology-stack)
4. [Dockerfile Deep Dive](#-dockerfile-deep-dive)
5. [GitHub Actions Workflow](#-github-actions-workflow)
6. [Kubernetes Deployment](#-kubernetes-deployment)
7. [Infrastructure as Code (Terraform)](#-infrastructure-as-code-terraform)
8. [Setup & Configuration](#-setup--configuration)
9. [Local Development](#-local-development)
10. [Deployment Guide](#-deployment-guide)
11. [Troubleshooting](#-troubleshooting)

---

## 📋 Project Overview

This project demonstrates a **complete end-to-end DevOps workflow** for deploying a React application to AWS EKS (Elastic Kubernetes Service) using modern CI/CD practices.

### Key Features:
✅ **React 18** - Modern UI framework with Vite for fast development  
✅ **Docker Multi-Stage Build** - Optimized production images  
✅ **GitHub Actions CI/CD** - Automated build and deployment pipeline  
✅ **Kubernetes (K8s)** - Orchestration and scaling  
✅ **Terraform** - Infrastructure automation (IaC)  
✅ **AWS EKS** - Managed Kubernetes cluster  
✅ **Docker Hub Integration** - Centralized image registry  

---

## 🏗️ Architecture
########
### End-to-End Deployment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      Developer Workflow                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────┐
        │   GitHub Repository (Master)     │
        │   Push Code Trigger              │
        └──────────────────┬───────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         │                                   │
         ▼                                   ▼
    ┌─────────────┐               ┌────────────────────┐
    │  Terraform  │               │  GitHub Actions    │
    │  Provision  │               │  Pipeline (CI/CD)  │
    │  EKS Cluster│               │                    │
    └──────┬──────┘               └─────────┬──────────┘
           │                                 │
           │                    ┌────────────┴──────────┐
           │                    │                       │
           │                    ▼                       ▼
           │            ┌──────────────────┐  ┌──────────────────┐
           │            │  Build & Test    │  │  Push to Docker  │
           │            │  React App       │  │  Hub Registry    │
           │            └──────────────────┘  └────────┬─────────┘
           │                                           │
           │                                           ▼
           │                                ┌──────────────────────┐
           │                                │  Docker Image Ready  │
           │                                │  3booda24/secure-... │
           │                                └──────────┬───────────┘
           │                                           │
           ▼                                           ▼
    ┌──────────────────┐                    ┌────────────────────┐
    │  AWS EKS Cluster │◄──────────────────│  Deploy to EKS     │
    │  (Kubernetes)    │   kubectl apply    │  Update kubeconfig │
    └────────┬─────────┘                    └────────────────────┘
             │
             ▼
    ┌──────────────────┐
    │  Running Pods    │
    │  Load Balancer   │
    │  Service         │
    └──────────────────┘
             │
             ▼
    ┌──────────────────┐
    │   Users Access   │
    │   Application    │
    └──────────────────┘
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | React 18 + Vite | Fast, modern UI development |
| **Build Tool** | Vite | Lightning-fast build tool |
| **Container** | Docker | Image packaging & isolation |
| **Registry** | Docker Hub | Container image storage |
| **CI/CD** | GitHub Actions | Automated workflow |
| **Orchestration** | Kubernetes (K8s) | Container deployment & scaling |
| **Cloud** | AWS EKS | Managed Kubernetes service |
| **IaC** | Terraform | Infrastructure provisioning |
| **Package Manager** | npm | Dependency management |
| **Runtime** | Node.js 18 Alpine | Lightweight Node environment |

---

## 🐳 Dockerfile Deep Dive

### Multi-Stage Build Strategy

The Dockerfile uses **two-stage building** to optimize the final image size:

```dockerfile
#########################################
# Stage 1: Build (Builder)
#########################################
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build
```

#### **Stage 1 Analysis:**
- **Base Image**: `node:18-alpine` (~150MB)
  - Lightweight Alpine Linux with Node.js
  - Sufficient for building React apps
  
- **Why `npm ci` instead of `npm install`?**
  - `npm ci` (clean install) is deterministic
  - Installs exact versions from `package-lock.json`
  - Faster in CI/CD environments
  - Better reproducibility

- **Output**: Generates `dist/` folder with optimized production build

```dockerfile
#########################################
# Stage 2: Runtime (serve static)
#########################################
FROM node:18-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["serve", "-s", "dist", "-l", "3000"]
```

#### **Stage 2 Analysis:**
- **Fresh Image**: New Alpine image without build dependencies
- **Serve Package**: `serve` - lightweight HTTP server for static files
- **Copy Artifacts**: Only `dist/` folder (production bundle)
- **Port**: 3000 for the application
- **Command**: Runs `serve` with:
  - `-s` (single page app mode - redirect to index.html)
  - `-l 3000` (listen on port 3000)

### Build Image Optimization

```
Final Image Size Comparison:
┌──────────────────────────────────────┐
│ WITHOUT Multi-Stage Build: ~800MB    │
│ ├─ node_modules/                     │
│ ├─ src/                              │
│ ├─ build files                       │
│ └─ dependencies                      │
├──────────────────────────────────────┤
│ WITH Multi-Stage Build: ~120MB       │
│ ├─ node (runtime)                    │
│ ├─ serve binary                      │
│ └─ dist/ (optimized)                 │
└──────────────────────────────────────┘
```

**Benefits:**
- 🚀 **85% smaller** - Faster downloads & deployments
- 🔒 **More secure** - No build tools exposed in production
- 💾 **Lower storage** - Saves disk space on registries
- ⚡ **Better performance** - Less bloat in container

---

## 🔄 GitHub Actions Workflow

### Workflow Architecture

```yaml
name: docker build and test
on:
  push:
    branches:
      - Master
```

### Complete CI/CD Pipeline

```
Push to Master
     │
     ▼
┌─────────────────────────────┐
│  Checkout Repository        │
│  actions/checkout@v4        │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Login to Docker Hub        │
│  docker/login-action@v3     │
│  (uses GitHub Secrets)      │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Setup QEMU                 │
│  docker/setup-qemu-action   │
│  (multi-arch support)       │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Setup Docker Buildx        │
│  docker/setup-buildx-action │
│  (advanced building)        │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Build & Push Image         │
│  docker/build-push-action   │
│  → Docker Hub Registry      │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Image Ready!               │
│  3booda24/secure-nodejs:... │
└─────────────────────────────┘
```

### Workflow Step-by-Step

#### Step 1: Checkout Code
```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```
- Clones your repository code into the runner
- Provides all source files for building

#### Step 2: Docker Hub Authentication
```yaml
- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```
- Authenticates with Docker Hub using encrypted secrets
- Allows pushing images without exposing credentials
- **Security**: Never hardcode credentials!

#### Step 3: QEMU Setup (Multi-Architecture)
```yaml
- name: Set up QEMU
  uses: docker/setup-qemu-action@v3
```
- Enables building for multiple CPU architectures:
  - `linux/amd64` - Standard 64-bit Intel/AMD
  - `linux/arm64` - ARM processors (Apple Silicon, Raspberry Pi)
  - `linux/arm/v7` - 32-bit ARM

#### Step 4: Docker Buildx Setup
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
```
- Advanced Docker builder with features:
  - Better caching mechanisms
  - Multi-stage build optimization
  - BuildKit backend for performance

#### Step 5: Build & Push to Registry
```yaml
- name: Build and push
  uses: docker/build-push-action@v6
  with:
    push: true
    tags: 3booda24/secure-nodejs:latest
```
- Executes multi-stage Dockerfile build
- Pushes resulting image to Docker Hub
- Tags with `latest` for quick access

---

## ☸️ Kubernetes Deployment

### Deployment Architecture

```
┌─────────────────────────────────────────┐
│          AWS EKS Cluster                │
├─────────────────────────────────────────┤
│  Namespace: default                     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │    Deployment: react-app         │  │
│  │    Replicas: 2+                  │  │
│  ├──────────────────────────────────┤  │
│  │  Pod 1              Pod 2         │  │
│  │  ┌─────────────┐  ┌─────────────┐│  │
│  │  │ Container   │  │ Container   ││  │
│  │  │ Port: 3000  │  │ Port: 3000  ││  │
│  │  └─────────────┘  └─────────────┘│  │
│  └──────────────────────────────────┘  │
│               ▲                         │
│               │ (Selects pods)          │
│  ┌──────────────────────────────────┐  │
│  │    Service: LoadBalancer         │  │
│  │    Port: 80 → 3000               │  │
│  └──────────────────────────────────┘  │
│               ▲                         │
│               │ (Routes traffic)        │
└────────────────────────────────────────┘
               │
               ▼
        Internet Users
```

### Deployment YAML Configuration

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
      - name: react-app
        image: 3booda24/secure-nodejs:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
```

**Key Concepts:**
- **Replicas**: 2 instances for high availability
- **Image Pull**: Latest image from Docker Hub
- **Port Mapping**: Container port 3000 exposed
- **Resource Limits**: CPU and memory constraints
- **Self-Healing**: Kubernetes restarts failed pods

### Service Configuration

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: react-app-service
spec:
  type: LoadBalancer
  selector:
    app: react-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
```

**Service Features:**
- **LoadBalancer Type**: External IP for public access
- **Port Mapping**: HTTP 80 → Container 3000
- **Pod Selection**: Routes to all pods with label `app: react-app`
- **Load Distribution**: Automatic round-robin across pods

---

## 🏗️ Infrastructure as Code (Terraform)

### Terraform Architecture

```
terraform/
├── main.tf                 # Root configuration
└── modules/
    └── eks/
        ├── main.tf         # EKS cluster definition
        ├── outputs.tf      # Output values
        └── variables.tf    # Input variables
```

### Infrastructure Diagram

```
┌─────────────────────────────────────────────────┐
│            AWS Account                          │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │  VPC (Virtual Private Cloud)              │ │
│  ├───────────────────────────────────────────┤ │
│  │                                           │ │
│  │  ┌─────────────────────────────────────┐ │ │
│  │  │  EKS Control Plane                  │ │ │
│  │  │  (Managed by AWS)                   │ │ │
│  │  └─────────────────────────────────────┘ │ │
│  │                    │                      │ │
│  │                    ▼                      │ │
│  │  ┌─────────────────────────────────────┐ │ │
│  │  │  Worker Nodes (EC2 Instances)      │ │ │
│  │  │  ├─ Node 1 (t3.medium)             │ │ │
│  │  │  ├─ Node 2 (t3.medium)             │ │ │
│  │  │  └─ Auto Scaling Group             │ │ │
│  │  └─────────────────────────────────────┘ │ │
│  │                                           │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Terraform Configuration Example

```hcl
# terraform/modules/eks/main.tf

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name            = var.cluster_name
  role_arn        = aws_iam_role.eks_cluster_role.arn
  version         = var.kubernetes_version
  
  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

# Worker Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids
  
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
  
  instance_types = ["t3.medium"]
}
```

### Terraform Workflow

```
1. terraform init
   └─ Initialize working directory
   
2. terraform plan
   └─ Show what will be created/modified
   
3. terraform apply
   └─ Create actual AWS resources
   
Result: EKS cluster ready for Kubernetes deployments
```

---

## 🔑 Setup & Configuration

### Prerequisites

```bash
# Required tools
✓ Git
✓ Docker & Docker Desktop
✓ Node.js 18+
✓ npm or yarn
✓ kubectl
✓ AWS CLI v2
✓ Terraform 1.6.6+
```

### GitHub Secrets Configuration

Navigate to: **Settings → Secrets and variables → Actions**

Add these secrets:

| Secret Name | Value | Example |
|------------|-------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub username | `your-username` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | `dckr_pat_xxxxx` |
| `AWS_ACCESS_KEY_ID` | AWS access key | From IAM User |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | From IAM User |

### Docker Hub Token Creation

1. Go to [Docker Hub](https://hub.docker.com)
2. Account Settings → Security
3. Create New Access Token
4. Copy token to GitHub Secrets

### AWS Credentials Setup

1. Create IAM User with EKS permissions
2. Generate Access Keys
3. Add to GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

---

## 🚀 Local Development

### Initial Setup

```bash
# Clone repository
git clone https://github.com/abdelrahmanonline4/action-react-demo.git
cd action-react-demo

# Install dependencies
npm install

# Start development server
npm run dev
```

Open browser: `http://localhost:5173`

### Available Scripts

```bash
# Development server (hot reload)
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run tests
npm run test

# Build Docker image locally
docker build -t react-app:local .

# Run Docker container
docker run -p 3000:3000 react-app:local
```

---

## 📦 Deployment Guide

### Step 1: Configure Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Create AWS infrastructure
terraform apply -auto-approve
```

### Step 2: Update kubeconfig

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name my-eks-cluster-git
```

### Step 3: Deploy to Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services
```

### Step 4: Get Application URL

```bash
# Get LoadBalancer external IP
kubectl get service react-app-service

# Access via: http://<EXTERNAL-IP>
```

---

## 📊 Monitoring & Logs

### Check Deployment Status

```bash
# View pods
kubectl get pods -w

# Check pod details
kubectl describe pod <POD_NAME>

# View logs
kubectl logs <POD_NAME>
kubectl logs <POD_NAME> -f  # Follow logs

# Check service
kubectl get svc react-app-service
```

### Scale Application

```bash
# Scale to 5 replicas
kubectl scale deployment react-app --replicas=5

# Auto-scaling (requires metrics-server)
kubectl autoscale deployment react-app \
  --min=2 \
  --max=10 \
  --cpu-percent=80
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### 1. Docker Build Fails
```bash
# Problem: npm install times out
# Solution: Increase Docker memory and build timeout

# Clean Docker resources
docker system prune -a

# Rebuild with verbose output
docker build -t react-app . --progress=plain
```

#### 2. GitHub Actions Secrets Not Working
```bash
# Problem: Docker Hub login fails
# Solution: Verify secrets

# Check secrets exist (don't reveal values)
gh secret list

# Update token if expired
# Settings → Secrets → Update DOCKERHUB_TOKEN
```

#### 3. Kubernetes Pods Stuck in Pending
```bash
# Check node resources
kubectl describe nodes

# View pod events
kubectl describe pod <POD_NAME>

# Check Docker image exists
docker pull 3booda24/secure-nodejs:latest
```

#### 4. EKS Cluster Access Denied
```bash
# Verify kubeconfig
cat ~/.kube/config

# Update kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name my-eks-cluster-git

# Check AWS credentials
aws sts get-caller-identity
```

#### 5. Image Pull Errors
```bash
# Solution: Verify image exists on Docker Hub
docker pull 3booda24/secure-nodejs:latest

# Check image tag in deployment.yaml
kubectl get deployment react-app -o yaml | grep image
```

---

## 📁 Complete Project Structure

```
action-react-demo/
├── .github/
│   └── workflows/
│       └── test.yaml                 # CI/CD Pipeline
├── k8s/
│   ├── deployment.yaml               # Kubernetes Deployment
│   └── service.yaml                  # Kubernetes Service
├── terraform/
│   ├── main.tf                       # Terraform Root Config
│   └── modules/
│       └── eks/
│           ├── main.tf               # EKS Cluster Definition
│           ├── outputs.tf            # Output Variables
│           └── variables.tf          # Input Variables
├── src/
│   ├── components/
│   │   ├── HelpArea.jsx
│   │   ├── HelpBox.jsx
│   │   └── MainContent.jsx
│   ├── assets/
│   │   └── images/
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── public/
├── Dockerfile                        # Multi-stage Build
├── vite.config.js                    # Vite Config
├── package.json                      # Dependencies
├── package-lock.json                 # Lock File
├── index.html                        # HTML Entry
└── README.md                         # This File
```

---

## 🔗 Useful References

### Docker & Containerization
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Alpine Linux for Docker](https://hub.docker.com/_/alpine)

### Kubernetes
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### CI/CD
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Build Push Action](https://github.com/docker/build-push-action)

### Infrastructure as Code
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform EKS Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples)

### React & Vite
- [React Documentation](https://react.dev)
- [Vite Documentation](https://vitejs.dev)
- [Vite React Plugin](https://github.com/vitejs/vite-plugin-react)

---

## 📝 Environment Variables

Create a `.env` file for local development:

```bash
VITE_API_URL=http://localhost:3000
VITE_ENV=development
```

For production, configure in deployment.yaml:

```yaml
env:
  - name: NODE_ENV
    value: "production"
  - name: VITE_API_URL
    value: "https://your-domain.com"
```

---

## ✨ Features Summary

| Feature | Implementation | Status |
|---------|----------------|--------|
| React Frontend | Vite + React 18 | ✅ Complete |
| Docker Container | Multi-stage build | ✅ Complete |
| CI/CD Pipeline | GitHub Actions | ✅ Complete |
| Image Registry | Docker Hub | ✅ Complete |
| Kubernetes | K8s manifests | ✅ Complete |
| Cloud Infra | AWS EKS + Terraform | ✅ Complete |
| Auto-scaling | K8s HPA ready | ⚠️ Optional |
| Monitoring | Prometheus/Grafana | ⚠️ Optional |
| Service Mesh | Istio | ⚠️ Optional |

---

## 🎯 Next Steps

1. **Configure Secrets** - Add GitHub Secrets
2. **Push to Master** - Trigger CI/CD pipeline
3. **Verify Build** - Check Docker Hub for new image
4. **Deploy to EKS** - Apply Kubernetes manifests
5. **Monitor** - Check pod status and logs
6. **Scale** - Adjust replicas as needed

---

## 📧 Support & Contribution

- **Issues**: Open GitHub Issues for bugs
- **Discussions**: Use GitHub Discussions for questions
- **PRs**: Welcome for improvements

---

## 📄 License

This project is open source and available under the MIT License.

---

**Last Updated**: November 26, 2025  
**Maintainer**: [Abdelrahman Online](https://github.com/abdelrahmanonline4)  
**Repository**: [action-react-demo](https://github.com/abdelrahmanonline4/action-react-demo)


<img width="1912" height="549" alt="image" src="https://github.com/user-attachments/assets/9b319cae-21ac-463c-8bc4-145cfec2ba6d" />
