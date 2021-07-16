# worsica-kubernetes

This repository will contain the required files to build worsica on Kubernetes environment.
Deploying in Kubernetes is very different from depolying to the cloud. In kubernetes, there's no fixed local deployment. Kubernetes tries to deploy to somewhere, thus this requires to do some changes on the docker compose, such as losing the volume mount.

In this version:
- We provided modified copies of Dockerfiles for each WORSICA component (portal/intermediate/processing). The main changes are its name (worsica-kubernetes-XYZ instead of worsica-XYZ), and the repository download and installation during the build.
- Docker compose was adjusted to reflect on these changes. No longer is able to use volume mounts.

To do:
- Translating docker commands to kubectl?

Cheat sheet:
VM0 - Master
VM1 - worsica-frontend
VM2 - worsica-intermediate + nextcloud
VM3 - postgis
VM4 - rabbitmq

Installation:
1- On VM master, git clone this repository, then worsica-frontend, worsica-intermediate, worsica-processing
2- Run worsica_docker_build_scrpt_kubernetes.sh (as sudo), it will start building the essentials, then each component of WORSICA.

Update:
- If you have changed the files from the worsica-frontend/worsica-intermediate/worsica-processing services, you need to do "git pull" on their respective VM. 
- If you have changed any dockerfiles on worsica-kubernetes, you must build again.