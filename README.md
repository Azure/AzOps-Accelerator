# AzOps Starter

## Configuration

The following script blocks and steps will prepare the repository for Push and Pull operating models.

### GitHub Actions

Run either the `bash` or `powershell` script blocks from within the root of repository.

```bash
# Create workflows directory
mkdir .github/workflows

# Copy actions templates
cp -R .github/templates/simple/ .github/workflows/

# Remove pipelines artefacts
rm -rf .pipelines/
```

```powershell
# Create workflows directory
New-Item -Path ./ -Name ".github/workflows" -ItemType Directory

# Copy actions templates
Copy-Item -Path ./.github/templates/simple/* -Destination ./.github/workflows/ -Recurse

# Remove pipelines
Remove-Item -Path ./.pipelines/ -Recurse -Force
```

After running the script blocks, the following repository secrets will need to be created.

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID

### Azure Pipelines

Run either the `bash` or `powershell` script blocks from within the root of repository.

```bash
# Copy templates to the root
cp -R .pipelines/templates/simple/ .pipelines/

# Edit the following files
.pipelines/pull.yml
.pipelines/push.yml

# Remove Actions
rm -rf .github/
```

```powershell
# Copy actions templates
Copy-Item -Path ./.pipelines/templates/simple/* -Destination ./.pipelines/ -Recurse

# Remove pipelines
Remove-Item -Path ./.github/ -Recurse -Force
```

After running the script blocks, the following pipeline variables will need to be created.

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
