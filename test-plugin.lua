-- Test script for Azure DevOps plugin
-- Run with: nvim -u test-plugin.lua

-- Add the plugin to runtimepath
vim.opt.rtp:prepend(vim.fn.getcwd())

-- Load the plugin
local azure = require('azure-devops')

-- Setup with your credentials (REPLACE THESE)
azure.setup({
  organization_url = 'https://dev.azure.com/your-organization',
  personal_access_token = 'your-token-here'
})

-- Wait a bit for plugin to start
vim.defer_fn(function()
  print('Plugin loaded! Try these commands:')
  print(':lua require("azure-devops").connect()')
  print(':lua require("azure-devops").list_projects()')
  print(':lua require("azure-devops").list_work_items("ProjectName")')
end, 1000)
