This repository contains a production-ready containerized backend application deployed to Kubernetes using Helm and GitLab CI/CD.

## PROJECT STRUCTURE

.
├── backend/                    # Java backend service
│   ├── Dockerfile              # Container build definition
│   ├── pom.xml                 # Maven configuration
│   ├── src/                    # Application source code
│   ├── chart/                  # Helm chart for Kubernetes deployment
│   │   └── tekmetric-backend/  # Backend Helm chart
│   └── frontend/               # (Optional) Frontend assets
│
├── qa/                          # QA-related resources (tests, configs)
├── ml/                          # ML-related components (reserved/future)
├── sre/                         # SRE / infrastructure-related assets
│
├── .gitlab-ci.yml               # GitLab CI/CD pipeline definition
├── .gitignore
└── README.md

Assignment Overview – What Was Done

For this assignment, I focused on taking a simple backend application and productionizing it using containerization, Kubernetes, and automated deployment practices.
The goal was not just to make the application run, but to deploy it in a way that is reliable, secure, observable, and safe to operate in a real Kubernetes environment.

##  Scope of Work
1. Containerized the Backend Application
        Created a Docker image for the Java backend service
        Ensured the application exposes a clear health endpoint (/api/welcome)
        Used immutable image tags to support reproducible deployments

2. Deployed the Application to Kubernetes
    Defined Kubernetes resources for:
        Deployment
        Service (ClusterIP)
        Ensured proper labeling and selectors for service-to-pod routing

3. Implemented Health Checks for Reliability
        Added startup, readiness, and liveness probes
        Startup probe protects slow application initialization
        Readiness probe ensures traffic is only routed to healthy pods
        Liveness probe enables automatic recovery from unhealthy states
        These checks ensure the application behaves correctly during startup, runtime, and failure scenarios.

4. Added Resource Management
        Defined CPU and memory requests and limits
        Ensured predictable scheduling and stability
        Prevented resource exhaustion and noisy-neighbor issues
        Made the deployment compatible with managed platforms such as GKE Autopilot

5. Applied Security Best Practices
        Enforced non-root container execution
        Disabled privilege escalation
        Dropped unnecessary Linux capabilities
        default seccomp profile for syscall restriction
        This reduces the container’s attack surface while maintaining functionality.

6. Enabled Horizontal Scaling
        Configured a Horizontal Pod Autoscaler (HPA)
        Allowed the application to scale automatically based on CPU and memory usage
        Set reasonable minimum and maximum replica counts
        This allows the service to handle variable load without manual intervention.

7. Automated Build and Deployment
        Built and pushed container images via CI/CD
        Deployed to Kubernetes using Helm with atomic upgrades
        Ensured failed deployments automatically roll back

----------------
## Containerization

The backend service is containerized using Docker.

Build locally:
docker build -t tekmetric-backend:local backend/

Run locally
docker run -p 8080:8080 tekmetric-backend:local
curl http://localhost:8080/api/welcome 

----------------
##  Kubernetes & Helm

This configuration provides:

Deployment:
        Runs the backend pods with defined CPU and memory limits
        Includes startup, readiness, and liveness probes for safe startup and self-healing
        Applies secure container defaults (non-root, no privilege escalation, dropped capabilities)

Service (ClusterIP)
        Exposes the backend internally
        Routes traffic only to healthy pods

Horizontal Pod Autoscaler (HPA)
        Scales pods automatically based on CPU and memory usage

Deployment Behavior
        Uses helm upgrade --install with --atomic and --wait for safe rollouts

## Observability (Prometheus & Grafana)

Cluster-level observability is provided using Prometheus and Grafana,
deployed via the kube-prometheus-stack Helm chart.

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

This setup provides:
- Pod and node CPU/memory metrics
- HPA scaling visibility
- Container restarts and health status
- Kubernetes resource monitoring

The backend service relies on Kubernetes-native health probes and
resource metrics, which are automatically collected by Prometheus.

## CI/CD Pipeline

This project includes a minimal but production-oriented CI/CD pipeline that automates building, packaging, and deploying the backend application to Kubernetes.
The CI/CD pipeline performs the following steps:

Build
        Builds a Docker image for the backend application
        Tags the image using an immutable identifier (commit SHA)
        Pushes the image to a container registry

Deploy (Development)
        Deploys the application to a Kubernetes cluster using Helm
        Uses atomic upgrades to ensure failed deployments are rolled back automatically
        Waits for the rollout to complete before finishing the job

Deploy (Production)
        Triggered manually
        Deploys the same artifact to a production namespace
        Uses the same Helm chart and configuration to ensure consistency