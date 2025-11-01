local M = {}
local ui = require('azure-devops.ui')

-- Configuration
M.config = {
  organization_url = '',
  personal_access_token = ''
}

-- Setup function for user configuration
function M.setup(opts)
  opts = opts or {}
  M.config.organization_url = opts.organization_url or M.config.organization_url
  M.config.personal_access_token = opts.personal_access_token or M.config.personal_access_token
end

-- Connect to Azure DevOps
function M.connect()
  if M.config.organization_url == '' or M.config.personal_access_token == '' then
    vim.notify('Please configure organization_url and personal_access_token', vim.log.levels.ERROR)
    return
  end
  
  ui.show_loading('Connecting to Azure DevOps...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, vim.g.azure_devops_channel, 'azure_devops_connect', 
      M.config.organization_url, M.config.personal_access_token)
    
    if success then
      ui.update_modal_content('Azure DevOps', {
        '',
        '  ✓ Connected successfully!',
        '',
        '  Press q or <Esc> to close'
      })
    else
      ui.update_modal_content('Azure DevOps', {
        '',
        '  ✗ Connection failed',
        '  ' .. tostring(result),
        '',
        '  Press q or <Esc> to close'
      })
    end
  end, 100)
end

-- List all projects
function M.list_projects()
  ui.show_loading('Fetching projects...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, vim.g.azure_devops_channel, 'azure_devops_list_projects')
    
    if success and result then
      local lines = { '' }
      for _, line in ipairs(vim.split(result, '\n')) do
        if line ~= '' then
          table.insert(lines, '  ' .. line)
        end
      end
      table.insert(lines, '')
      table.insert(lines, '  Press q or <Esc> to close')
      
      ui.update_modal_content('Azure DevOps Projects', lines)
    else
      ui.update_modal_content('Azure DevOps Projects', {
        '',
        '  ✗ Failed to fetch projects',
        '',
        '  Press q or <Esc> to close'
      })
    end
  end, 100)
end

-- List work items for a project
function M.list_work_items(project_name)
  if not project_name or project_name == '' then
    vim.notify('Please provide a project name', vim.log.levels.ERROR)
    return
  end
  
  ui.show_loading('Fetching work items for ' .. project_name .. '...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, vim.g.azure_devops_channel, 
      'azure_devops_list_work_items', project_name)
    
    if success and result then
      local lines = { '' }
      for _, line in ipairs(vim.split(result, '\n')) do
        if line ~= '' then
          table.insert(lines, '  ' .. line)
        end
      end
      table.insert(lines, '')
      table.insert(lines, '  Press q or <Esc> to close')
      
      ui.update_modal_content('Work Items - ' .. project_name, lines)
    else
      ui.update_modal_content('Work Items - ' .. project_name, {
        '',
        '  ✗ Failed to fetch work items',
        '',
        '  Press q or <Esc> to close'
      })
    end
  end, 100)
end

return M
