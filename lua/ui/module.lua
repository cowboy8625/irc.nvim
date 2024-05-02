---@class IrcUi
local M = {}

M.bufnr = nil
M.winid = nil

M.config = {
  relative = "editor",
  style = "minimal",
  border = "rounded",
}

---@param server_name string
M.init = function(server_name)
  M.bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_name(M.bufnr, server_name)

  assert(M.bufnr, "Failed to create buffer")

  M.write("Welcome to the IRC chat!")
  M.message("cowboy8625", "Hello!")
  M.message("dude", "Lets GOOOOOOOOOOO!!!!!")
  M.prompt()

  vim.api.nvim_buf_set_option(M.bufnr, "syntax", "irc")

  local config = M.build_config()

  M.winid = vim.api.nvim_open_win(M.bufnr, true, config)
end

M.prompt = function()
  if not M.bufnr then
    print("Module not initialized")
    return
  end

  if M.has_prompt() then
    return
  end

  M.write("> ")
end

M.build_config = function()
  local config = M.config
  config.width = math.floor(vim.o.columns * 0.8)
  config.height = math.floor(vim.o.lines * 0.8)

  config.row = math.floor((vim.o.lines - config.height) * 0.5)
  config.col = math.floor((vim.o.columns - config.width) * 0.5)

  return config
end

---@param username string
---@param msg string
M.message = function(username, msg)
  if not M.bufnr then
    print("Module not initialized")
    return
  end

  local fmgs = "<" .. username .. "> " .. msg .. " [" .. os.date("%I:%M %p") .. "]"

  M.write(fmgs)
end

M.has_prompt = function()
  local line = vim.api.nvim_buf_get_lines(M.bufnr, -2, -1, false)[1]
  if line == nil then
    return false
  end

  if line:sub(1, 1) ~= ">" then
    return false
  end

  return true
end

---@return string?
M.get_message_to_send = function()
  local line = vim.api.nvim_buf_get_lines(M.bufnr, -2, -1, false)[1]
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

M.delete_message = function()
  vim.api.nvim_buf_set_lines(M.bufnr, -2, -1, false, {})
end

M.write = function(message)
  if not M.bufnr then
    print("Module not initialized")
    return
  end
  vim.api.nvim_buf_set_lines(M.bufnr, -1, -1, false, {
    message,
  })
end

M.show = function()
  if not M.bufnr then
    print("Module not initialized")
    return
  end
  M.winid = vim.api.nvim_open_win(M.bufnr, true, M.config)
end

M.close = function()
  if not M.winid then
    print("Module not initialized")
    return
  end
  vim.api.nvim_win_close(M.winid, true)
  M.winid = nil
end

M.delete = function()
  vim.api.nvim_buf_delete(M.bufnr, { force = true })
end

return M
