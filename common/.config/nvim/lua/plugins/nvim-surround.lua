return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "gs", "<Plug>(nvim-surround-normal)", opts)
      map("n", "gss", "<Plug>(nvim-surround-normal-cur)", opts)
      map("n", "gsd", "<Plug>(nvim-surround-delete)", opts)
      map("n", "gsc", "<Plug>(nvim-surround-change)", opts)
      map("x", "gs", "<Plug>(nvim-surround-visual)", opts)
    end,
  },
}
