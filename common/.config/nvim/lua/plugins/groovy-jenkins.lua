-- Groovy / Jenkinsfile support
-- Treesitter parser for syntax highlighting
-- Neovim auto-detects Jenkinsfile as groovy filetype

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "groovy" })
    end,
  },
}
