# flogo-azure-func

This repository is a demonstration on how to:

1. Configure a visual studio code workspace for Dev Container use with TIBCO Flogo Plug-in.
2. Configure project for Azure Function.
3. Build and deploy Flogo application on Azure as a Function Application.


## Step 1 - Configure VSC workspace for Dev Container use with TIBCO Flogo Plugin

Create .devcontainer directory
Create devcontainer.json file inside .devcontainer directory
Create .devcontainer/extensions directory
Copy flogo vsc extension 
Edit the devcontainer.json using the following configuration

### devcontainer.json

```
{
    "name": "FlogoDevContainerAzFn",

    "image": "mcr.microsoft.com/devcontainers/go:1-1.23-bookworm",

    "features": {
        "ghcr.io/devcontainers/features/azure-cli":{},
        "ghcr.io/devcontainers/features/docker-in-docker":{},
        "ghcr.io/jlaundry/devcontainer-features/azure-functions-core-tools": {},
        "ghcr.io/azure/azure-dev/azd": {}
    },
    
    "forwardPorts": [
        8080,
        9999
    ],
    
    "customizations": {
        "vscode": {
            "extensions": [
                "golang.go",
                "ms-azuretools.vscode-docker",
                "ms-vscode.azurecli",
                "${containerWorkspaceFolder}/.devcontainer/extensions/flogo-vscode-linux-x64-1.2.0-836.vsix"
            ]
        }
    }

}
```

Use CTRL+SHIFT+P and DevContainers: Redeploy to launch into your Dev Container.



## Build Flogo Application

Build your TIBCO Flogo application.
Make sure your local runtime is linux x86_64



## Step 2 - Configure project for Azure Function. 

Run the following in your VSC terminal...

> **Note** Remember to replace **<<your-azure-function-name>>** value.

```
func init --worker-runtime custom --docker
func new --name <<your-azure-function-name>> --template "HTTP trigger"
```

2. Modify the following files...
   
### function.json

```
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [ "get" ],
      "route": "hello"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

### host.json

```
{
  "version": "2.0",
  "logging": {
    "fileLoggingMode": "always",
    "logLevel": {
      "default": "Trace",
      "Host.Results": "Trace",
      "Host.Aggregator": "Trace",
      "Function": "Trace"
    },
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "excludedTypes": "Request"
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  },
  "customHandler": {
    "description": {
      "defaultExecutablePath": "start.sh",
      "workingDirectory": "",
      "arguments": []
    },
    "enableForwardingHttpRequest": true
  },
  "extensions": {
    "http": {
      "routePrefix":""
    }
  }
}
```

### Dockerfile

```
# FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice 
FROM mcr.microsoft.com/azure-functions/dotnet:4
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FLOGO_LOG_CONSOLE_STREAM=stdout

COPY . "/home/site/wwwroot"
```

### local.settings.json

```
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "custom",
    "AzureWebJobsStorage": "",
    "FLOGO_LOG_CONSOLE_STREAM": "stdout"
  }
}
```


### start.sh

Create the start.sh file making sure to chmod +x

```
#!/usr/bin/env sh
echo "Starting function..."
PORT=${FUNCTIONS_CUSTOMHANDLER_PORT} ./flogo-hello-world
```


## Step 3 - Build and deploy Flogo application on Azure as a Function Application.

Run the following in your VSC terminal...

> **Note** Remember to replace <your-azure-function-app-name>,  <region>, <your-resource-group>, and <your-storage-account> values.


```
az login
az functionapp create --resource-group <<your-resource-group>> --os-type Linux --consumption-plan-location <<region>> --runtime custom --functions-version 4 --name <<your-azure-function-app-name>> --storage-account <<your-storage-account>>
zip -r app.zip  . -x "./.devcontainer/*"
az functionapp deployment source config-zip --resource-group  <<your-resource-group>> --name <<your-azure-function-app-name>> --src app.zip
```
