FROM extension-tests-unit-build:latest AS final
ENTRYPOINT ["dotnet", "test", "test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj", "-c 'Release'", "--logger:'trx;LogFileName=Extensions.Tests.Unit.trx'", "/p:CollectCoverage=true", "/p:CoverletOutputFormat=cobertura"]
