-- Lua Language Server for non-nvim Lua files (system configs, scripts, etc.)
-- lazydev.nvim (already installed) handles nvim-specific Lua intelligence

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              completion = { callSnippet = "Replace" },
              diagnostics = {
                -- don't flag vim as unknown when editing non-nvim lua
                -- lazydev.nvim handles nvim globals separately
                disable = { "missing-fields" },
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "lua", "luadoc" })
    end,
  },
}
