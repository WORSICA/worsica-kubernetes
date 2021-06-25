# worsica-kubernetes

This repository will contain the required files to build worsica on Kubernetes environment.
Deploying in Kubernetes is very different from depolying to the cloud. In kubernetes, there's no fixed local deployment. Kubernetes tries to deploy to somewhere, thus this requires to do some changes on the docker compose, such as losing the volume mount.

In this version:
- We provided modified copies of Dockerfiles for each WORSICA component (portal/intermediate/processing). The main changes are its name (worsica-kubernetes-XYZ instead of worsica-XYZ), and the repository download and installation during the build.
- Docker compose was adjusted to reflect on these changes. No longer is able to use volume mounts.

To do:
- Translating docker commands to kubectl?

Installation:
- Git clone or download this repository to somewhere.
- Run worsica_docker_build_scrpt_kubernetes.sh (as sudo), it will start building the essentials, then each component of WORSICA.