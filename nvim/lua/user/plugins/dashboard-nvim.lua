local dashboard = require('dashboard')

dashboard.custom_center = {
  { icon = '  ', desc = 'New file                       ', action = 'enew' },
  { icon = '  ', shortcut = 'SPC f', desc = 'Find file                 ', action = 'Telescope find_files' },
  { icon = '  ', shortcut = 'SPC h', desc = 'Recent files              ', action = 'Telescope oldfiles' },
  { icon = '  ', shortcut = 'SPC g', desc = 'Find Word                 ', action = 'Telescope live_grep' },
}

dashboard.custom_footer = { '' }
