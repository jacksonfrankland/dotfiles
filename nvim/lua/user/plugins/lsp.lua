local lsp = require('lsp-zero')
lsp.preset('recommended')
lsp.setup_nvim_cmp({
    mappings = cmp_mappings,
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp', keyword_length = 1 },
        { name = 'buffer', keyword_length = 1 },
        { name = 'luasnip', keyword_length = 1 },
    }
})

lsp.setup()
vim.keymap.set('n', '<Leader>i', ':lua vim.lsp.buf.code_action()<CR>', { desc = 'Code actions' })
