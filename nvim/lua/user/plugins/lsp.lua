local lsp = require('lsp-zero')
lsp.preset('recommended')

require('luasnip/loaders/from_snipmate').lazy_load()

-- diagnostics
vim.api.nvim_set_keymap('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>',
    { desc = 'See diagnostics', noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    { desc = 'Previous diagnostic', noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>',
    { desc = 'Next diagnostic', noremap = true, silent = true })
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>',
    { desc = 'Declaration', noremap = true, silent = true })
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = 'Definition', noremap = true, silent = true })
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
    { desc = 'Implementation', noremap = true, silent = true })
vim.keymap.set('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    { desc = 'Type definition', noremap = true, silent = true })
vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.rename()<CR>', { desc = 'Rename', noremap = true, silent = true })
vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>', { desc = 'References', noremap = true, silent = true })

-- code actions
vim.keymap.set('n', '<Leader>i', ':lua vim.lsp.buf.code_action()<CR>', { desc = 'Code actions' })

lsp.setup_nvim_cmp({
    experimental = {
        ghost_text = true,
    },
    mappings = cmp_mappings,
    sources = {
        { name = 'nvim_lsp',                keyword_length = 1 },
        { name = 'nvim_lsp_signature_help', keyword_length = 1 },
        { name = 'nvim_lua',                keyword_length = 1 },
        { name = 'buffer',                  keyword_length = 1 },
        { name = 'luasnip',                 keyword_length = 1 },
        { name = 'path' },
    }
})

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
    on_attach = null_opts.on_attach,
    sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.pint
    }
})


lsp.setup()
