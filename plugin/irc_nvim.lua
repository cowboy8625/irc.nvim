local irc = require("irc_nvim")
vim.api.nvim_create_user_command("Irc", irc.irc, {})
