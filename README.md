# Azure Container Instances with Aure Developer CLI

This repo contains a demo for Azure Platform as a Service components (Paas) which can be deployed to Azure with the [Aure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview). This template is part of the [Microsoft Trainer Demo Deploy Catalog](https://aka.ms/trainer-demo-deploy).

## ⬇️ Installation
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
    - When installing the above the following tools will be installed on your machine as well:
        - [GitHub CLI](https://cli.github.com)
        - [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [.NET Core 8 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

## 🚀 Usage
- Clone this repo
- Execute following command and follow instructions in CLI
```
azd up
```

- Use the [demo guide](demoguide.md) for inspiration for your demo

### ⚠️ Attention non-Windows users!
This scenario has been tested exclusively on Windows. Behavior on other platforms, such as Linux, may differ due to platform-specific factors. Specifically:
- The function app runs on Windows during local builds and deployments.
- Linux is currently unsupported due to these constraints.

If you are testing or deploying on a non-Windows platform, we encourage you to validate the templates, make any necessary modifications, and consider contributing your findings or improvements back to this repository.

## 💭 Feedback and Contributing
Feel free to create issues for bugs, suggestions or create a PR with new demo scenario's.