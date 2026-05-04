-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set({ "n", "i", "v" }, "<C-S-s>", function()
  -- Принудительно загружаем conform если ещё не загружен
  local conform = require("conform")
  conform.format({ async = false, lsp_fallback = true }, function()
    vim.cmd("write")
    vim.notify("Formatted & saved", vim.log.levels.INFO, { title = "Format" })
  end)
end, { desc = "Format & Save", silent = true })
