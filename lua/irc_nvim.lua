-- main module file
local client = require("client.module")
local cmd = require("client.command")
local ircUi = require("ui.module")
local utils = require("utils.module")
local channelPicker = require("picker.module")

---@class Config
---@field opt table<string, any>
---@field opt.server string
---@field opt.port number
---@field opt.nickname string
---@field opt.username string
---@field opt.realname string
---@field opt.password string
---@field opt.channels string[]
local config = {
  opt = {},
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
M.client = client
---@type IrcUi
M.ui = ircUi
---@type table<string, integer>
M.channels = {}
---@type table{name: string, bufnr: integer}
M.current_channel = nil
---@type IrcChannelPicker
M.channel_picker = channelPicker

M.auto_close = function()
  vim.cmd([[
  augroup AutoCloseOnFocusLost
    autocmd!
    autocmd WinLeave * :IrcCloseUi
  augroup END
  ]])
end

M.irc = function()
  M.auto_close()
  local c = M.config.opt
  assert(c.server, "server is required")
  assert(c.port, "port is required")
  assert(c.nickname, "nickname is required")
  assert(c.username, "username is required")
  assert(c.realname, "realname is required")
  for _, channel in ipairs(c.channels) do
    M.current_channel = { name = channel, bufnr = ircUi.init(channel) }
    M.channels[channel] = M.current_channel.bufnr
    assert(M.current_channel.bufnr, "Failed to create buffer")
    assert(M.current_channel.name, "Failed to create buffer")
    M.ui.prompt(M.current_channel.bufnr)
  end

  for _, bufnr in pairs(M.channels) do
    M.init_keymaps(bufnr)
  end

  -- M.client = client.init(c.server, c.port, c.nickname, c.username, c.realname)
  -- M.client.connect_to_irc(M.output_data_to_ui)
  -- local p = utils.ebg13(c.password)
  -- M.client.login_to_irc(p)
  -- M.client.join_channel(M.current_channel.name)

  M.open_ui()
  vim.cmd('autocmd ExitPre * :lua require("irc_nvim").quit()')
end

---@param data string
M.output_data_to_ui = function(data)
  local lines = utils.filter(vim.split(data, "\r\n"), function(line)
    return line ~= ""
  end)
  vim.schedule(function()
    for _, line in ipairs(lines) do
      local split = vim.split(line, " ")
      local command = split[2]
      if command == cmd.PRIVMSG then
        local username = vim.split(split[1], "!")[1]:sub(2, -1)
        local channel = split[3]
        local message_split = vim.split(line, ":")
        local message = table.remove(message_split, #message_split)
        local bufnr = M.channels[channel]
        M.ui.message(bufnr, username, message)
      else
        M.ui.write(M.current_channel.bufnr, { line })
      end
    end
  end)
end

M.quit = function()
  for _, bufnr in pairs(M.channels) do
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
  if M.client then
    M.client.close()
  end
  if M.ui then
    M.ui.close()
  end
end

M.send_message_from_ui = function()
  local bufnr = M.current_channel.bufnr
  local channel = M.current_channel.name
  assert(channel, "No channel to send message to")
  assert(bufnr, "No buffer to send message to")
  local message = M.ui.get_message_to_send(bufnr)
  if message == nil then
    M.ui.write(bufnr, { "No message to send" })
    return
  end
  M.client.send_message(channel, message)
  M.ui.delete_message(bufnr)
  M.ui.message(bufnr, M.config.opt.username, message)
  M.ui.prompt(bufnr)
end

M.jump_to_end_of_message = function()
  M.ui.jump_to_end_of_message(M.current_channel.bufnr)
end

M.close_ui = function()
  M.ui.close()
end

M.open_ui = function()
  M.ui.show(M.current_channel.bufnr)
end

M.channel_list_ui = function()
  local bufnr = M.channel_picker.init(M.channels)
  M.nmap(bufnr, "<enter>", ":lua require('irc_nvim').goto_channel_from_picker()<CR>")
  M.nmap(bufnr, "q", ":lua require('irc_nvim').channel_picker.close()<CR>")
end

M.goto_channel_from_picker = function()
  local data = M.channel_picker.get_bufnr_under_cursor()
  if data == nil then
    return
  end
  -- M.channel_picker.close()
  M.current_channel = data
  --M.ui.redraw()
end

---@param bufnr integer
M.init_keymaps = function(bufnr)
  M.nmap(bufnr, "<enter>", ":lua require('irc_nvim').send_message_from_ui()<CR>")
  M.imap(bufnr, "<enter>", "<cmd>lua require('irc_nvim').send_message_from_ui()<CR>")
  M.nmap(bufnr, "q", ":lua require('irc_nvim').close_ui()<CR>")
  M.nmap(bufnr, "<C-a>", ":lua require('irc_nvim').jump_to_end_of_message()<CR>")
  M.nmap(bufnr, "cp", ":IrcChannelPicker<CR>")
end

---@param bufnr integer
---@param keys string
---@param command string
M.nmap = function(bufnr, keys, command)
  vim.api.nvim_buf_set_keymap(bufnr, "n", keys, command, {})
end

---@param bufnr integer
---@param keys string
---@param command string
M.imap = function(bufnr, keys, command)
  vim.api.nvim_buf_set_keymap(bufnr, "i", keys, command, {})
end

return M
