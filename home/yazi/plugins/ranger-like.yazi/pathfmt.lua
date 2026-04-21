--- @since 25.2.13

local function clone_parts(parts, suffix)
  local out = {}

  for i, part in ipairs(parts) do
    out[i] = {
      text = part.text,
      dim = part.dim,
    }
  end

  if suffix and suffix ~= "" then
    out[#out + 1] = { text = suffix }
  end

  return out
end

local function store_parts(name)
  local hash, rest = name:match("^([0-9a-z]+)%-(.+)$")
  if not hash or #hash ~= 32 then
    return nil
  end

  if rest == "home-manager-files" then
    return {
      { text = "<nix-hm:" .. hash:sub(1, 6) .. ">", dim = true },
    }
  end

  return {
    { text = "<nix:" .. hash:sub(1, 6) .. ">", dim = true },
    { text = "-" .. rest },
  }
end

local function split_path(path)
  local out = {}

  for part in path:gmatch("[^/]+") do
    out[#out + 1] = part
  end

  return out
end

local function append_parts(out, parts, suffix)
  local copied = clone_parts(parts, suffix)

  for _, part in ipairs(copied) do
    out[#out + 1] = part
  end
end

local M = {}

function M.parts(name, in_store, suffix)
  local parts = in_store and store_parts(name) or nil
  return clone_parts(parts or { { text = name } }, suffix)
end

function M.text(parts)
  local out = {}

  for i, part in ipairs(parts) do
    out[i] = part.text
  end

  return table.concat(out)
end

function M.path(path)
  local out = {}
  local parts = split_path(path)
  local i = 1

  if path:sub(1, 1) == "/" then
    out[#out + 1] = { text = "/" }
  end

  if parts[1] == "nix" and parts[2] == "store" and parts[3] then
    local collapsed = store_parts(parts[3])
    if collapsed then
      append_parts(out, collapsed, #parts > 3 and "/" or "")
      i = 4
    end
  end

  for j = i, #parts do
    out[#out + 1] = {
      text = parts[j] .. (j < #parts and "/" or ""),
    }
  end

  return out
end

return M
