---@class Module
local M = {}

---@param sock table
---@param command string
M.send_irc_command = function(sock, command)
  sock:write(command .. "\r\n")
end

---@param config table
---@param client table
M.login_to_irc = function(config, client)
  print("Logging in as: " .. config.nickname)
  M.send_irc_command(client, "NICK " .. config.nickname)
  M.send_irc_command(client, "USER " .. config.username .. " 0 * :" .. config.realname)
end

---@param config table
---@param client table
M.join_channel = function(config, client)
  print("Joining channel: " .. config.channel)
  M.send_irc_command(client, "JOIN " .. config.channel)
end

---@param config table
---@param client table
M.connect_to_irc = function(config, client)
  print("Connecting to: " .. config.server .. ":" .. config.port)
  local ip = M.resolve_hostname("irc.libera.chat")
  client:connect(ip, config.port, function(err)
    if err then
      print("Failed to connect to IRC server: " .. err)
    else
      print("Connected to IRC server successfully")
    end
  end)
end

M.resolve_hostname = function(hostname)
  local command = "nslookup " .. hostname
  local handle = io.popen(command)
  assert(handle, "Failed to execute command: " .. command)
  local output = handle:read("*a")
  handle:close()

  -- Parse the output to extract the IP address
  local ip = output:match("Address: ([^\n]+)")

  return ip
end

return M
