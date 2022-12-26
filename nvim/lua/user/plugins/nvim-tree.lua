require('nvim-tree').setup({
        git = {
            ignore = false,
        },
        view = {
            width = 45
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
        actions = {
            open_file = {
                quit_on_open = true
            }
        }
    })

vim.keymap.set('n', '<Leader>n', ':NvimTreeCollapse<CR>:NvimTreeFindFileToggle<CR>', {desc = 'Open file tree'})
