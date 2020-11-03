FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env

ARG PROJECT_NAME

ENV PROJECT_PATH ./${PROJECT_NAME}
ENV PROJECT_TESTS_PATH ./${PROJECT_NAME}.Tests

WORKDIR /webapp

# Copy csproj and restore as distinct layers
COPY ${PROJECT_PATH}/*.csproj ./${PROJECT_PATH}/
COPY ${PROJECT_TESTS_PATH}/*.csproj ./${PROJECT_TESTS_PATH}/

RUN dotnet restore ${PROJECT_PATH}
RUN dotnet restore ${PROJECT_TESTS_PATH}

# Copy everything else and build
COPY ${PROJECT_PATH}/* ${PROJECT_PATH}/
COPY ${PROJECT_TESTS_PATH}/* ${PROJECT_TESTS_PATH}/

RUN dotnet build ${PROJECT_PATH} -c Release -o out
RUN dotnet build ${PROJECT_TESTS_PATH} -c Release -o out-tests

# Run tests
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as test-env

ARG PROJECT_NAME
ENV PROJECT_TESTS_DLL="$PROJECT_NAME.Tests.dll"

WORKDIR /webapp/out-test/

COPY --from=build-env /webapp/out-tests .
RUN dotnet test ${PROJECT_TESTS_DLL} --logger "trx;LogFileName=testresults.trx"

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as publish-env

ARG PROJECT_NAME
ENV PROJECT_DLL="$PROJECT_NAME.dll"

WORKDIR /webapp
EXPOSE 80

COPY --from=build-env /webapp/out .

ENTRYPOINT dotnet $PROJECT_DLL
