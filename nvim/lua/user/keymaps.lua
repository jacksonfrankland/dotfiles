vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Reselect visual selection after indenting.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set('v', 'y', 'myy`y')

-- Paste replace visual selection without copying it.
vim.keymap.set('v', 'p', '"_dP')

-- Easy insertion of a trailing ; or ,
vim.keymap.set('n', '<Leader>;', 'A;<Esc>', { desc = 'Insert ; to end of line' })
vim.keymap.set('n', '<Leader>,', 'A,<Esc>', { desc = 'Insert , to end of line' })

-- Quickly clear search highlighting.
vim.keymap.set('n', '<Leader>k', ':nohlsearch<CR>', { desc = 'Clear search' })

-- Move lines up and down.
vim.keymap.set('i', '<A-j>', '<Esc>:move .+1<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc>:move .-2<CR>==gi')
vim.keymap.set('n', '<A-j>', ':move .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':move .-2<CR>==')
vim.keymap.set('v', '<A-j>', ":move '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":move '<-2<CR>gv=gv")

-- Reindent
vim.keymap.set('n', '<Leader>=', ':set shiftwidth=4<CR>:LspZeroFormat<CR>', { desc = 'Format' })

-- Insert empty line above or below
vim.keymap.set('n', '<Leader>o', 'moo<Esc>0d$`o', { desc = 'Insert empty line below' })
vim.keymap.set('n', '<Leader>O', 'moO<Esc>0d$`o', { desc = 'Insert empty line above' })

-- Common commands
vim.keymap.set('n', '<Leader>w', ':w<CR>', { desc = 'Save' })
vim.keymap.set('n', '<Leader>q', ':qa<CR>', { desc = 'Quit' })
