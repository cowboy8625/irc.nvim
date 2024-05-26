---@module 'utils.models'

---@class Utils
---@field map function fun(array: T[], func: fun(arg: T): U): U[]
---@field filter function fun(array: T[], predicate: fun(arg: T): boolean): T[]
M = {}

---@generic T, U
---@param array T[]
---@param func fun(arg: T): U
---@return U[]
M.map = function(array, func)
  local result = {}
  for i, v in ipairs(array) do
    result[i] = func(v)
  end
  return result
end

---@generic T
---@param array T[]
---@param predicate fun(arg: T): boolean
---@return T[]
M.filter = function(array, predicate)
  local result = {}
  for _, v in ipairs(array) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

---@param text string
---@return string
M.ebg13 = function(text)
  return (
    text:gsub("%a", function(c)
      local base = c:lower() == c and string.byte("a") or string.byte("A")
      return string.char(base + (string.byte(c) - base + 13) % 26)
    end)
  )
end

---@generic T
---@param value string
---@param tbl T[] -- Table to search in
---@return boolean
-- Helper function to check if a value is in a table
M.value_in_table = function(value, tbl)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

---@param line_number integer
M.is_line_in_view = function(line_number)
  local first_visible_line = vim.fn.line("w0")
  local last_visible_line = vim.fn.line("w$")

  return line_number >= first_visible_line and line_number <= last_visible_line
end

---@param keys string
---@private
-- Helper function to feed keys to Neovim
M.feedkeys = function(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", true)
end

-- Scroll up by a specified number of lines
M.scroll_up = function(lines)
  M.feedkeys(lines .. "<C-y>")
end

-- Scroll down by a specified number of lines
local function scroll_down(lines)
  M.feedkeys(lines .. "<C-e>")
end

return M
