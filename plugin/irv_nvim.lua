print("Loading my first plugin")
vim.api.nvim_create_user_command("MyFirstFunction", require("irc_nvim").hello, {})
