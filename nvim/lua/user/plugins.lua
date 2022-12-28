local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- My plugins here

    -- Theme
    use { "catppuccin/nvim", as = "catppuccin" }
    require("catppuccin").setup({
        flavour = "macchiato",
        integrations = {
            telescope = true,
            nvimtree = true,
            which_key = true,
            dashboard = true,
            leap = true
        }
    })
    vim.cmd.colorscheme "catppuccin"

    -- Commenting support.
    -- Line: gcc
    -- Selection: gc
    -- General: gc<motion>
    use('tpope/vim-commentary')

    -- Add, change, and delete surrounding text
    -- Change: cs<old><new>
    -- Delete: ds<old>
    -- Add: ys<motion><new>
    use('tpope/vim-surround')

    -- Useful commands like :Rename and :SudoWrite.
    use('tpope/vim-eunuch')

    -- Indent autodetection with editorconfig support.
    use('tpope/vim-sleuth')

    -- Allow plugins to enable repeating of commands.
    use('tpope/vim-repeat')

    -- Add more languages.
    use('sheerun/vim-polyglot')

    -- Navigate seamlessly between Vim windows and Tmux panes.
    use('christoomey/vim-tmux-navigator')

    -- Jump to the last location when opening a file.
    use('farmergreg/vim-lastplace')

    -- Enable * searching with visually selected text.
    use('nelstrom/vim-visual-star-search')

    -- Automatically create parent dirs when saving.
    use('jessarcher/vim-heritage')

    -- Text objects for HTML attributes.
    use({
        'whatyouhide/vim-textobj-xmlattr',
        requires = 'kana/vim-textobj-user',
    })

    -- Automatically add closing brackets, quotes, etc.
    use({
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
        end,
    })

    -- Add smooth scrolling to avoid jarring jumps
    use({
        'karb94/neoscroll.nvim',
        config = function()
            require('neoscroll').setup()
        end,
    })

    -- Split arrays and methods onto multiple lines, or join them back up.
    use({
        'AndrewRadev/splitjoin.vim',
        config = function()
            vim.g.splitjoin_html_attributes_bracket_on_new_line = 1
            vim.g.splitjoin_trailing_comma = 1
            vim.g.splitjoin_php_method_chain_full = 1
        end,
    })

    -- Automatically fix indentation when pasting code.
    use({
        'sickill/vim-pasta',
        config = function()
            vim.g.pasta_disabled_filetypes = { 'fugitive' }
        end,
    })

    -- Fuzzy finder
    use({
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons',
            'nvim-telescope/telescope-live-grep-args.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        },
        config = function()
            require('user/plugins/telescope')
        end,
    })

    -- File tree sidebar
    use({
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('user/plugins/nvim-tree')
        end,
    })

    -- A Status line.
    use({
        'nvim-lualine/lualine.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('user/plugins/lualine')
        end,
    })

    -- Display indentation lines.
    use({
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('user/plugins/indent-blankline')
        end,
    })

    -- Add a dashboard.
    use({
        'glepnir/dashboard-nvim',
        config = function()
            require('user/plugins/dashboard-nvim')
        end
    })

    -- Git integration.
    use({
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
            vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>')
            vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>')
            vim.keymap.set('n', 'gs', ':Gitsigns stage_hunk<CR>')
            vim.keymap.set('n', 'gS', ':Gitsigns undo_stage_hunk<CR>')
            vim.keymap.set('n', 'gp', ':Gitsigns preview_hunk<CR>')
            vim.keymap.set('n', 'gb', ':Gitsigns blame_line<CR>')
        end,
    })

    -- Git commands.
    use({
        'tpope/vim-fugitive',
        requires = 'tpope/vim-rhubarb',
    })

    --- Floating terminal.
    use({
        'voldikss/vim-floaterm',
        config = function()
            vim.g.floaterm_width = 0.8
            vim.g.floaterm_height = 0.8
            vim.keymap.set('n', '<Leader>p', ':FloatermToggle<CR>')
            vim.keymap.set('t', '<Leader>p', '<C-\\><C-n>:FloatermToggle<CR>')
            vim.cmd([[
      highlight link Floaterm CursorLine
      highlight link FloatermBorder CursorLineBg
    ]]       )
        end
    })

    -- Improved syntax highlighting
    use({
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })
        end,
        requires = {
            'JoosepAlviste/nvim-ts-context-commentstring',
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            require('user/plugins/treesitter')
        end,
    })

    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        },
        config = function()
            require('user/plugins/lsp')
        end
    }

    -- Testing helper
    use({
        'vim-test/vim-test',
        config = function()
            require('user/plugins/vim-test')
        end,
    })


    -- Allow key helper popups
    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
            }
        end
    }
    vim.opt.timeoutlen = 500

    -- Motion for easy navigation
    use({
        'ggandor/leap.nvim',
        requires = 'tpope/vim-repeat',
    })
    require('leap').add_default_mappings()
    require('leap').opts.safe_labels = {}

    -- Autosave
    use({
        "Pocco81/auto-save.nvim",
        config = function()
            require("auto-save").setup {
                -- your config goes here
                -- or just leave it empty :)
            }
        end,
    })

    use "mg979/vim-visual-multi"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
