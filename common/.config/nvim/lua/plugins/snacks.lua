return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        hidden = true,
        sort = {
          fields = { "type", "name" },
        },
      },
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          files = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
