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

-- Open informed365 Jira tickets you're assigned to or reviewing, with a
-- worktree and session for each. See ticket-picker.sh.
rex.action{
  name     = "ticket_picker",
  title    = "Open Ticket Worktree…",
  category = "Session",
  keywords = "jira ticket review worktree informed365 fzf session",
  run      = function(ctx, args)
    float{ config_dir .. "/ticket-picker.sh" }
  end,
}

-- informed365's run command (run-i365 in shell/.functions) in a tab named
-- "run", for the checkout or worktree of the focused pane. If the session
-- already has a "run" tab, switch to it instead.
local i365 = os.getenv("HOME") .. "/Code/informed365"
local i365_worktrees = os.getenv("HOME") .. "/Code/worktrees/informed365/"

rex.action{
  name     = "run_informed",
  title    = "Run informed365",
  category = "Session",
  keywords = "run informed365 build watch dev server",
  run      = function(ctx, args)
    local view = rex.session.view{}
    for _, w in ipairs((view and view.windows) or {}) do
      if w.label == "run" then
        local _, err = rex.session.focus_window{ window_id = w.window_id }
        if err ~= nil then error(err, 0) end
        return
      end
    end

    local cwd = focused_cwd(ctx)
    local r = cwd ~= "" and rex.exec({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd })
    local root = (r and r.ok and r.stdout:gsub("\n$", "")) or ""
    local is_i365 = root == i365
      or (root:sub(1, #i365_worktrees) == i365_worktrees and not root:find("/", #i365_worktrees + 1))
    if not is_i365 then
      error("Run informed365: the focused pane isn't in an informed365 checkout or worktree", 0)
    end

    -- An interactive zsh loads run-i365; the shell stays after it stops.
    local _, err = rex.session.new_window{
      window_label = "run",
      layout = rex.layout.block{
        flavor  = terminal .. ".shell",
        options = { cwd = root, command = { "zsh", "-ic", "run-i365; exec zsh" } },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("cmd+o", "project_picker")
rex.bind("cmd+r", "run_informed")
rex.bind("shift+cmd+j", "ticket_picker")
rex.bind("shift+cmd+o", "worktree_picker")
