-- main module file
local module = require("irc_nvim.module")
local uv = vim.loop

---@class Config
---@field opt table Your config option
local config = {
  opt = {
    server = "irc.libera.chat",
    port = 6667,
    nickname = "test-neovim",
    username = "test-neovim",
    realname = "Test-Neovim",
    channel = "#dailycodex",
  },
}

---@class Module
local M = {}
---@type Config
M.config = config

M.tx = uv.new_tcp()

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

---@param self Module
M.connect = function(self)
  module.connect_to_irc(self.config.opt, self.tx)
end

---@param self Module
M.join = function(self)
  module.join_channel(self.config.opt, self.tx)
end

---@param self Module
M.login = function(self)
  module.login_to_irc(self.config.opt, self.tx)
end

M.irc = function()
  print(vim.inspect(M.config))
  M:connect()
  vim.cmd('autocmd ExitPre * :lua require("irc_nvim").quit()')
  M:login()
  M:join()
end

M.quit = function()
  uv.close(M.tx)
end

return M
