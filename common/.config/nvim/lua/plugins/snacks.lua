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
        sources = {
          files = {
            hidden = true,
            ignored = true,
          },
          grep = {
            hidden = true,
            ignored = true,
          },
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
