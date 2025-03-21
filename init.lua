if vim.g.vscode then
  return
end
-- Print a welcome message
print("Welcome to Neovim with Lua!")

-- Basic Settings
vim.o.number = true           -- Show line numbers
vim.o.relativenumber = true    -- Relative line numbers
vim.o.expandtab = true         -- Use spaces instead of tabs
vim.o.tabstop = 4              -- Number of spaces for a tab
vim.o.shiftwidth = 4           -- Indent size
vim.o.smartindent = true       -- Auto-indent new lines

-- Leader Key (important for plugins)
vim.g.mapleader = " "  -- Set Space as the leader key

-- Simple keybinding
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })
-- Keybindings for LSP (like "go to definition")
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
-- Hover info (like VSCode's "hover" feature)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
-- Find references (like "find all references")
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true, silent = true })
-- Rassign ESC key to 'jk'
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Peek implementation (like VS Code's peekImplementation)
-- vim.keymap.set('n', 'gi', function()
--   vim.lsp.buf.implementation()
-- end, { noremap = true, silent = true })

-- Toggle between relative and absolute line numbers
vim.keymap.set('n', '<Leader>ln', function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
  end
end, { noremap = true, silent = true })

-- Better version for peek implementation
vim.keymap.set('n', 'gi', function()
  vim.lsp.buf_request(0, 'textDocument/implementation', vim.lsp.util.make_position_params(), function(err, result, ctx, config)
    if err or not result or vim.tbl_isempty(result) then
      print('No implementations found')
      return
    end

    if #result == 1 then
      vim.lsp.util.jump_to_location(result[1])
    else
      local items = vim.lsp.util.locations_to_items(result, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
      vim.fn.setqflist(items)
      vim.cmd('copen')
    end
  end)
end, { noremap = true, silent = true })

-- Ensure packer is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Plugin section: add all plugins here
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer can manage itself

    -- File explorer and icons
    use {
        'nvim-tree/nvim-tree.lua',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    -- Syntax highlighting
    use 'nvim-treesitter/nvim-treesitter'

    -- LSP and autocompletion
    use 'neovim/nvim-lspconfig'
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
        }
    }
    use 'williamboman/mason.nvim'

    -- Appearance
    use 'nvim-lualine/lualine.nvim'
    use 'folke/tokyonight.nvim'

    -- Productivity tools
    use 'numToStr/Comment.nvim'
    use 'windwp/nvim-autopairs'

    if packer_bootstrap then
        require('packer').sync()
    end
end)

-- Enable devicons for file icons
require('nvim-web-devicons').setup({})
-- require('nvim-web-devicons').setup({
--   override = {
--     go = {
--       icon = "",
--       color = "#519aba",
--       name = "Go"
--     }
--   },
--   default = true
-- })

-- nvim-tree setup
require("nvim-tree").setup({
    view = {
        width = 30,
        side = "left",
    },
    renderer = {
        icons = {
            glyphs = {
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                },
            },
        },
    },
})

-- Keybindings for nvim-tree
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  ensure_installed = { "go", "lua", "json", "bash" }, -- Add other languages if needed
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
}

-- LSP for Golang (gopls)
require('lspconfig').gopls.setup{
  cmd = {"gopls"},
  filetypes = {"go", "gomod"},
  root_dir = require('lspconfig.util').root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- Set colorscheme
vim.cmd [[colorscheme tokyonight]]

-- Confirm successful load
vim.cmd("echo 'init.lua loaded successfully!'")

vim.lsp.set_log_level("debug")

-- Enable relative numbers in normal mode, absolute in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function() vim.wo.relativenumber = false end
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function() vim.wo.relativenumber = true end
})