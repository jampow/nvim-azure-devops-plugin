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
      await this.nvim.outWrite('Connected to Azure DevOps successfully!\n');
      return true;
    } catch (error) {
      await this.nvim.errWrite(`Failed to connect: ${error.message}\n`);
      return false;
    }
  }

  async listProjects() {
    if (!this.connection) {
      await this.nvim.errWrite('Not connected to Azure DevOps. Please connect first.\n');
      return;
    }

    try {
      const coreApi = await this.connection.getCoreApi();
      const projects = await coreApi.getProjects();
      
      await this.nvim.outWrite('\nAzure DevOps Projects:\n');
      await this.nvim.outWrite('======================\n');
      
      for (const project of projects) {
        await this.nvim.outWrite(`- ${project.name} (${project.id})\n`);
      }
    } catch (error) {
      await this.nvim.errWrite(`Failed to list projects: ${error.message}\n`);
    }
  }

  async listWorkItems(projectName) {
    if (!this.connection) {
      await this.nvim.errWrite('Not connected to Azure DevOps. Please connect first.\n');
      return;
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
        
        await this.nvim.outWrite('\nWork Items:\n');
        await this.nvim.outWrite('===========\n');
        
        for (const wi of workItems) {
          await this.nvim.outWrite(`#${wi.id} - ${wi.fields['System.Title']} [${wi.fields['System.State']}]\n`);
        }
      } else {
        await this.nvim.outWrite('No work items found.\n');
      }
    } catch (error) {
      await this.nvim.errWrite(`Failed to list work items: ${error.message}\n`);
    }
  }
}

// Initialize plugin when Neovim connects
(async () => {
  const nvim = await attach({ reader: process.stdin, writer: process.stdout });
  const plugin = new AzureDevOpsPlugin(nvim);

  // Register commands
  nvim.setHandler('azure_devops_connect', async ([orgUrl, token]) => {
    return await plugin.connect(orgUrl, token);
  });

  nvim.setHandler('azure_devops_list_projects', async () => {
    return await plugin.listProjects();
  });

  nvim.setHandler('azure_devops_list_work_items', async ([projectName]) => {
    return await plugin.listWorkItems(projectName);
  });

  await nvim.outWrite('Azure DevOps plugin loaded!\n');
})();
