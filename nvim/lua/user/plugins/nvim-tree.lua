require('nvim-tree').setup({
        git = {
            ignore = false,
        },
        renderer = {
            group_empty = true,
            icons = {
                show = {
                    folder_arrow = false,
                },
            },
            indent_markers = {
                enable = false,
            },
        },
    })

vim.keymap.set('n', '<Leader>n', ':NvimTreeFocus<CR>', {desc = 'Toggle file tree'})
