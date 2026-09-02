-- Nginx config syntax highlighting via treesitter

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "nginx" },
    },
  },
}
