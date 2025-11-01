" Neovim plugin for Azure DevOps integration
if exists('g:loaded_azure_devops')
  finish
endif
let g:loaded_azure_devops = 1

" Commands
command! AzureDevOpsConnect lua require('azure-devops').connect()
command! AzureDevOpsListProjects lua require('azure-devops').list_projects()
command! -nargs=1 AzureDevOpsListWorkItems lua require('azure-devops').list_work_items(<f-args>)

" Shorter aliases
command! AzureConnect lua require('azure-devops').connect()
command! AzureProjects lua require('azure-devops').list_projects()
command! -nargs=1 AzureWorkItems lua require('azure-devops').list_work_items(<f-args>)
