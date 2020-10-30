FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env

ARG PROJECT_NAME

WORKDIR /webapp

# Copy csproj and restore as distinct layers
COPY ./${PROJECT_NAME}/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./${PROJECT_NAME}/* ./
RUN dotnet publish -c Release -o out


# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1

ARG PROJECT_NAME
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp
EXPOSE 80

COPY --from=build-env webapp/out .

ENTRYPOINT dotnet $PROJECT_DLL
