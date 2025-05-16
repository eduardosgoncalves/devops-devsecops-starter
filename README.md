# DevOps + DevSecOps Starter

Projeto de exemplo que demonstra CI/CD com segurança integrada, deploy via Docker/Kubernetes, IaC com Terraform e monitoramento com Prometheus + Grafana.

## Ferramentas utilizadas
- GitHub Actions (CI/CD)
- Docker + Kubernetes (Deploy)
- Snyk + SonarQube + Gitleaks (Segurança)
- Terraform (Infraestrutura)
- Prometheus + Grafana (Monitoramento)

## Como executar localmente
```bash
cd app
docker build -t flask-app .
docker run -p 5000:5000 flask-app
```
