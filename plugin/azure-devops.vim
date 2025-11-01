" Neovim plugin for Azure DevOps integration
if exists('g:loaded_azure_devops')
  finish
endif
let g:loaded_azure_devops = 1

" Set the path to the Node.js script
let s:script_path = expand('<sfile>:p:h:h') . '/rplugin/node/azure-devops.js'

" Commands
command! AzureDevOpsConnect :call AzureDevOpsConnect()
command! AzureDevOpsListProjects :call AzureDevOpsListProjects()
command! AzureDevOpsListWorkItems :call AzureDevOpsListWorkItems()

function! AzureDevOpsConnect()
  echo "Connecting to Azure DevOps..."
endfunction

function! AzureDevOpsListProjects()
  echo "Fetching projects..."
endfunction

function! AzureDevOpsListWorkItems()
  echo "Fetching work items..."
endfunction
