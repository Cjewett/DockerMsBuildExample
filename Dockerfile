# Generate base image from global.json
FROM mcr.microsoft.com/dotnet/sdk:7.0.102-bullseye-slim AS base

# Add the repository level requirements for building.
COPY ["global.json", "."]
COPY ["NuGet.config", "."]
COPY ["Directory.Build.props", "."]
COPY ["Directory.Packages.props", "."]

# Detect the most efficient dependency graph.
# Create the necessary stages based on dependency graph. 
# Split them out into separate Dockerfiles if needed but for the purpose of this example I'm just shoving them all into a single Dockerfile.

# Api.csproj and Extensions.csproj can be built in parallel off the rip.
# Console.csproj and Extensions.Tests.Unit rely on Extensions.csproj. Can be bulit in parallel after the extensions-build stage is complete.

FROM base AS api-restore
COPY ["src/Api/Api.csproj", "src/Api/"]
RUN dotnet restore "src/Api/Api.csproj"

FROM api-restore AS api-build
COPY ["src/Api/", "src/Api/"]
RUN dotnet build "src/Api/Api.csproj"

FROM base AS extensions-restore
COPY ["src/Extensions/Extensions.csproj", "src/Extensions/"]
RUN dotnet restore "src/Extensions/Extensions.csproj"

FROM extensions-restore AS extensions-build
COPY ["src/Extensions/", "src/Extensions/"]
RUN dotnet build "src/Extensions/Extensions.csproj"

FROM extensions-build AS console-restore
COPY ["src/Console/Console.csproj", "src/Console/"]
RUN dotnet restore "src/Console/Console.csproj"

FROM console-restore AS console-build
COPY ["src/Console/", "src/Console/"]
RUN dotnet build "src/Console/Console.csproj"

FROM extensions-build AS extensions-tests-unit-restore
COPY ["test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj", "test/Extensions.Tests.Unit/"]
RUN dotnet restore "test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj"

FROM extensions-tests-unit-restore AS extensions-tests-unit-build
COPY ["test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj", "test/Extensions.Tests.Unit/"]
RUN dotnet restore "test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj"

# Build base. 
# docker build -t base:latest --target base .

# The two commands below should be parallelizable.  
# docker build -t api-build:latest --target api-build .
# docker build -t extensions-build:latest --target extensions-build .

# The two commands below should be parallelizable as soon as the extensions-build docker build command above completes.
# docker build -t console-build:latest --target console-build .
# docker build -t extensions-tests-unit-build:latest --target extensions-tests-unit-build .

# All of the Dockerfiles that live in the directory of the applications can be built. All they really do is create an image to "deploy". For our company we have pretty standard use cases.
# Library and dotnet tool projects are pushed to NuGet repositories, so spinning up a container of those images results in an idempotent way to upload the packages.
# Application projects are pushed to the Docker registry and people can run them whenever they want.
# Test projects just run tests. Some volume mounting happening to extract results.

# docker build -t api:latest .
# docker build -t console:latest .
# docker build -t extensions:latest .
# docker build -t extensions-tests-unit:latest .