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

-- Quick escape with jk (faster than reaching for Esc)
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

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

    -----------------------------------------------------
    -- WHICH-KEY: Shows available keybindings
    -- Press <Space> and wait to see all leader bindings
    -----------------------------------------------------
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                delay = 300,  -- Show popup after 300ms
            })
            -- Add labels for key groups
            wk.add({
                { "<leader>c", group = "code" },
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>t", group = "toggle" },
            })
        end,
    },

    -----------------------------------------------------
    -- AUTO-PAIRS: Automatically close brackets, quotes
    -----------------------------------------------------
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,  -- Use treesitter for smarter pairs
            })
        end,
    },

    -----------------------------------------------------
    -- LUALINE: Statusline
    -- Shows mode, file, git branch, LSP status
    -----------------------------------------------------
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -----------------------------------------------------
    -- GITSIGNS: Git diff in the gutter
    -- Shows added/changed/deleted lines
    -----------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local opts = { buffer = bufnr }

                    -- Navigation between hunks
                    vim.keymap.set("n", "]h", gs.next_hunk, opts)
                    vim.keymap.set("n", "[h", gs.prev_hunk, opts)

                    -- Actions
                    vim.keymap.set("n", "<leader>gs", gs.stage_hunk, opts)
                    vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)
                    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
                    vim.keymap.set("n", "<leader>gb", gs.blame_line, opts)
                end,
            })
        end,
    },

    -----------------------------------------------------
    -- CONFORM: Format on save
    -- Auto-runs black, rustfmt, gofmt, etc.
    -----------------------------------------------------
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "black" },
                    rust = { "rustfmt" },
                    go = { "gofmt" },
                    lua = { "stylua" },
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
    },

    -----------------------------------------------------
    -- COMMENT: Easy commenting
    -- gcc = comment line, gc = comment selection
    -----------------------------------------------------
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require("Comment").setup()
        end,
    },

    -----------------------------------------------------
    -- LEAP: Fast navigation
    -- s + 2 chars to jump anywhere visible
    -----------------------------------------------------
    {
        "ggandor/leap.nvim",
        config = function()
            -- Modern mapping setup (add_default_mappings is deprecated)
            vim.keymap.set("n", "s", "<Plug>(leap-forward)")
            vim.keymap.set("n", "S", "<Plug>(leap-backward)")
            vim.keymap.set({"x", "o"}, "s", "<Plug>(leap-forward)")
            vim.keymap.set({"x", "o"}, "S", "<Plug>(leap-backward)")
        end,
    },

    -----------------------------------------------------
    -- MINI.SURROUND: Change/add/delete surroundings
    -- sa = add, sd = delete, sr = replace
    -- Example: saiw" adds quotes around word
    -----------------------------------------------------
    {
        "echasnovski/mini.surround",
        version = false,
        config = function()
            require("mini.surround").setup({
                mappings = {
                    add = "sa",            -- Add surrounding
                    delete = "sd",         -- Delete surrounding
                    replace = "sr",        -- Replace surrounding
                    find = "sf",           -- Find surrounding
                    find_left = "sF",      -- Find surrounding (left)
                    highlight = "sh",      -- Highlight surrounding
                    update_n_lines = "sn", -- Update n_lines
                },
            })
        end,
    },

    -----------------------------------------------------
    -- INDENT-BLANKLINE: Visual indent guides
    -----------------------------------------------------
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope = { enabled = true },
            })
        end,
    },

    -----------------------------------------------------
    -- TROUBLE: Better diagnostics list
    -- <leader>xx to toggle
    -----------------------------------------------------
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup()
            vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
            vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>")
        end,
    },

    -----------------------------------------------------
    -- TODO-COMMENTS: Highlight TODO, FIXME, etc.
    -----------------------------------------------------
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup()
            vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>")
        end,
    },

    -----------------------------------------------------
    -- TELESCOPE: Fuzzy finder
    -- <leader>ff = find files, <leader>fg = live grep
    -----------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "node_modules", ".git/", "target/" },
                },
            })

            -- Keybindings
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
            vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
        end,
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

-----------------------------------------------------
-- WARMUP GAME
-- Run :Warmup 10 for 10 random challenges
-- Run :WarmupAll for all challenges
-----------------------------------------------------
require("warmup").setup()
