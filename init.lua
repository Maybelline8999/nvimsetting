-- ~/.config/nvim/init.lua
require('logger/errorlog')
require('android/copy')

-- 1. Переменные окружения (до загрузки плагинов)
vim.env.XDG_RUNTIME_DIR = vim.fn.expand("$PREFIX/var/run")
vim.env.HOME   = vim.fn.expand("~")
vim.env.GOROOT = "/data/data/com.termux/files/usr/lib/go"
vim.env.GOPATH = vim.env.HOME .. "/gopath"
vim.env.GOBIN  = vim.env.GOPATH .. "/bin"
vim.env.PATH   = vim.env.GOBIN .. ":" .. vim.env.GOROOT .. "/bin:" .. vim.env.PATH

-- 2. Установка lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Настройка плагинов
require("lazy").setup({
  spec = {
    {
      "ray-x/go.nvim",
      dependencies = {
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
      },
      -- Добавляем event, чтобы плагин грузился и запускал gopls ДО того, как ты начнешь печатать
      ft = { "go", "gomod" },
      event = { "BufReadPre", "BufNewFile" }, 
      config = function()
        require("go").setup({
          lsp_cfg = true,
          goimports = "goimports",
          gofmt = "gofumpt",
          dap_debug = false,
          dap_debug_vt = false,
        })

        -- ⚡️ Используем новый API Neovim для настройки gopls без конфликтов
        vim.lsp.config('gopls', {
          settings = {
            gopls = {
              diagnosticsTrigger = "Edit",     -- Пересчитывать диагностику при редактировании
              diagnosticsDelay = "100ms",     -- Минимальная задержка перед анализом
            },
          },
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            require("go.format").goimports()
          end,
        })
      end,
      build = function()
        require("go.install").update_all_sync()
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },
    {
      'windwp/nvim-autopairs',
      event = "InsertEnter",
      config = true
    },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})

-- Показать ошибку по Ctrl + k
vim.keymap.set("n", "<C-M-k>", vim.diagnostic.open_float, { desc = "Показать ошибку" })
-- Вызов документации по Alt + Ctrl + g
vim.keymap.set("n", "<M-C-g>", vim.lsp.buf.hover, { desc = "Показать документацию" })
