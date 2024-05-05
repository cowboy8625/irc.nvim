local irc = require("irc_nvim")
vim.api.nvim_create_user_command("IrcInit", irc.irc, {})
vim.api.nvim_create_user_command("IrcOpenUi", irc.open_ui, {})
vim.api.nvim_create_user_command("IrcCloseUi", irc.close_ui, {})
