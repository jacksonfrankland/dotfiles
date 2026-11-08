-- Option+Ctrl+Arrow moves focus between panes
rex.bind("ctrl+alt+left", "pane.focus.left")
rex.bind("ctrl+alt+right", "pane.focus.right")
rex.bind("ctrl+alt+up", "pane.focus.up")
rex.bind("ctrl+alt+down", "pane.focus.down")

-- Pickers: fzf in a floating pane, then switch to (or create) a session.
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
local terminal = "com.superlogical.terminal"

-- Run a command in a floating pane in front of the current window.
local function float(command)
  local _, err = rex.session.new_layer{
    bounds = { 0.2, 0.15, 0.6, 0.6 },
    focus  = true,
    layout = rex.layout.block{
      flavor  = terminal .. ".shell",
      options = { command = command },
    },
  }
  if err ~= nil then error(err, 0) end
end

-- The working directory of the program in the focused pane, or "".
local function focused_cwd(ctx)
  if ctx.block_id == nil then return "" end
  local p = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  return (p and p.foreground and p.foreground.cwd) or ""
end

-- Projects in ~/Code. See project-picker.sh.
rex.action{
  name     = "project_picker",
  title    = "Open Project…",
  category = "Session",
  keywords = "project code fzf session switch",
  run      = function(ctx, args)
    float{ config_dir .. "/project-picker.sh" }
  end,
}

-- Worktrees of the current session's project, from
-- ~/Code/worktrees/PROJECT/*. See worktree-picker.sh.
rex.action{
  name     = "worktree_picker",
  title    = "Open Worktree…",
  category = "Session",
  keywords = "worktree git branch fzf session switch",
  run      = function(ctx, args)
    local view = rex.session.view{}
    float{
      config_dir .. "/worktree-picker.sh",
      focused_cwd(ctx),
      (view and view.label) or "",
    }
  end,
}

rex.bind("cmd+o", "project_picker")
rex.bind("shift+cmd+o", "worktree_picker")
