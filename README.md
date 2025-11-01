# nvim-azure-plugin

A Neovim plugin to communicate with Azure DevOps using Node.js.

## Features

- Connect to Azure DevOps organizations
- List projects
- List work items
- Built with Node.js and the official Azure DevOps API

## Requirements

- Neovim 0.5+
- Node.js 14+
- npm

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'yourusername/nvim-azure-plugin',
  run = 'npm install'
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'yourusername/nvim-azure-plugin',
  build = 'npm install',
  config = function()
    require('azure-devops').setup({
      organization_url = 'https://dev.azure.com/your-organization',
      personal_access_token = 'your-pat-token'
    })
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'yourusername/nvim-azure-plugin', { 'do': 'npm install' }
```

## Configuration

Configure the plugin with your Azure DevOps credentials:

```lua
require('azure-devops').setup({
  organization_url = 'https://dev.azure.com/your-organization',
  personal_access_token = 'your-personal-access-token'
})
```

### Getting a Personal Access Token

1. Go to Azure DevOps
2. Click on User Settings → Personal Access Tokens
3. Create a new token with appropriate permissions (Work Items: Read, Project and Team: Read)

## Usage

### Lua API

```lua
local azure = require('azure-devops')

-- Connect to Azure DevOps
azure.connect()

-- List all projects
azure.list_projects()

-- List work items for a specific project
azure.list_work_items('ProjectName')
```

### Vim Commands

```vim
:AzureDevOpsConnect
:AzureDevOpsListProjects
:AzureDevOpsListWorkItems
```

## Development

### Project Structure

```
nvim-azure-plugin/
├── plugin/              # Vim plugin files
│   └── azure-devops.vim
├── rplugin/            # Remote plugin
│   └── node/
│       └── azure-devops.js
├── lua/                # Lua modules
│   └── azure-devops/
│       └── init.lua
├── doc/                # Documentation
├── package.json        # Node.js dependencies
└── README.md
```

### Installing Dependencies

```bash
npm install
```

### Testing

After installation, start Neovim and run:

```vim
:UpdateRemotePlugins
```

Then restart Neovim to load the plugin.

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
