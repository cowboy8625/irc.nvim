---@class TextBoxConfig
---@field offset {row: integer, col: integer}
---@field cursor { row: integer, col: integer }
---@field key string

---@class TextBox
local M = {}
---@type integer
---@private
M.winid = nil
---@type integer
---@private
M.bufnr = nil

---@param parent_win integer
---@param text string
---@param config TextBoxConfig
M.open = function(parent_win, text, config)
  local parent_config = vim.api.nvim_win_get_config(parent_win)
  M.bufnr = vim.api.nvim_create_buf(false, true)
  M.init_ui_keymaps()
  local width = parent_config.width
  assert(width, "Parent window has no width")
  local row = config.offset.row
  local col = config.offset.col + 1
  local win_config = M.build_config(width - 2, row, col, parent_win)
  M.winid = vim.api.nvim_open_win(M.bufnr, true, win_config)
  vim.api.nvim_feedkeys(config.key, "n", false)
  vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, { text })
  if config.cursor and config.cursor.row and config.cursor.col then
    vim.api.nvim_win_set_cursor(M.winid, { config.cursor.row, config.cursor.col })
  end
  vim.cmd([[ au BufWinLeave <buffer> stopinsert ]])
end

---@return { text: string[], row: integer, col: integer }?
M.close = function()
  local result = nil
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) then
    result = {}
    result.text = vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false)
    local row, col = unpack(vim.api.nvim_win_get_cursor(M.winid))
    result.row = row
    result.col = col
    vim.api.nvim_win_close(M.winid, true)
  end
  if M.bufnr ~= nil and vim.api.nvim_buf_is_valid(M.bufnr) then
    vim.api.nvim_buf_delete(M.bufnr, { force = true })
  end
  return result
end

---@param width integer
---@param row integer
---@param col integer
---@param parent_win integer
---@return table
M.build_config = function(width, row, col, parent_win)
  return {
    relative = "win",
    win = parent_win,
    style = "minimal",
    border = "none",
    width = width,
    height = 1,
    bufpos = { row - 2, col },
  }
end

M.init_ui_keymaps = function()
  vim.api.nvim_buf_set_keymap(
    M.bufnr,
    "i",
    "<esc>",
    "<cmd>lua require('irc_nvim').close_message_box()<CR>",
    { silent = true }
  )

  vim.api.nvim_buf_set_keymap(
    M.bufnr,
    "i",
    "<enter>",
    "<cmd>lua require('irc_nvim').send_message_from_ui()<CR>",
    { silent = true }
  )
end

return M
