-- main module file
local ircClient = require("irc_nvim.module")
local ircUi = require("ui.module")
local utils = require("utils.module")
local cmd = require("irc_nvim.command")

---@class Config
---@field opt table Your config option
---@field opt.server string
local config = {
  opt = {
    server = "irc.libera.chat",
    port = 6667,
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
  M.ui.init(c.server)
  M.init_keymaps()
  vim.cmd('autocmd ExitPre * :lua require("irc_nvim").quit()')
  M.client.init(c.server, c.port, c.nickname, c.username, c.realname, c.channel)
  M.client.connect_to_irc(M.output_data_to_ui)
  M.ui.prompt()
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
        -- local channel = split[3]
        local message = vim.split(line, ":")[3]
        M.ui.message(username, message)
      end
    end
  end)
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
  local message = M.ui.get_message_to_send()
  if message == nil then
    M.ui.write({ "No message to send" })
    return
  end
  M.client.send_message(message)
  M.ui.delete_message()
  M.ui.message(M.config.opt.username, message)
  M.ui.prompt()
end

M.jump_to_end_of_message = function()
  M.ui.jump_to_end_of_message()
end

M.close_ui = function()
  M.ui.close()
end

M.open_ui = function()
  M.ui.show()
end

M.init_keymaps = function()
  M.nmap("q", ":lua require('irc_nvim').close_ui()<CR>")
  M.nmap("<enter>", ":lua require('irc_nvim').send_message_from_ui()<CR>")
  M.imap("<enter>", "<cmd>lua require('irc_nvim').send_message_from_ui()<CR>")
  M.nmap("q", ":lua require('irc_nvim').close_ui()<CR>")
  M.nmap("<C-a>", ":lua require('irc_nvim').jump_to_end_of_message()<CR>")
end

M.test = function(args)
  local message = args.args:gsub('"', "")
  M.ui.write(message)
  return message
end

---@param keys string
---@param command string
M.nmap = function(keys, command, descripton)
  vim.api.nvim_buf_set_keymap(M.ui.bufnr, "n", keys, command, {})
end

---@param keys string
---@param command string
M.imap = function(keys, command, descripton)
  vim.api.nvim_buf_set_keymap(M.ui.bufnr, "i", keys, command, {})
end

return M
