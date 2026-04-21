--- @since 25.2.13

local header = require("ranger-like.header")
local linemode = require("ranger-like.linemode")
local status = require("ranger-like.status")

local setup_done = false
local M = {}

function M:setup()
  if setup_done then
    return
  end
  setup_done = true

  header.setup()
  status.setup()

  local function refresh()
    local cwd = cx.active.current.cwd
    if not cwd then
      return
    end

    linemode.prefetch(cwd)
  end

  ps.sub("cd", refresh)

  ps.sub("load", function(args)
    local cwd = cx.active.current.cwd
    if not cwd or tostring(args.url) ~= tostring(cwd) then
      return
    end

    refresh()
  end)
end

function M:render(file)
  return linemode.render(file)
end

return M
