---@class IrcChannelPicker
M = {}
---@type integer | nil
M.bufnr = nil
---@type integer | nil
M.winid = nil
---@type table<string, any>
M.config = {
  relative = "editor",
  style = "minimal",
  border = "rounded",
}

---@param line integer
M.highlight_line = function(line)
  local src_id = vim.api.nvim_create_namespace("irc_channel_picker")
  vim.api.nvim_buf_add_highlight(M.bufnr, src_id, "SelectedChannel", line, 0, -1)
end

---@param data table<string, integer>[]
---@param current? integer current bufnr/channel
---@return integer
M.init = function(data, current)
  print("init channel picker")
  local names = {}
  local line_of_current_channel = nil
  local i = 0
  for channel, bufnr in pairs(data) do
    if bufnr == current then
      line_of_current_channel = i
    end
    table.insert(names, bufnr .. " " .. channel)
    i = i + 1
  end

  M.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(M.bufnr, "Channel Picker")
  vim.api.nvim_buf_set_option(M.bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, names)

  if line_of_current_channel then
    print("highlighting line", line_of_current_channel)
    M.highlight_line(line_of_current_channel)
  end

  vim.api.nvim_buf_set_option(M.bufnr, "modifiable", false)
  M.winid = vim.api.nvim_open_win(M.bufnr, true, M.build_config())
  return M.bufnr
end

M.build_config = function()
  local config = M.config
  config.width = math.floor(vim.o.columns * 0.3)
  config.height = math.floor(vim.o.lines * 0.3)

  config.row = math.floor((vim.o.lines - config.height) * 0.5)
  config.col = math.floor((vim.o.columns - config.width) * 0.5)

  return config
end

---@return table?{name: string, bufnr: integer}
M.get_bufnr_under_cursor = function()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if line == nil then
    return nil
  end

  local bufnr = tonumber(vim.split(line, " ")[1])
  local name = vim.split(line, " ")[2]
  return { name = name, bufnr = bufnr }
end

M.close = function()
  if not M.bufnr then
    return
  end
  vim.api.nvim_buf_delete(M.bufnr, { force = true })
  M.bufnr = nil
end

return M
