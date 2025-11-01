local M = {}
local ui = require('azure-devops.ui')

-- Configuration
M.config = {
  organization_url = '',
  personal_access_token = '',
  auto_connect = false  -- Set to true to connect automatically on startup
}

M.job_id = nil

-- Setup function for user configuration
function M.setup(opts)
  opts = opts or {}
  M.config.organization_url = opts.organization_url or M.config.organization_url
  M.config.personal_access_token = opts.personal_access_token or M.config.personal_access_token
  M.config.auto_connect = opts.auto_connect or M.config.auto_connect
  
  -- Start the Node.js plugin
  M.start_plugin()
  
  -- Auto-connect if enabled
  if M.config.auto_connect then
    -- Wait a bit for the plugin to be ready
    vim.defer_fn(function()
      M.connect_silent()
    end, 500)
  end
end

function M.start_plugin()
  if M.job_id then
    return
  end
  
  local plugin_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h:h') .. '/rplugin/node/azure-devops.js'
  
  M.job_id = vim.fn.jobstart({'node', plugin_path}, {
    rpc = true,
    on_exit = function(job_id, exit_code, event)
      M.job_id = nil
      if exit_code ~= 0 then
        vim.notify('Azure DevOps plugin exited with code ' .. exit_code, vim.log.levels.ERROR)
      end
    end
  })
  
  if M.job_id <= 0 then
    vim.notify('Failed to start Azure DevOps plugin', vim.log.levels.ERROR)
    M.job_id = nil
  end
end

-- Connect to Azure DevOps (with modal)
function M.connect()
  if not M.job_id then
    M.start_plugin()
    vim.defer_fn(function() M.connect() end, 500)
    return
  end
  
  if M.config.organization_url == '' or M.config.personal_access_token == '' then
    vim.notify('Please configure organization_url and personal_access_token', vim.log.levels.ERROR)
    return
  end
  
  ui.show_loading('Connecting to Azure DevOps...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, M.job_id, 'azure_devops_connect', 
      M.config.organization_url, M.config.personal_access_token)
    
    if success and type(result) == 'string' then
      ui.update_modal_content('Azure DevOps', {
        '',
        '  ✓ Connected successfully!',
        '',
        '  Press q or <Esc> to close'
      })
    elseif success and type(result) == 'table' and result.error then
      ui.update_modal_content('Azure DevOps', {
        '',
        '  ✗ Connection failed',
        '  ' .. tostring(result.error),
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

-- Connect silently (for auto-connect on startup, no modal)
function M.connect_silent()
  if not M.job_id then
    M.start_plugin()
    vim.defer_fn(function() M.connect_silent() end, 500)
    return
  end
  
  if M.config.organization_url == '' or M.config.personal_access_token == '' then
    return
  end
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, M.job_id, 'azure_devops_connect', 
      M.config.organization_url, M.config.personal_access_token)
    
    if success and type(result) == 'string' then
      vim.notify('Azure DevOps: Connected', vim.log.levels.INFO)
    elseif success and type(result) == 'table' and result.error then
      vim.notify('Azure DevOps: Connection failed - ' .. tostring(result.error), vim.log.levels.WARN)
    end
  end, 100)
end

-- List all projects
function M.list_projects()
  if not M.job_id then
    vim.notify('Plugin not started. Please run setup() first.', vim.log.levels.ERROR)
    return
  end
  
  ui.show_loading('Fetching projects...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, M.job_id, 'azure_devops_list_projects')
    
    if success and type(result) == 'string' then
      local lines = { '' }
      for _, line in ipairs(vim.split(result, '\n')) do
        if line ~= '' then
          table.insert(lines, '  ' .. line)
        end
      end
      table.insert(lines, '')
      table.insert(lines, '  Press q or <Esc> to close')
      
      ui.update_modal_content('Azure DevOps Projects', lines)
    elseif success and type(result) == 'table' and result.error then
      ui.update_modal_content('Azure DevOps Projects', {
        '',
        '  ✗ Failed to fetch projects',
        '  ' .. tostring(result.error),
        '',
        '  Press q or <Esc> to close'
      })
    else
      ui.update_modal_content('Azure DevOps Projects', {
        '',
        '  ✗ Failed to fetch projects',
        '  ' .. tostring(result),
        '',
        '  Press q or <Esc> to close'
      })
    end
  end, 100)
end

-- List work items for a project
function M.list_work_items(project_name)
  if not M.job_id then
    vim.notify('Plugin not started. Please run setup() first.', vim.log.levels.ERROR)
    return
  end
  
  if not project_name or project_name == '' then
    vim.notify('Please provide a project name', vim.log.levels.ERROR)
    return
  end
  
  ui.show_loading('Fetching work items for ' .. project_name .. '...')
  
  vim.defer_fn(function()
    local success, result = pcall(vim.fn.rpcrequest, M.job_id, 
      'azure_devops_list_work_items', project_name)
    
    if success and type(result) == 'string' then
      local lines = { '' }
      for _, line in ipairs(vim.split(result, '\n')) do
        if line ~= '' then
          table.insert(lines, '  ' .. line)
        end
      end
      table.insert(lines, '')
      table.insert(lines, '  Press q or <Esc> to close')
      
      ui.update_modal_content('Work Items - ' .. project_name, lines)
    elseif success and type(result) == 'table' and result.error then
      ui.update_modal_content('Work Items - ' .. project_name, {
        '',
        '  ✗ Failed to fetch work items',
        '  ' .. tostring(result.error),
        '',
        '  Press q or <Esc> to close'
      })
    else
      ui.update_modal_content('Work Items - ' .. project_name, {
        '',
        '  ✗ Failed to fetch work items',
        '  ' .. tostring(result),
        '',
        '  Press q or <Esc> to close'
      })
    end
  end, 100)
end

return M
