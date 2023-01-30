# DockerMsBuildExample

As part of our Docker journey we have used Docker to build our code. The resulting images also allow us to deploy in a few different yet standard (to our company) ways. The problem that we have run into is that it requires decent knowledge of how Docker works to introduce changes that would require an update to any of the Dockerfiles. It leads to a less than stellar developer experience in a world where a lot of our developers believe it should be automated. 

During that investigation we came across the Microsoft backed C# project to generate Docker images using MSBuild and felt it was a great way to approach the auto generation problem. Upon further investigation we found that it builds locally and copies the binaries into an image rather than building the code and creating a final stage for deployments. This repository is mainly outlining our point of view on why we want to keep building code in Docker and why we want to auto generate Dockerfiles.

## Project Dependency Tree
Below is the dependency structure of the projects in this repository.
* [Directory.Build.Props](./Directory.Build.props)
   [Directory.Packages.props](./Directory.Packages.props)
   [global.json](./global.json)
   [NuGet.config](./NuGet.config)
	* [Api.csproj](./src/Api/Api.csproj)
	* [Extensions.csproj](./src/Extensions/Extensions.csproj)
		* [Console.csproj](./src/Console/Console.csproj)
		* [Extensions.Tests.Unit.csproj](./test/Extensions.Tests.Unit/Extensions.Tests.Unit.csproj)

In an optimized build pipeline you would expect Api.csproj and Extensions.csproj to be built in parallel. As soon as Extensions.csproj is completed then Console.csproj and Extensions.Tests.Unit.csproj would be run in parallel.

## Problem
In Docker you have to copy all of the necessary files to perform these operations. In addition to that you also have to keep in mind the order of operations that you should introduce things or split them up into stages to make sure you take advantage of the Docker cache. You're almost always in a constant battle.

Making things easy results in inefficient caching.
Making things efficient results in a more difficult developer experience. 

We used to follow the make things efficient but make the developer experience difficult. Over time we swapped to make things easy and sacrifice efficient caching and builds. It doesn't feel like we should have to sacrifice in either direction though.

## Potential Path Forward
So how do we prevent sacrificing one of the two? We don't want our developers to have to worry about updating Dockerfiles if they make changes to the repository. We also want the significant caching efficiencies that Docker could provide to us (in additon to all of the other Docker benefits). 

Naturally we looked at the Solution file and how it gives us a graph of everything required to build. Further peeking into the Project (csproj) files gives you even more context into what is required to build. The combination of all of that information should allow us to auto generate Dockerfiles that take advantage of the caching, outputs Docker images that are applicable to our needs, and it completely negates the need for our developers to make changes to Dockerfiles. 

So do we want to expose a tool that autogenerates the Dockerfiles and check them in? We lean towards not doing that. Our developers shouldn't have to care about what the Dockerfiles look like unless they *really* need to know. So provide an easy way to reproduce but don't introduce a never ending merge conflict nightmare. We use Cake, so it would be easy to auto generate the Dockerfiles as the first step. It naturally provides the ability to only run that step if a developer wants to see what is going on under the hood.

How do we take advantage of the caching though? We leverage Nerdbank.GitVersioning which allows us to version every project that we have. We can also use the version for the Docker image tag. Pairing that with Docker's ability to pull and build on cache miss you put yourself in a position where your Docker registry could act as a distributed cache for your build. This is something that is sorely missing in the C# world to make sure larger repositories stay quick. 

Not only are the builds going to be quicker on average but you also naturally gain test impact analysis at the project level. If nothing about the test projects dependency hasn't changed then it should be possible to avoid running those tests altogether. We already have internal tooling to do this for our CI/CD pipeline today but gaining this by default would be great.

All that said this is what we believe to be possible. We still need to do a proof of concept, verify everything works as expected, etc. 

## Why Build in Docker?
#### Works on one OS, trouble with another
We've run into many different scenarios where building and testing on the same OS would give us more confidence. Some examples below:
* Builds on Windows. Runs correctly on Windows. Runs incorrectly on Linux.
* Builds on Windows. Fails to build on Mac.

It would simply be much nicer to perform separate builds for the different environments we want to support and we'd be able to do that with ease because all the host machines would need is Docker and the .NET SDK installed.

#### Best Practices
AFAIK building the code in Docker and using multi-stage builds to generate smaller images for the runtime application is best practice. We'd prefer to stay that route because when updates to technologies happen they keep people who follow best practices in mind. Those who do not are typically left in a tough position. 

#### Normalization
We want build normalization across all environments. If I'm a developer who needs to debug and reproduce how code made it to Production they should be able to do that.

#### DevOps Impact
It takes time to spin up new machines. Time to spin up the machine, time to install the software, time to verify and test the machine, etc. Being able to handle everything in Docker and reduce the number pre-requirements for a host machine down to Docker and the .NET SDK is huge for us. We can also take advantage of all of the Docker image security scanning available.