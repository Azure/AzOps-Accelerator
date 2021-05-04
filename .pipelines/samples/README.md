# Samples

## Multi-Environment

The Multi-Environment sample demonstrates how to use AzOps where segregation between management groups is required.
This approach would fit where there are two Enterprise Scale reference implementations (canary and production).

This is most suited to enterprises with *robust change management processes* governing changes to the production management group hierarchy. The Canary environment can be independently used to author and test deployments before taking the same Arm templates into the Production environment.

![Canary and Prod Management Groups](ManagementGroupsCanary.png)

### Changes

The key changes over the core AzOps Accelerator pipelines are;

1. Two sets of Push and Pull pipelines
1. Two configuration files for each pair of pipelines
1. Use of [Azure DevOps templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) to eliminate duplication of code between the pipelines
1. Two sets of branches used to capture changes from each of the environments
1. Introduction of Pipeline Environments to enable Environment Approvers

### Implementation Notes

#### Service Principals

It's advised to use different Service Principals to access each environment. Each Service Principal will need Owner access for just the Management Group scope it needs to augment change in. These would be stored in two different Variable Groups, named according to the environment (AZURECREDENTIALS_CANARY and AZURECREDENTIALS_PROD).

#### Environment names

The terms Canary and Prod are embedded throughout the sample files. Where your Reference Implementation Prefix is different, these replacements will need to be made.

## Subscription-Vend

The [Subscription-Vend pipeline](Subscription-Vend/VendEmptySubscription.yml)  demonstrates governed Subscription Creation. It leverages the AzOps deployment capability, through raising a Pull Request on the main branch with a new Arm template dropped at the correct folder scope.

### RBAC Permissions

Ensure you've read [this guide](https://github.com/Azure/Enterprise-Scale/wiki/Create-Landingzones#create-landing-zones-subscription-using-azops), and granted the appropriate permissions to the service principal in order to create subscriptions.

### Pipeline

The pipeline performs the following actions;

1. Creates a new branch
1. Composes a new Arm template, combining the reference template with the provided variable values
1. Adds, commits and pushes the change to the new branch
1. Creates a pull request

#### Initiating the Pipeline from CLI

The pipeline can be initiated from the [Azure DevOps CLI](https://docs.microsoft.com/en-us/cli/azure/devops), therefore enabling easy integration  with existing automation used in your enterprise.

```azurepowershell
az login --use-device-code
az pipelines run --org https://dev.azure.com/ORG -p PROJECT --name VendEmptySubscription --variables ManagementGroup=canary-sandboxes SubscriptionName=My-New-Sub Environment=canary
```

### Arm Template

The [sample Arm template](Subscription-Vend/CreateEmptySubscription.json) creates an empty subscription, with no resources or tags. The subscription will be placed in the appropriate Management Group. Other example Arm templates that can be leveraged for subscription creation can be found [here](https://github.com/Azure/Enterprise-Scale/tree/main/examples/landing-zones).

### Security

By using a pipeline, authentication with the Git repository is simple and reuses the Agent authentication token.
No Azure Credentials are leveraged, because the scope of what the pipeline does is focussed on making a Pull Request.