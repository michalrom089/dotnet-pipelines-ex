var target = Argument("target", "BuildAndTest");
var projectName = Argument("projectName", "");
var buildConfiguration = Argument("buildConfiguration", "Release");
var testOutputPath = Argument("testOutputPath", "test-output/");
var publishOutputPath = Argument("testOutputPath", "publish/");

var projectTestName = $"{projectName}.Tests";

Task("Clean")
    .Does(() => {
        void RemoveDirectory(string d) 
        {
            if (DirectoryExists(d))
            {
                CleanDirectory(d);
            }
        }
        RemoveDirectory("publish/");
        RemoveDirectory("test-output/");

        var projectDirectories = GetDirectories($"{projectName}/obj").Concat(GetDirectories($"{projectName}/bin"));
        var projectTestDirectories = GetDirectories($"{projectTestName}/obj").Concat(GetDirectories($"{projectTestName}/bin"));
        
        var directories = projectDirectories.Concat(projectTestDirectories);
                foreach(var dir in directories)
        {
            RemoveDirectory(dir.ToString());
        }
    });

Task("Restore")
    .Does(() =>
    {
        DotNetCoreRestore(projectName);
        DotNetCoreBuild(projectTestName);

    });

Task("Build")
    .Does(() => 
    {
        var settings = new DotNetCoreBuildSettings
        {
            Configuration = buildConfiguration,
        };

        DotNetCoreBuild(projectName, settings);
        DotNetCoreBuild(projectTestName, settings);
    });

Task("Test")
    .Does(() =>
    {
        var settings = new DotNetCoreTestSettings
        {
            Configuration = buildConfiguration,
            ResultsDirectory = testOutputPath,
            Logger = "trx;LogFileName=testresults.trx",
            NoBuild = true,
            NoRestore = true,
            ArgumentCustomization = args => args
                .Append("--collect").AppendQuoted("XPlat Code Coverage")
        };
        DotNetCoreTest(projectTestName, settings);
    });

Task("Publish")
    .Does(() =>
    {
        var settings = new DotNetCorePublishSettings
        {
            Configuration = buildConfiguration,
            OutputDirectory = publishOutputPath,
            NoBuild=true,
            NoRestore=true
        };
                    
        DotNetCorePublish(projectName, settings);
    });

Task("BuildAndTest")
    .IsDependentOn("Clean")
    .IsDependentOn("Restore")
    .IsDependentOn("Build")
    .IsDependentOn("Test");

Task("Release")
    .IsDependentOn("Clean")
    .IsDependentOn("Restore")
    .IsDependentOn("Build")
    .IsDependentOn("Test")
    .IsDependentOn("Publish");

RunTarget(target);