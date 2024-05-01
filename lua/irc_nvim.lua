-- main module file
local ircClient = require("irc_nvim.module")
local ircUi = require("ui.module")

---@class Config
---@field opt table Your config option
---@field opt.server string
local config = {
  opt = {
    server = "irc.libera.chat",
    port = 6697,
    nickname = "cowboybob",
    username = "cowboybob",
    realname = "cowboybob",
    channel = "#dailycodex",
  },
}

---@class Irc
local M = {}
---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@type IrcClient
M.client = ircClient
---@type IrcUi
M.ui = ircUi

M.irc = function()
  local c = M.config.opt
  assert(c.server, "server is required")
  assert(c.port, "port is required")
  assert(c.nickname, "nickname is required")
  assert(c.username, "username is required")
  assert(c.realname, "realname is required")
  assert(c.channel, "channel is required")
  M.ui.init()
  M.init_keymaps()
  vim.cmd('autocmd ExitPre * :lua require("irc_nvim").quit()')
  -- M.client.start(c.server, c.port, c.nickname, c.username, c.realname, c.channel)
  -- M.client.connect_to_irc()
  -- M.client.login_to_irc()
  -- M.client.join_channel()
end

M.quit = function()
  M.client.close()
  M.ui.close()
end

M.send = function(args)
  local message = args.args:gsub('"', "")
  M.client.send_message(message)
end

M.send_message_from_ui = function()
  local line = vim.api.nvim_buf_get_lines(M.ui.bufnr, -2, -1, false)[1]
  print("line: " .. line)
  M.ui.write(line)
end

M.close_ui = function()
  M.ui.close()
end

M.open_ui = function()
  M.ui.show()
end

M.init_keymaps = function()
  vim.api.nvim_buf_set_keymap(M.ui.bufnr, "n", "q", "<cmd>lua require('irc_nvim').close_ui()<CR>", {})
  vim.api.nvim_buf_set_keymap(M.ui.bufnr, "n", "<enter>", "<cmd>lua require('irc_nvim').send_message_from_ui()<CR>", {})
end

M.test = function(args)
  local message = args.args:gsub('"', "")
  M.ui.write(message)
  return message
end

return M
