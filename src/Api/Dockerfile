FROM api-build:latest AS publish
RUN dotnet publish "src/Api/Api.csproj" -c "Release" -o "/publish" --no-restore --no-build

FROM  mcr.microsoft.com/dotnet/aspnet:7.0.2-bullseye-slim AS final
WORKDIR /app
COPY --from=publish /publish .
ENTRYPOINT ["dotnet", "Api.csproj"]
