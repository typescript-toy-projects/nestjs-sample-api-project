terraform {
    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "2.23.0"
        }
    }
}

provider "kubernetes" {
    config_path = "~/.kube/config"
}

# 1️⃣ Create namespace
resource "kubernetes_namespace" "nestjs" {
    metadata {
        name = "nestjs-app"
    }
    
    lifecycle {
        ignore_changes = [metadata]
    }
}

# 2️⃣ Deploy NestJS application (using your Docker image)
resource "kubernetes_deployment" "nestjs_deployment" {
    metadata {
        name      = "nestjs-deployment"
        namespace = kubernetes_namespace.nestjs.metadata[0].name
        labels = {
            app = "nestjs"
        }
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                app = "nestjs"
            }
        }

        template {
            metadata {
                labels = {
                    app = "nestjs"
                }
            }

            spec {
                container {
                    name  = "nestjs"
                    image = "changlee0216/nestjs-app:latest"
                    port {
                        container_port = 3000
                    }
                }
            }
        }
    }
    
    lifecycle {
        ignore_changes = [metadata]
    }
}

# 3️⃣ Create a service to expose it internally
resource "kubernetes_service" "nestjs_service" {
    metadata {
        name      = "nestjs-service"
        namespace = kubernetes_namespace.nestjs.metadata[0].name
    }

    spec {
        selector = {
            app = "nestjs"
        }

        port {
            port        = 80
            target_port = 3000
        }

        type = "LoadBalancer"
    }
    
    lifecycle {
        ignore_changes = [metadata]
    }
}

# 4️⃣ (Optional) Expose via Ingress for external access
resource "kubernetes_ingress_v1" "nestjs_ingress" {
    metadata {
        name      = "nestjs-ingress"
        namespace = kubernetes_namespace.nestjs.metadata[0].name
        annotations = {
            "kubernetes.io/ingress.class" = "nginx"
        }
    }

    spec {
        rule {
            host = "nestjs.local"
            http {
                path {
                    path = "/"
                    path_type = "Prefix"
                    backend {
                        service {
                            name = kubernetes_service.nestjs_service.metadata[0].name
                            port {
                                number = 80
                            }
                        }
                    }
                }
            }
        }
    }
    
    lifecycle {
        ignore_changes = [metadata]
    }
}
