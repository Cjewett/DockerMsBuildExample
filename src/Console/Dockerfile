FROM console-build:latest AS publish
ARG VERSION
RUN dotnet pack "src/Console/Console.csproj" -c "Release" -o "/publish" --no-restore --no-build -p:PackageVersion="$VERSION"

FROM mcr.microsoft.com/dotnet/sdk:7.0.102-bullseye-slim AS final
WORKDIR /app
COPY --from=publish /publish .
ENTRYPOINT ["dotnet", "nuget", "push", "*.nupkg", "--source", "https://nuget", "--skip-duplicate"]
