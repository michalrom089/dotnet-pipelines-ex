# Build runtime image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build-env

ARG PROJECT_NAME=Michal.Romanowski.Service1
ARG CAKE_VERSION="0.38.5"
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp

#restores
COPY build.cake .
COPY ${PROJECT_NAME} ${PROJECT_NAME}
COPY ${PROJECT_NAME}.Tests ${PROJECT_NAME}.Tests

# Install Cake and add it to Path
ENV PATH="/root/.dotnet/tools:${PATH}" 
RUN dotnet tool install --global Cake.Tool --version ${CAKE_VERSION}

RUN dotnet cake build.cake \
        --projectName=${PROJECT_NAME} \
        --publishOutputPath=./publish/ \
        --target=Release


# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as publish-env

ARG PROJECT_NAME=Michal.Romanowski.Service1
ARG BUILD_CONFIGURATION=Release
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp
EXPOSE 80

COPY --from=build-env webapp/publish/ .
ENTRYPOINT dotnet $PROJECT_DLL

