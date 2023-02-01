local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup()
vim.keymap.set('n', '<Leader>i', ':lua vim.lsp.buf.code_action()<CR>', { desc = 'Code actions' })

