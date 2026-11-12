-- ~/.config/nvim/lua/logger/errorlog.lua

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN]  = "W",
      [vim.diagnostic.severity.INFO]  = "I",
      [vim.diagnostic.severity.HINT]  = "H",
    },
  },
  underline = true,
  update_in_insert = true, -- ⚡️ Обновлять диагностику прямо во время ввода
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

-- Показывать полный текст ошибки при остановке курсора
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end,
})
