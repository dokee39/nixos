--- @since 25.2.13

local pathfmt = require("ranger-like.pathfmt")

local function width_of(block)
  if not block or block == "" then
    return 0
  end

  if type(block) == "string" then
    return ui.Line(block):width()
  end

  return block:width()
end

local function format_mtime(mtime)
  if not mtime then
    return nil
  end

  local time = math.floor(mtime)
  if time <= 0 then
    return nil
  end

  if os.date("%Y", time) == os.date("%Y") then
    return os.date("%b %d %H:%M", time)
  end

  return os.date("%b %d  %Y", time)
end

local function user_group_info(h)
  if ya.target_family() ~= "unix" then
    return nil
  end

  local uid = h.cha.uid
  local gid = h.cha.gid
  if uid == nil or gid == nil then
    return nil
  end

  return {
    user = ya.user_name(uid) or tostring(uid),
    group = ya.group_name(gid) or tostring(gid),
  }
end

local function render_user_group(self)
  local h = self._current.hovered
  if not h then
    return ""
  end

  local info = user_group_info(h)
  if not info then
    return ""
  end

  local style = self:style()
  local alt_bg = style.alt:bg()
  local user_color = info.user == "root" and "red" or "green"

  return ui.Line {
    ui.Span(" "):style(style.alt),
    ui.Span(info.user):fg(user_color):bg(alt_bg),
    ui.Span(":"):style(style.alt),
    ui.Span(info.group):fg("green"):bg(alt_bg),
    ui.Span(" "):style(style.alt),
    ui.Span(th.status.sep_left.close):fg(alt_bg),
  }
end

local function append_parts(line, parts)
  for _, part in ipairs(parts) do
    local span = ui.Span(part.text)
    if part.dim then
      span = span:dim()
    end
    line[#line + 1] = span
  end
end

local function render_link_meta(h, max)
  if max <= 0 then
    return ""
  end

  local target = h.link_to and tostring(h.link_to) or nil
  if not target or target == "" then
    return ""
  end

  local arrow_width = width_of(" ->")
  local prefix_width = width_of(" -> ")
  if max < arrow_width then
    return ""
  end

  if max < prefix_width then
    return ui.Line {
      " ",
      ui.Span("->"):dim(),
    }
  end

  local remain = max - prefix_width
  local target_parts = pathfmt.path(target)
  local target_text = pathfmt.text(target_parts)
  local line = {
    " ",
    ui.Span("->"):dim(),
    " ",
  }

  if remain > 0 then
    if width_of(target_text) <= remain then
      append_parts(line, target_parts)
    else
      line[#line + 1] = ui.truncate(target_text, { max = remain, rtl = true })
    end
  end

  return ui.Line(line)
end

local function render_stat_meta(h, max)
  if max <= 0 then
    return ""
  end

  local nlink = ya.target_family() == "unix" and h.cha.nlink ~= nil and tostring(h.cha.nlink) or nil
  local mtime = format_mtime(h.cha.mtime)
  local candidates = {}

  if nlink and mtime then
    candidates[#candidates + 1] = ui.Line {
      " ",
      ui.Span(nlink):dim(),
      " ",
      mtime,
    }
  end

  if nlink then
    candidates[#candidates + 1] = ui.Line {
      " ",
      ui.Span(nlink):dim(),
    }
  end

  if mtime then
    candidates[#candidates + 1] = " " .. mtime
  end

  for _, candidate in ipairs(candidates) do
    if width_of(candidate) <= max then
      return candidate
    end
  end

  if mtime and max > 1 then
    return " " .. ui.truncate(mtime, { max = max - 1, rtl = true })
  end

  return ""
end

local function render_meta(self, max)
  local h = self._current.hovered
  if not h or max <= 0 then
    return ""
  end

  if h.link_to then
    return render_link_meta(h, max)
  end

  return render_stat_meta(h, max)
end

local function collect_blocks(self)
  local blocks = {
    mode = self:mode(),
    user_group = render_user_group(self),
    perm = self:perm(),
    percent = self:percent(),
    position = self:position(),
  }

  blocks.mode_width = width_of(blocks.mode)
  blocks.user_group_width = width_of(blocks.user_group)
  blocks.perm_width = width_of(blocks.perm)
  blocks.percent_width = width_of(blocks.percent)
  blocks.position_width = width_of(blocks.position)

  return blocks
end

local function join_line(parts)
  local out = {}

  for _, part in ipairs(parts) do
    if part and part ~= "" then
      out[#out + 1] = part
    end
  end

  return ui.Line(out)
end

local function visible_blocks(blocks, total)
  local show = {
    mode = true,
    user_group = true,
    perm = true,
    percent = true,
    position = true,
  }

  local function fixed()
    local width = 0

    if show.mode then
      width = width + blocks.mode_width
    end
    if show.user_group then
      width = width + blocks.user_group_width
    end
    if show.perm then
      width = width + blocks.perm_width
    end
    if show.percent then
      width = width + blocks.percent_width
    end
    if show.position then
      width = width + blocks.position_width
    end

    return width
  end

  if fixed() <= total then
    return show
  end

  show.perm = false
  if fixed() <= total then
    return show
  end

  show.user_group = false
  if fixed() <= total then
    return show
  end

  show.percent = false
  if fixed() <= total then
    return show
  end

  show.position = false
  if fixed() <= total then
    return show
  end

  show.mode = false
  return show
end

local function build_plan(self)
  local blocks = collect_blocks(self)
  local show = visible_blocks(blocks, self._area.w)

  local fixed = 0
  if show.mode then
    fixed = fixed + blocks.mode_width
  end
  if show.user_group then
    fixed = fixed + blocks.user_group_width
  end
  if show.perm then
    fixed = fixed + blocks.perm_width
  end
  if show.percent then
    fixed = fixed + blocks.percent_width
  end
  if show.position then
    fixed = fixed + blocks.position_width
  end

  local meta = render_meta(self, self._area.w - fixed)

  local left = {}
  if show.mode then
    left[#left + 1] = blocks.mode
  end
  if show.user_group then
    left[#left + 1] = blocks.user_group
  end
  if meta and meta ~= "" then
    left[#left + 1] = meta
  end

  local right = {}
  if show.perm then
    right[#right + 1] = blocks.perm
  end
  if show.percent then
    right[#right + 1] = blocks.percent
  end
  if show.position then
    right[#right + 1] = blocks.position
  end

  return join_line(left), join_line(right)
end

local function render_left(self)
  local left = build_plan(self)
  return left
end

local function render_right(self)
  local _, right = build_plan(self)
  return right
end

local setup_done = false
local M = {}

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  Status:children_remove(1, Status.LEFT)
  Status:children_remove(2, Status.LEFT)
  Status:children_remove(3, Status.LEFT)

  Status:children_remove(4, Status.RIGHT)
  Status:children_remove(5, Status.RIGHT)
  Status:children_remove(6, Status.RIGHT)

  Status:children_add(render_left, 1000, Status.LEFT)
  Status:children_add(render_right, 1000, Status.RIGHT)
end

return M
