require('lualine').setup {
  options = {
    theme = "catppuccin",
    component_separators = '|',
    section_separators = { left = '', right = '' },
    -- ... the rest of your lualine config
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {{'filename', path = 1}},
    lualine_y = {'progress', 'diagnostics'},
  }
}
