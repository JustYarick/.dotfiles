-- Groovy / Jenkinsfile support
-- Treesitter parser for syntax highlighting
-- Neovim auto-detects Jenkinsfile as groovy filetype

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "groovy" },
    },
  },
}
