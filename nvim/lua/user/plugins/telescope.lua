local actions = require('telescope.actions')

local previewers = require('telescope.previewers')

local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}

    filepath = vim.fn.expand(filepath)
    vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end
        if stat.size > 100000 then
            return
        else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
    end)
end

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
        buffer_previewer_maker = new_maker,
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
