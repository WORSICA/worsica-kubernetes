# worsica-kubernetes

This repository will contain the required files to build worsica on Kubernetes environment.
Deploying in Kubernetes is very different from depolying to the cloud. In kubernetes, there's no fixed local deployment. Kubernetes tries to deploy to somewhere, thus this requires to do some changes on the docker compose, such as losing the volume mount.

In this version:
- We provided modified copies of Dockerfiles for each WORSICA component (portal/intermediate/processing). The main changes are its name (worsica-kubernetes-XYZ instead of worsica-XYZ), and the repository download and installation during the build.
- Docker compose was adjusted to reflect on these changes. No longer is able to use volume mounts.

---------------
Cheat sheet:
VM0 - Master
VM1 - worsica-frontend
VM2 - worsica-intermediate + nextcloud
VM3 - postgis
VM4 - rabbitmq

---------------
Installation:
1- On VM master, git clone this repository, then worsica-cicd, worsica-frontend, worsica-intermediate, worsica-processing
2- Run worsica_docker_build_scrpt_kubernetes.sh (as sudo), it will start building the essentials, then each component of WORSICA and the respective worsica-kubernetes docker counterparts (for the COPY).

Update:
- If you have changed the files from the worsica-frontend/worsica-intermediate/worsica-processing services, or changed any dockerfiles on worsica-kubernetes, always run the "worsica_update_scrpt.sh *COMPONENT*". 

---------------
Scripts:
worsica_docker_build_scrpt_kubernetes.sh *--no-cache*
Build only the dockers. --no-cache forces the docker essentials to be rebuild from scratch

worsica_update_scrpt.sh *COMPONENT*
Update the worsica components with the latest git releses using git pull. Then start building and deploying the dockers using Kubernetes. This script is much easier than doing manually. Use this if you have already installed beforehand.
COMPONENT is the component name you want to update. 
Valid COMPONENT names are: essentials, frontend, intermediate, processing.
If you do not give any name, it will start updating all the components.

----------------
Important notes:
Create migration folders befirehand on worsica_api (worsica-intermediate) and worsica_portal (worsica-frontend), to be possible mounting the PVC for migration file persistent storage on Kubernetes.