---@class TextBox
local M = {}
---@type integer
---@private
M.winid = nil
---@type integer
---@private
M.bufnr = nil

---@param parent_win integer
---@param offset_row integer
---@param offset_col integer
---@param text string
M.open = function(parent_win, offset_row, offset_col, text)
  local parent_config = vim.api.nvim_win_get_config(parent_win)
  M.bufnr = vim.api.nvim_create_buf(false, true)
  M.init_ui_keymaps()
  local width = parent_config.width
  assert(width, "Parent window has no width")
  local row = parent_config.row + offset_row
  local col = parent_config.col + offset_col + 1
  M.winid = vim.api.nvim_open_win(M.bufnr, true, M.build_config(width, row, col))
  vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, { text })
  vim.api.nvim_feedkeys("A", "n", false)
  vim.cmd([[ au BufWinLeave <buffer> stopinsert ]])
end

---@return string[]
M.close = function()
  local text = vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false)
  if M.winid ~= nil and vim.api.nvim_win_is_valid(M.winid) then
    vim.api.nvim_win_close(M.winid, true)
  end
  if M.bufnr ~= nil and vim.api.nvim_buf_is_valid(M.bufnr) then
    vim.api.nvim_buf_delete(M.bufnr, { force = true })
  end
  return text
end

---@param width integer
---@param row integer
---@param col integer
---@return table
M.build_config = function(width, row, col)
  return {
    relative = "editor",
    style = "minimal",
    border = "none",
    width = width,
    height = 1,
    row = row,
    col = col,
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
end

return M
