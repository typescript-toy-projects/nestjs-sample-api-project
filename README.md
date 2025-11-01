# NestJS Kubernetes Deployment Project

A complete NestJS application with Terraform-based Kubernetes deployment, automated CI/CD, and comprehensive development tooling.

## Project Structure

```
src/
├── main.ts              # Application entry point - bootstraps the NestJS app
├── app.module.ts        # Root module - defines dependency injection container
├── app.controller.ts    # HTTP request handler - defines API endpoints
├── app.service.ts       # Business logic layer - contains application logic
└── app.controller.spec.ts # Unit tests for the controller

test/
├── app.e2e-spec.ts      # End-to-end tests
└── jest-e2e.json        # E2E test configuration

Infrastructure:
├── main.tf              # Terraform Kubernetes deployment configuration
├── Dockerfile           # Docker container configuration
└── deploy.sh            # Automated deployment script

Configuration Files:
├── package.json         # Dependencies and npm scripts
├── tsconfig.json        # TypeScript compiler configuration
├── tsconfig.build.json  # Production build configuration
├── nest-cli.json        # NestJS CLI configuration
├── .eslintrc.js         # Code linting rules
└── .prettierrc          # Code formatting rules
```

## Architecture Overview

This project follows NestJS's modular architecture pattern:

- **Module** (`app.module.ts`) - Organizes components using `@Module` decorator
- **Controller** (`app.controller.ts`) - Handles HTTP requests using `@Controller` and `@Get` decorators
- **Service** (`app.service.ts`) - Contains business logic using `@Injectable` decorator
- **Main** (`main.ts`) - Bootstraps the application and starts the server

The application creates a REST API with endpoints:
- `GET /` - Returns "Hello World!"
- `GET /introduction/:name` - Returns personalized greeting

## Project Setup

```bash
$ npm install
```

## Local Development

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run Tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

This project is configured for Kubernetes deployment using Terraform with automated Docker image building and deployment.

### Prerequisites

- **Docker Desktop** with Kubernetes enabled
- **Docker Hub account** (for image registry)
- **kubectl** configured to access your cluster
- **Terraform** installed
- **Node.js and npm** for local development

### Quick Deployment (Automated)

**One-Command Deployment:**
```bash
# Login to Docker Hub first
$ docker login

# Run automated deployment script
$ ./deploy.sh
```

The script will:
1. Build Docker image locally
2. Push to Docker Hub registry
3. Deploy to Kubernetes using Terraform
4. Start port-forwarding to localhost:3000
5. Make app accessible at `http://localhost:3000`

### Manual Deployment Steps

**1. Setup Docker Hub**
```bash
# Login to Docker Hub
$ docker login

# Update image name in deploy.sh and main.tf with your username
# Replace 'changlee0216' with your Docker Hub username
```

**2. Build and Push Docker Image**
```bash
# Build the Docker image
$ docker build -t your-username/nestjs-app:latest .

# Push to Docker Hub
$ docker push your-username/nestjs-app:latest
```

**3. Deploy Infrastructure with Terraform**
```bash
# Initialize Terraform
$ terraform init

# Import existing namespace (if any)
$ terraform import kubernetes_namespace.nestjs nestjs-app

# Deploy to Kubernetes
$ terraform apply
```

**4. Access the Application**

**Option A: Port Forward (Automatic with deploy.sh)**
```bash
# Port forward to localhost
$ kubectl port-forward svc/nestjs-service 3000:80 -n nestjs-app
# Visit: http://localhost:3000
```

**Option B: Ingress (Domain-based)**
```bash
# Add to /etc/hosts:
$ echo "127.0.0.1 nestjs.local" >> /etc/hosts
# Visit: http://nestjs.local
```

### Verify Deployment

```bash
# Check pod status
$ kubectl get pods -n nestjs-app

# Check service details
$ kubectl get svc -n nestjs-app

# View application logs
$ kubectl logs -f deployment/nestjs-deployment -n nestjs-app

# Check all resources
$ kubectl get all -n nestjs-app
```

### Clean Up

```bash
# Stop port-forwarding (Ctrl+C)

# Destroy Terraform infrastructure
$ terraform destroy

# Remove Docker images (optional)
$ docker rmi nestjs-app:latest your-username/nestjs-app:latest
```

### Troubleshooting

**Image Pull Issues:**
- Ensure you're logged into Docker Hub: `docker login`
- Verify image exists: `docker images | grep nestjs-app`
- Check image name matches in main.tf

**Kubernetes Issues:**
- Reset Kubernetes: Docker Desktop → Settings → Kubernetes → Reset
- Check context: `kubectl config current-context`
- Verify cluster: `kubectl get nodes`

**Network Issues:**
- Docker Desktop → Settings → Resources → Network
- Uncheck "Use kernel networking for UDP"
- Uncheck "Enable host networking"

## Infrastructure (Terraform)

The project includes comprehensive Kubernetes deployment configuration via Terraform (`main.tf`):

### Infrastructure Components

- **Terraform Provider**: Uses Kubernetes provider v2.23.0 with local kubeconfig
- **Namespace**: Creates `nestjs-app` namespace for resource isolation
- **Deployment**: Deploys NestJS app using Docker image from Docker Hub
  - Single replica configuration
  - Exposes container port 3000
- **Service**: LoadBalancer service exposing port 80 → 3000
- **Ingress**: NGINX ingress for external access at `nestjs.local`

### Deployment Commands

```bash
# Initialize Terraform
$ terraform init

# Plan deployment
$ terraform plan

# Apply infrastructure
$ terraform apply

# Destroy infrastructure
$ terraform destroy
```

**Prerequisites**: Kubernetes cluster and kubectl configured locally.

## VS Code Integration

The project includes comprehensive VS Code configurations:

### Launch Configurations
- **NestJS (Development)** - Direct TypeScript debugging
- **Debug Jest Unit Tests** - Unit test debugging
- **Debug Jest E2E Tests** - E2E test debugging
- **Debug Current Test File** - Debug specific test files

### Tasks
- **npm: start:dev** - Development server with watch mode
- **npm: test** - Run unit tests
- **npm: test:e2e** - Run end-to-end tests

Access via `Ctrl+Shift+P` → "Tasks: Run Task" or Run and Debug panel.

## API Endpoints

- `GET /` - Returns "Hello World!"
- `GET /introduction/:name` - Returns "Hello! My name is {name}"

## Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## License

This project is [MIT licensed](LICENSE).