---@class IrcUi
local M = {}

M.winid = nil
M.is_open = false

M.config = {
  relative = "editor",
  style = "minimal",
  border = "rounded",
}

---@param server_name string
M.init = function(server_name)
  -- -- TODO: close this buffer
  -- local title_bufnr = vim.api.nvim_create_buf(false, true)
  -- vim.api.nvim_buf_set_lines(title_bufnr, 0, -1, false, { server_name })
  local bufnr = vim.api.nvim_create_buf(false, true)
  assert(bufnr, "Failed to create buffer")
  vim.api.nvim_buf_set_name(bufnr, server_name)
  M.write(bufnr, { "Welcome to the IRC chat!" })
  vim.api.nvim_buf_set_option(bufnr, "syntax", "irc")
  return bufnr
end

---@param bufnr integer
M.prompt = function(bufnr)
  if M.has_prompt(bufnr) then
    return
  end

  M.write(bufnr, { "> " })
end

M.build_config = function()
  local config = M.config
  config.width = math.floor(vim.o.columns * 0.8)
  config.height = math.floor(vim.o.lines * 0.8)

  config.row = math.floor((vim.o.lines - config.height) * 0.5)
  config.col = math.floor((vim.o.columns - config.width) * 0.5)

  return config
end

---@param bufnr integer
---@param username string
---@param msg string
M.message = function(bufnr, username, msg)
  local fmgs = "<" .. username .. "> " .. msg .. " [" .. os.date("%I:%M %p") .. "]"

  M.write(bufnr, { fmgs })
end

---@param bufnr integer
M.has_prompt = function(bufnr)
  local line = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)[1]
  if line == nil then
    return false
  end

  if line:sub(1, 1) ~= ">" then
    return false
  end

  return true
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

  if line:sub(1, 1) ~= ">" then
    return nil
  end

  local message = line:sub(3, -1)

  if message == "" then
    return nil
  end

  return message
end

---@param bufnr integer
M.delete_message = function(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, -2, -1, false, {})
end

---@param bufnr integer
---@param messages string[]
M.write = function(bufnr, messages)
  local row = M.has_prompt(bufnr) and -2 or -1
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, messages)
end

---@param bufnr integer
M.show = function(bufnr)
  if M.winid then
    return
  end
  vim.cmd("tabnew | buffer " .. bufnr)
  M.is_open = true
  -- M.winid = vim.api.nvim_open_win(bufnr, true, M.build_config())
end

M.close = function()
  if not M.winid then
    print("Module not initialized")
    return
  end
  vim.api.nvim_win_close(M.winid, true)
  M.winid = nil
end

return M
