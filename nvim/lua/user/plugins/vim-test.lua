local wk = require("which-key")
wk.register({
    t = {
      name = "test",
      n = {':TestNearest<CR>', "Test nearest"},
      f = {':TestFile<CR>', "Test file"},
      s = {':TestSuite<CR>', "Test suite"},
      l = {':TestLast<CR>', "Test last"},
      v = {':TestVisit<CR>', "Test visit"},
    }
  }, {prefix = "<leader>"})

vim.cmd([[
  function! FloatermStrategy(cmd)
    execute 'silent FloatermKill'
    execute 'FloatermNew! '.a:cmd.' |less -X'
  endfunction
  let g:test#custom_strategies = {'floaterm': function('FloatermStrategy')}
  let g:test#strategy = 'floaterm'
]])
