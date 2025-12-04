vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme tokyonight")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "rust", "c", "go", "lua" },
                highlight = { enable = true },
            })
        end,
    },

    -----------------------------------------------------
    -- LSP SETUP (Language Server Protocol)
    -- This gives you: autocomplete, go-to-definition,
    -- error squiggles, hover docs, etc.
    -----------------------------------------------------

    -- MASON: Auto-installs language servers
    -- Without this, you'd manually install pyright, rust-analyzer, etc.
    -- Run :Mason to see/manage installed servers
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- MASON-LSPCONFIG: Bridges mason and lspconfig
    -- Tells mason which servers to install, then auto-configures them
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                -- These will be auto-installed when you open neovim
                ensure_installed = {
                    "pyright",        -- Python
                    "rust_analyzer",  -- Rust
                    "clangd",         -- C/C++
                    "gopls",          -- Go
                    "lua_ls",         -- Lua (for your neovim config)
                },
            })
        end,
    },

    -- NVIM-LSPCONFIG: Still needed for server configs, but we use vim.lsp.config now
    { "neovim/nvim-lspconfig" },

    -----------------------------------------------------
    -- AUTOCOMPLETE SETUP
    -- nvim-cmp provides the autocomplete popup
    -----------------------------------------------------

    -- LUASNIP: Snippet engine (required by nvim-cmp)
    -- Allows you to expand snippets like "fn" -> full function template
    { "L3MON4D3/LuaSnip" },

    -- NVIM-CMP: The autocomplete engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",  -- LSP completions
            "L3MON4D3/LuaSnip",      -- Snippet support
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                -- How to expand snippets when selected
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                -- KEYBINDINGS FOR AUTOCOMPLETE POPUP:
                mapping = cmp.mapping.preset.insert({
                    -- Ctrl+Space = manually trigger completion
                    ["<C-Space>"] = cmp.mapping.complete(),
                    -- Enter = confirm selection
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    -- Tab = next item in list
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    -- Shift+Tab = previous item in list
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    -- Ctrl+e = close completion menu
                    ["<C-e>"] = cmp.mapping.abort(),
                }),

                -- Where to get completions from (in priority order)
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },  -- LSP suggestions
                    { name = "luasnip" },   -- Snippet suggestions
                }),
            })
        end,
    },

    -- CMP-NVIM-LSP: Feeds LSP completions into nvim-cmp
    { "hrsh7th/cmp-nvim-lsp" },

    -----------------------------------------------------
    -- FILE EXPLORER
    -----------------------------------------------------

    -- OIL.NVIM: Edit filesystem like a buffer
    -- Open with :Oil or -
    -- Navigate: hjkl, Enter to open
    -- Rename: just edit the text
    -- Delete: dd the line
    -- Save changes: :w
    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup({
                -- Show hidden files
                view_options = {
                    show_hidden = true,
                },
            })
            -- Press - to open parent directory
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end,
    },

    -----------------------------------------------------
    -- TMUX INTEGRATION
    -----------------------------------------------------

    -- VIM-TMUX-NAVIGATOR: Seamless movement between nvim and tmux panes
    -- Ctrl+h/j/k/l moves between splits AND tmux panes
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
        },
        keys = {
            { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
            { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
            { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
            { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
        },
    },
})

-----------------------------------------------------
-- LSP CONFIGURATION (Neovim 0.11+ native API)
-----------------------------------------------------

-- Keybindings when LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local opts = { buffer = bufnr }

        -- gd = go to definition (where is this function defined?)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- K = hover docs (show function signature/docs)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        -- <leader>rn = rename symbol (rename variable everywhere)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        -- <leader>ca = code actions (quick fixes, refactors)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        -- gr = go to references (where is this used?)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        -- <leader>e = show error in floating window
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        -- [d and ]d = jump to prev/next error
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
})

-- Enable language servers (new Neovim 0.11+ way)
-- Mason installs these, vim.lsp.enable activates them
vim.lsp.enable("pyright")       -- Python
vim.lsp.enable("rust_analyzer") -- Rust
vim.lsp.enable("clangd")        -- C/C++
vim.lsp.enable("gopls")         -- Go
vim.lsp.enable("lua_ls")        -- Lua
