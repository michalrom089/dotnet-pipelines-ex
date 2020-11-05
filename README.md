# Azure Pipelines - Dotnet CI/CD

Contains multiple dotnet *hello-world* services and test projects. The CI/CD implementation is implemented using Azure DevOps pipelines with help of Cake and Docker.

Project structure:

```bash
├───Michal.Romanowski.Service1/
├───Michal.Romanowski.Service1.Tests/
├───Michal.Romanowski.Service2/
├───Michal.Romanowski.Service2.Tests/
├───Michal.Romanowski.Service3/
├───Michal.Romanowski.Service3.Tests/
├───azure-pipelines-service-build-test.yml #job template file used to build and test the solutions
├───azure-pipelines-service-push.yml #job template file used to push Docker image to the remote repository
├───azure-pipelines.yml # main pipeline
├───build.cake # build/test/release definition for dotnet projects
├───docker-compose.yml 
└───Dockerfile
```

## Azure Pipelines

Pipelines was divided into multiple templates to simplify the main pipeline file **azure-pipelines.yml**. The services are defined as an array parameter which is passed to the job templates used to build/push the solution. The main pipeline (**azure-pipelines**) executes the **azure-pipelines-service-build-test.yml** in order to build and test each of the solutions, then publishes tests results, lastly it builds and pushes Docker images to the remote repository using **azure-pipelines-service-push.yml** file.

## Docker

Docker image was divided into two stages: **build-env** nad **publish-env**. In the first stage the solution is builded against the official dotnet sdk image, then artifacts are copied to the publish stagem which uses lighter version of the dotnet image. The outcome is much smaller Docker image.
