FROM mcr.microsoft.com/azure-functions/dotnet:4
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FLOGO_LOG_CONSOLE_STREAM=stdout

COPY . "/home/site/wwwroot"