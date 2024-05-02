local uv = vim.loop

---@class IrcClient
local M = {}

---@class Config
---@field server string
---@field port number
---@field nickname string
---@field username string
---@field realname string
---@field channel string
M.config = nil

---@type table
M.tx = nil

---@param sock table
---@param command string
M.send_irc_command = function(sock, command)
  sock:write(command .. "\r\n")
end

M.login_to_irc = function()
  print("Logging in as: " .. M.config.nickname)
  M.send_irc_command(M.tx, "NICK " .. M.config.nickname)
  M.send_irc_command(M.tx, "USER " .. M.config.username .. " 0 * :" .. M.config.realname)
end

M.join_channel = function()
  print("Joining channel: " .. M.config.channel)
  M.send_irc_command(M.tx, "JOIN " .. M.config.channel)
end

M.connect_to_irc = function()
  print("Connecting to: " .. M.config.server .. ":" .. M.config.port)
  local ip = M.resolve_hostname(M.config.server)
  print("Resolved IP: " .. ip)
  M.tx:connect(ip, M.config.port, function(err)
    if err then
      print("Failed to connect to IRC server: " .. err)
    else
      M.login_to_irc()
      M.join_channel()
      print("Connected to IRC server successfully")
      -- Schedule a function to be executed periodically (e.g., every 30 seconds)
      local interval = 30 * 1000 -- 30 seconds in milliseconds
      local timer
      timer = vim.defer_fn(function()
        if not M.tx:is_closing() then
          -- Send a ping message to keep the connection alive
          M.tx:write("PING #libera\n")
          print("Sent ping message")
        else
          -- Stop the timer if the connection is closed
          vim.clear_fn(timer)
        end
      end, interval)

      M.receive_data()
    end
  end)
end

M.receive_data = function()
  if not M.tx then
    print("Not connected to IRC server")
    return
  end

  M.tx:read_start(function(err, data)
    if err then
      if err.code == "ECONNRESET" then
        print("Connection to IRC server reset by the server")
        M.stop_receive_data() -- Stop receiving data
        M.close() -- Close the connection
      else
        print("Error receiving data:", err)
      end
      return
    end

    if data then
      -- Process the received data
      print("Received data:", data)
    else
      -- Socket closed
      print("Connection to IRC server closed")
    end
  end)
end

-- Add a function to stop receiving data when needed
M.stop_receive_data = function()
  if not M.tx then
    print("Not connected to IRC server")
    return
  end

  M.tx:read_stop()
end

---@param hostname string
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

---@param message string
M.send_message = function(message)
  if not M.tx then
    print("Not connected to IRC server")
    return
  end
  print("Sending message: " .. message)
  M.send_irc_command(M.tx, "PRIVMSG " .. M.config.channel .. " :" .. message)
end

M.close = function()
  M.tx:shutdown()
  M.tx:close()
  M.stop_receive_data()
  M.tx = nil
  M.config = nil
end

M.init = function(server, port, nickname, username, realname, channel)
  if M.tx then
    M.close()
  end
  M.tx = uv.new_tcp()
  M.config = {
    server = server,
    port = port,
    nickname = nickname,
    username = username,
    realname = realname,
    channel = channel,
  }
end

return M
