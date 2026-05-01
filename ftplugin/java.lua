local jdtls = require 'jdtls'

-- 1. Root and Workspace
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
local root_dir = require('jdtls.setup').find_root(root_markers)
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

-- 2. Direct path to Mason packages (Avoids the 'nil' API error)
local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/'
local bundles = {
  vim.fn.glob(mason_path .. 'java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true),
}

-- Add Java Test bundles
local test_jars = vim.fn.glob(mason_path .. 'java-test/extension/server/*.jar', true)
if test_jars ~= '' then
  vim.list_extend(bundles, vim.split(test_jars, '\n'))
end

-- 3. Configuration
local config = {
  cmd = {
    'jdtls',
    '-data',
    workspace_dir,
    -- Ensure jdtls is in your PATH. If not, use the full path to the executable:
    -- vim.fn.stdpath("data") .. "/mason/bin/jdtls"
  },
  root_dir = root_dir,
  init_options = {
    bundles = bundles,
  },
  on_attach = function(client, bufnr)
    -- This links the Debugger to the LSP session
    jdtls.setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()

    -- Sync Kickstart highlighting
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(bufnr, client.id)
    end
  end,
}

-- 4. Start
jdtls.start_or_attach(config)
