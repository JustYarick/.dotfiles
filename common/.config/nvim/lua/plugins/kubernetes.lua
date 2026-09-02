-- Kubernetes linting with kube-linter
-- Checks K8s manifests for best practices: missing resource limits, probes, security contexts, etc.
-- Note: kube-linter works on plain K8s YAML manifests, not Helm templates (.tpl files)
-- For Helm templates, helm-ls (already installed) provides LSP support

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "kube-linter" },
    },
  },
  -- Keybinding to run kube-linter on current file
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>cK", group = "kube-lint" },
      },
    },
  },
  -- Add keymap for kube-linter
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>cK",
        function()
          local file = vim.fn.expand("%:p")
          if file == "" then
            vim.notify("No file to lint", vim.log.levels.WARN)
            return
          end
          vim.fn.setqflist({}, "r", { title = "kube-linter" })
          vim.cmd("copen")
          local cmd = { "kube-linter", "lint", file, "--format", "plain" }
          vim.fn.jobstart(cmd, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = function(_, data)
              if not data then
                return
              end
              local items = {}
              for _, line in ipairs(data) do
                if line ~= "" then
                  table.insert(items, { text = line, type = "W" })
                end
              end
              if #items > 0 then
                vim.schedule(function()
                  vim.fn.setqflist(items, "a")
                end)
              end
            end,
            on_stderr = function(_, data)
              if not data then
                return
              end
              local items = {}
              for _, line in ipairs(data) do
                if line ~= "" then
                  table.insert(items, { text = line, type = "E" })
                end
              end
              if #items > 0 then
                vim.schedule(function()
                  vim.fn.setqflist(items, "a")
                end)
              end
            end,
            on_exit = function(_, code)
              vim.schedule(function()
                if code == 0 then
                  vim.notify("kube-linter: no issues found ✓", vim.log.levels.INFO)
                  vim.cmd("cclose")
                else
                  vim.notify("kube-linter: found issues, see quickfix", vim.log.levels.WARN)
                end
              end)
            end,
          })
        end,
        desc = "Kube-linter (current file)",
        ft = { "yaml", "yml" },
      },
    },
  },
}
