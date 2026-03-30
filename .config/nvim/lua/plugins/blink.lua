return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-y>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },

        ["<Tab>"] = {
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },

        ["<CR>"] = { "fallback" },
      },

      sources = {
        default = {
          "lsp",
          "snippets",
          "path",
          "buffer",
          "copilot",
        },

        providers = {
          lsp = { score_offset = 100 },
          snippets = { score_offset = 80 },
          path = { score_offset = 60 },
          buffer = { score_offset = 40 },
          copilot = { score_offset = -100 },
        },
      },
    },
  },
}
