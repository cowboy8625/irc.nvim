---@class IrcUi
local M = {}

M.bufnr = nil
M.winid = nil

M.config = {
  relative = "editor",
  style = "minimal",
  border = "single",
  width = 50,
  height = 10,
  row = 0,
  col = 0,
}

M.init = function()
  M.bufnr = vim.api.nvim_create_buf(false, true)

  assert(M.bufnr, "Failed to create buffer")

  M.write("Welcome to the IRC chat!")
  M.message("cowboy8625", "Hello!")
  M.message("dude", "Lets GOOOOOOOOOOO!!!!!")

  vim.api.nvim_buf_set_option(M.bufnr, "syntax", "irc")

  M.winid = vim.api.nvim_open_win(M.bufnr, true, M.config)
end

M.message = function(username, msg)
  if not M.bufnr then
    print("Module not initialized")
    return
  end

  local fmgs = "<" .. username .. "> " .. msg .. " [" .. os.date("%I:%M %p") .. "]"

  M.write(fmgs)
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
