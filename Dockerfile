# Build runtime image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build-env

ARG PROJECT_NAME=Michal.Romanowski.Service1
ARG BUILD_CONFIGURATION=Release
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp

#restores
COPY ${PROJECT_NAME}/*.csproj ./${PROJECT_NAME}/
RUN dotnet restore ${PROJECT_NAME}

# build and publish
COPY ${PROJECT_NAME}/* ./${PROJECT_NAME}/
RUN dotnet publish ${PROJECT_NAME} -c ${BUILD_CONFIGURATION}


# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as publish-env

ARG PROJECT_NAME=Michal.Romanowski.Service1
ARG BUILD_CONFIGURATION=Release
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp
EXPOSE 80

COPY --from=build-env webapp/${PROJECT_NAME}/bin/${BUILD_CONFIGURATION}/netcoreapp3.1/publish/ .

ENTRYPOINT dotnet $PROJECT_DLL

