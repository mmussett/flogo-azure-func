# flogo-azure-func


1. Create .devcontainer directory
2. Create devcontainer.json file inside .devcontainer directory
3. Create .devcontainer/extensions directory


-- devcontainer.json


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

4. Copy flogo vsc extension 
5. CTRL+SHIFT+P -> DevContainers: Redeploy

#### Build Flogo Application


!!!!DO NOT FORGET TO SAVE BEFORE RUN!!!!



### Function App commands

func init --worker-runtime custom --docker
func new --name flogo-hello-world-func --template "HTTP trigger"



--- function.json

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

--- host.json

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

--- start.sh

#!/usr/bin/env sh
echo "Starting function..."
PORT=${FUNCTIONS_CUSTOMHANDLER_PORT} ./flogo-hello-world


--- Dockerfile

# FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice 
FROM mcr.microsoft.com/azure-functions/dotnet:4
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FLOGO_LOG_CONSOLE_STREAM=stdout

COPY . "/home/site/wwwroot"

--- local.settings.json

{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "custom",
    "AzureWebJobsStorage": "",
    "FLOGO_LOG_CONSOLE_STREAM": "stdout"
  }
}


### Function App Deployment

az login

az functionapp create --resource-group <<your-resource-group>> --os-type Linux --consumption-plan-location <<region>> --runtime custom --functions-version 4 --name <<your-azure-function-app-name>> --storage-account <<your-storage-account>>


zip -r app.zip  . -x "./.devcontainer/*"


az functionapp deployment source config-zip --resource-group  <<your-resource-group>> --name<<your-azure-function-app-name>> --src app.zip
