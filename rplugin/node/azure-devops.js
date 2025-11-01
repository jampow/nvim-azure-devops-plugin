const { attach } = require('neovim');
const azdev = require('azure-devops-node-api');

class AzureDevOpsPlugin {
  constructor(nvim) {
    this.nvim = nvim;
    this.connection = null;
  }

  async connect(organizationUrl, personalAccessToken) {
    try {
      const authHandler = azdev.getPersonalAccessTokenHandler(personalAccessToken);
      this.connection = new azdev.WebApi(organizationUrl, authHandler);
      return 'Connected to Azure DevOps successfully!';
    } catch (error) {
      throw new Error(`Failed to connect: ${error.message}`);
    }
  }

  async listProjects() {
    if (!this.connection) {
      throw new Error('Not connected to Azure DevOps. Please connect first.');
    }

    try {
      const coreApi = await this.connection.getCoreApi();
      const projects = await coreApi.getProjects();
      
      let output = '';
      
      for (const project of projects) {
        output += `📁 ${project.name}\n`;
        if (project.description) {
          output += `   ${project.description}\n`;
        }
        output += `   ID: ${project.id}\n\n`;
      }
      
      return output || 'No projects found.';
    } catch (error) {
      throw new Error(`Failed to list projects: ${error.message}`);
    }
  }

  async listWorkItems(projectName) {
    if (!this.connection) {
      throw new Error('Not connected to Azure DevOps. Please connect first.');
    }

    try {
      const witApi = await this.connection.getWorkItemTrackingApi();
      const wiql = {
        query: `SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.TeamProject] = '${projectName}' ORDER BY [System.ChangedDate] DESC`
      };
      
      const result = await witApi.queryByWiql(wiql);
      
      if (result.workItems && result.workItems.length > 0) {
        const ids = result.workItems.map(wi => wi.id);
        const workItems = await witApi.getWorkItems(ids);
        
        let output = '';
        
        for (const wi of workItems) {
          const state = wi.fields['System.State'];
          const stateIcon = state === 'Active' ? '🔵' : state === 'Closed' ? '✅' : '⚪';
          output += `${stateIcon} #${wi.id} - ${wi.fields['System.Title']}\n`;
          output += `   State: ${state}\n`;
          if (wi.fields['System.AssignedTo']) {
            output += `   Assigned: ${wi.fields['System.AssignedTo'].displayName}\n`;
          }
          output += '\n';
        }
        
        return output;
      } else {
        return 'No work items found.';
      }
    } catch (error) {
      throw new Error(`Failed to list work items: ${error.message}`);
    }
  }
}

// Main entry point
if (require.main === module) {
  const nvim = attach({ reader: process.stdin, writer: process.stdout });
  const azurePlugin = new AzureDevOpsPlugin(nvim);

  // Handle RPC requests
  nvim.channelId.then((channelId) => {
    // Plugin is ready
  }).catch((err) => {
    console.error('Failed to get channel ID:', err);
  });

  // Listen for requests using nvim.on
  nvim.on('request', async (method, args, resp) => {
    try {
      switch (method) {
        case 'azure_devops_connect':
          const result = await azurePlugin.connect(args[0], args[1]);
          resp.send(result);
          break;
        case 'azure_devops_list_projects':
          const projects = await azurePlugin.listProjects();
          resp.send(projects);
          break;
        case 'azure_devops_list_work_items':
          const workItems = await azurePlugin.listWorkItems(args[0]);
          resp.send(workItems);
          break;
        default:
          resp.send({ error: 'Unknown method: ' + method }, true);
      }
    } catch (error) {
      resp.send({ error: error.message }, true);
    }
  });

  nvim.on('disconnect', () => {
    process.exit(0);
  });
}
