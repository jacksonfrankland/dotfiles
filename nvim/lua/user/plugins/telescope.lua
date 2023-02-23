local actions = require('telescope.actions')

vim.cmd([[
  highlight link TelescopePromptTitle PMenuSel
  highlight link TelescopePreviewTitle PMenuSel
  highlight link TelescopePromptNormal NormalFloat
  highlight link TelescopePromptBorder FloatBorder
  highlight link TelescopeNormal CursorLine
  highlight link TelescopeBorder CursorLineBg
]])

require('telescope').setup({
    defaults = {
        path_display = { truncate = 1 },
        prompt_prefix = '   ',
        selection_caret = '  ',
        layout_config = {
            prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
        mappings = {
            i = {
                ['<esc>'] = actions.close,
                ['<C-Down>'] = actions.cycle_history_next,
                ['<C-Up>'] = actions.cycle_history_prev,
            },
        },
        file_ignore_patterns = { '.git/' },
        preview = {
            filesize_hook = function(filepath, bufnr, opts)
                local max_bytes = 5000
                local cmd = { "head", "-c", max_bytes, filepath }
                require('telescope.previewers.utils').job_maker(cmd, bufnr, opts)
            end
        }
    },
    pickers = {
        find_files = {
            hidden = true,
        },
        buffers = {
            previewer = false,
            layout_config = {
                width = 80,
            },
        },
        oldfiles = {
            prompt_title = 'History',
        },
        lsp_references = {
            previewer = false,
        },
    },
})

require('telescope').load_extension('fzf')
require('telescope').load_extension('live_grep_args')

vim.keymap.set('n', '<leader>f', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], { desc = 'Find file' })
vim.keymap.set('n', '<leader>F',
    [[<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, prompt_title = 'All Files' })<CR>]],
    { desc = 'Find file including ignores' })
vim.keymap.set('n', '<leader>b', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { desc = 'Find buffer' })
vim.keymap.set('n', '<leader>g', [[<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]],
    { desc = 'Grep in files' })
vim.keymap.set('n', '<leader>h', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]],
    { desc = 'Find file in history' })
vim.keymap.set('n', '<leader>s', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]],
    { desc = 'Find symbol in buffer' })
vim.keymap.set('n', '<leader>S', [[<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>]],
    { desc = 'Find symbol in workspace' })
