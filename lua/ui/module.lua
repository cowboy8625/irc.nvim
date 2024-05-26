local cmd = require("client.command")
---@class IrcUi
local M = {}

M.winid = nil
M.is_open = false
---@type TextBox
M.text_box = require("ui.text_box")

M.config = {
  relative = "editor",
  style = "minimal",
  border = "rounded",
  title_pos = "center",
}

---@param server_name string
---@return integer
M.init = function(server_name)
  local bufnr = vim.api.nvim_create_buf(false, true)
  assert(bufnr, "Failed to create buffer")
  vim.api.nvim_buf_set_name(bufnr, server_name)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Welcome to the IRC chat!" })
  vim.api.nvim_set_option_value("syntax", "irc", { buf = bufnr })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  return bufnr
end

---@param bufnr integer
M.prompt = function(bufnr)
  if M.has_prompt(bufnr) then
    return
  end

  M.write(bufnr, { "> " }, { kind = "prompt" })
end

---@param title string -- channel name
M.build_config = function(title)
  title = " " .. title .. " "
  local config = M.config
  config.title = title
  config.width = math.floor(vim.o.columns * 0.8)
  config.height = math.floor(vim.o.lines * 0.8)

  config.row = math.floor((vim.o.lines - config.height) * 0.5)
  config.col = math.floor((vim.o.columns - config.width) * 0.5)

  return config
end

---@param bufnr integer
---@param username string
---@param msg string
---@param ops? { kind: string }
M.message = function(bufnr, username, msg, ops)
  if ops and ops.kind == cmd.PRIVMSG then
    local fmgs = "<" .. username .. "> " .. msg .. " [" .. os.date("%I:%M %p") .. "]"
    M.write(bufnr, { fmgs }, ops)
    return
  end
  M.write(bufnr, { msg }, ops)
end

---@param bufnr integer
M.has_prompt = function(bufnr)
  local line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)[1]
  if line == nil then
    return false
  end

  if line:find("^" .. "> ") then
    return true
  end
  return false
end

---@param bufnr integer
M.jump_to_end_of_message = function(bufnr)
  local col = #vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)[1]
  local row = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(M.winid, { row, col })
  vim.api.nvim_feedkeys("A", "n", true)
end

---@param bufnr integer
---@return string?
M.get_message_to_send = function(bufnr)
  local line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)[1]
  if line == nil then
    return nil
  end

  local split_line = vim.split(line, ">")
  local message = split_line[2]:gsub("^%s*(.-)%s*$", "%1")

  if message == "" then
    return nil
  end

  return message
end

---@param bufnr integer
M.delete_message = function(bufnr)
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, -2, -1, false, {})
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---@param bufnr integer
---@param messages string[]
---@param ops? { kind: string }
M.write = function(bufnr, messages, ops)
  local row = M.has_prompt(bufnr) and -2 or -1
  if ops and ops.kind ~= cmd.PRIVMSG then
    row = -1
  end
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, messages)
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---@param bufnr integer
---@param messages string[]
M.log = function(bufnr, messages)
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, messages)
  vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
end

---@param bufnr integer
---@param title string
M.show = function(bufnr, title)
  if M.is_open then
    return
  end
  if M.winid then
    return
  end
  -- vim.cmd("tabnew | buffer " .. bufnr)
  M.is_open = true
  M.winid = vim.api.nvim_open_win(bufnr, true, M.build_config(title))
end

M.close = function()
  if not M.winid then
    return
  end
  vim.api.nvim_win_close(M.winid, true)
  M.is_open = false
  M.winid = nil
end

---@param bufnr integer
---@param current_message string
M.open_text_box = function(bufnr, current_message)
  local col = 1
  local row = vim.api.nvim_buf_line_count(bufnr)
  M.text_box.open(M.winid, row, col, current_message)
end

---@param current_bufnr integer
M.close_text_box = function(current_bufnr)
  local result = M.text_box.close()
  if result == nil then
    return
  end
  local row = vim.api.nvim_buf_line_count(current_bufnr)
  local col = result.col + 2
  result.text[1] = "> " .. result.text[1]
  vim.api.nvim_set_option_value("modifiable", true, { buf = current_bufnr })
  vim.api.nvim_set_option_value("readonly", false, { buf = current_bufnr })
  vim.api.nvim_buf_set_lines(current_bufnr, -2, -1, false, result.text)
  vim.api.nvim_set_option_value("readonly", true, { buf = current_bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = current_bufnr })
  vim.api.nvim_win_set_cursor(M.winid, { row, col })
end

return M
