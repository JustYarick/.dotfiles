return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "vague-theme/vague.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
