# Testing the Plugin

## Setup

1. Make sure Node.js and npm are installed
2. Install dependencies:
   ```bash
   npm install
   ```

## Testing in Neovim

### Option 1: Add to your init.lua

Add this to your `~/.config/nvim/init.lua`:

```lua
-- Add the plugin path
vim.opt.rtp:prepend('/home/gianpaulo/Projects/nvim-azure-plugin')

-- Setup the plugin
local azure = require('azure-devops')
azure.setup({
  organization_url = 'https://dev.azure.com/your-organization',
  personal_access_token = 'your-pat-token'
})
```

### Option 2: Test directly in Neovim

1. Start Neovim in the plugin directory:
   ```bash
   cd /home/gianpaulo/Projects/nvim-azure-plugin
   nvim
   ```

2. Run these commands:
   ```vim
   :set rtp+=.
   :lua local azure = require('azure-devops')
   :lua azure.setup({organization_url='https://dev.azure.com/your-org', personal_access_token='your-token'})
   :AzureConnect
   ```

3. After a moment, you should see a modal window with the connection status.

4. Try listing projects:
   ```vim
   :AzureProjects
   ```
   Or using Lua:
   ```vim
   :lua require('azure-devops').list_projects()
   ```

5. Try listing work items (replace with actual project name):
   ```vim
   :AzureWorkItems MyProject
   ```
   Or using Lua:
   ```vim
   :lua require('azure-devops').list_work_items('MyProject')
   ```

## Troubleshooting

### Plugin exits with code 1

Check if Node.js can run the plugin:
```bash
cd /home/gianpaulo/Projects/nvim-azure-plugin
node rplugin/node/azure-devops.js
```

It should wait for input (press Ctrl+C to exit). If it shows errors, there's a problem with the code.

### No modal appears

Check if the job started:
```vim
:lua print(require('azure-devops').job_id)
```

Should print a number (the job ID). If it's `nil`, the plugin didn't start.

### Check for errors

Enable more verbose output:
```vim
:messages
```

This shows any error messages from Neovim.
