FROM mcr.microsoft.com/azure-functions/base:4.0-slim
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FLOGO_LOG_CONSOLE_STREAM=stdout

COPY . "/home/site/wwwroot"
