# 🚀 BUILD_PROJECT – Static Website CI/CD Pipeline with Jenkins & Monitoring

This project demonstrates a complete CI/CD pipeline setup to deploy a **simple static website** using **Jenkins**. It includes build and deploy scripts, containerized workflow using Docker, and real-time uptime monitoring using **Uptime Kuma**.

---

## 🌐 Live URLs

- 🔵 **Website**: [https://app.demoprojectbc1.com:447/](https://app.demoprojectbc1.com:447/)
- ⚙️ **Jenkins**: [https://jenkins.demoprojectbc1.com/job/build-project/](https://jenkins.demoprojectbc1.com/job/build-project/)
- 📈 **Monitoring (Uptime Kuma)**: [https://monitor_app.demoprojectbc1.com:448/](https://monitor_app.demoprojectbc1.com:448/)

---

## 📁 Repository Structure

```bash
BUILD_PROJECT/
│
├── build/
│   ├── AlertAppDown.jpeg        # Screenshot of downtime alert
│   ├── AlertAppUp.jpeg          # Screenshot of uptime recovery
│   ├── build.sh                 # Build script
│   ├── deploy.sh               # Deployment script
│   ├── DeployedSite.jpeg        # Screenshot of deployed site
│   └── MonitoringSetup.jpeg     # Uptime Kuma dashboard
│
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # Dockerfile to build the app container
├── Jenkinsfile                 # CI/CD pipeline definition for Jenkins
│
├── EC2Config.png               # EC2 instance configuration screenshot
├── EC2SGSettings.jpeg          # Security Group settings screenshot
├── JenkinsConfig.png           # Jenkins setup screenshot
├── ECRRepos.jpeg               # (Optional) ECR repository setup
