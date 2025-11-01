local M = {}

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
  
  vim.fn.rpcrequest(vim.g.azure_devops_channel, 'azure_devops_connect', 
    M.config.organization_url, M.config.personal_access_token)
end

-- List all projects
function M.list_projects()
  vim.fn.rpcrequest(vim.g.azure_devops_channel, 'azure_devops_list_projects')
end

-- List work items for a project
function M.list_work_items(project_name)
  if not project_name or project_name == '' then
    vim.notify('Please provide a project name', vim.log.levels.ERROR)
    return
  end
  
  vim.fn.rpcrequest(vim.g.azure_devops_channel, 'azure_devops_list_work_items', project_name)
end

return M
