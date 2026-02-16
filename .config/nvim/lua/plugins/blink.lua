return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}

      opts.keymap["<CR>"] = { "fallback" }

      opts.keymap["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.accept()
          end
        end,
        "fallback",
      }

      return opts
    end,
  },
}
