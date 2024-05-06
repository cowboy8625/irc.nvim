---@module 'irc_nvim.command'
---@class Command
local M = {}

M.AWAY = "AWAY"
M.CNOTICE = "CNOTICE"
M.CPRIVMSG = "CPRIVMSG"
M.CONNECT = "CONNECT"
M.DIE = "DIE"
M.ENCAP = "ENCAP"
M.ERROR = "ERROR"
M.HELP = "HELP"
M.INFO = "INFO"
M.INVITE = "INVITE"
M.ISON = "ISON"
M.JOIN = "JOIN"
M.KICK = "KICK"
M.KILL = "KILL"
M.KNOCK = "KNOCK"
M.LINKS = "LINKS"
M.LIST = "LIST"
M.LUSERS = "LUSERS"
M.MODE = "MODE"
M.MOTD = "MOTD"
M.NAMES = "NAMES"
M.NICK = "NICK"
M.NOTICE = "NOTICE"
M.OPER = "OPER"
M.PART = "PART"
M.PASS = "PASS"
M.PING = "PING"
M.PONG = "PONG"
M.PRIVMSG = "PRIVMSG"
M.QUIT = "QUIT"
M.REHASH = "REHASH"
M.RESTART = "RESTART"
M.RULES = "RULES"
M.SERVER = "SERVER"
M.SERVICE = "SERVICE"
M.SERVLIST = "SERVLIST"
M.SQUERY = "SQUERY"
M.SQUIT = "SQUIT"
M.SETNAME = "SETNAME"
M.SILENCE = "SILENCE"
M.STATS = "STATS"
M.SUMMON = "SUMMON"
M.TIME = "TIME"
M.TOPIC = "TOPIC"
M.TRACE = "TRACE"
M.USER = "USER"
M.USERHOST = "USERHOST"
M.USERIP = "USERIP"
M.USERS = "USERS"
M.VERSION = "VERSION"
M.WALLOPS = "WALLOPS"
M.WATCH = "WATCH"
M.WHO = "WHO"
M.WHOIS = "WHOIS"
M.WHOWAS = "WHOWAS"

---@param messages string
---@return string
--- sends a message to anyone sending a private message (away [message])
M.away = function(messages)
  return M.AWAY .. " " .. messages
end

---@param nickname string
---@param channel string
---@param messages string
---@return string
--- sends a message to a user on a server in a specified channel
--- (CNOTICE [nickname] [channel] :[message])
M.cnotice = function(nickname, channel, messages)
  return M.CNOTICE .. " " .. nickname .. " " .. channel .. " :" .. messages
end

---@param nickname string
---@param channel string
---@param messages string
---@return string
--- sends a private message to a user within the same channel
--- (CPRIVMSG [nickname] [channel] :[message])
M.cprivmsg = function(nickname, channel, messages)
  return M.CPRIVMSG .. " " .. nickname .. " " .. channel .. " :" .. messages
end

---@param server string
---@param port number
---@return string
--- connects to the specified server
--- (connect [target server] [port])
M.connect = function(server, port)
  return M.CONNECT .. " " .. server .. " " .. port
end

---@return string
M.die = function()
  return M.DIE
end

-- ENCAP = "ENCAP", -- used to encapsulate commands among all servers in network :)[source] ENCAP [destination] [subcommand] [parameters])

---@param error string
---@return string
--- used by a server to report errors to other severs
--- (error [error_message])
M.error = function(error)
  return M.ERROR .. " " .. error
end

---@return string
--- accesses server help file
M.help = function()
  return M.HELP
end

---@param server string
---@return string
--- returns information about the specified server
--- (info [server])
M.info = function(server)
  return M.INFO .. " " .. server
end

---@param nickname string
---@param channel string
---@return string
--- allows non-members to join a channel if it is a closed channel
--- (invite [nickname] [channel])
M.invite = function(nickname, channel)
  return M.INVITE .. " " .. nickname .. " " .. channel
end

---@param nickname string
---@return string
--- determines if user is on a channel
--- (ison [nickname])
M.ison = function(nickname)
  return M.ISON .. " " .. nickname
end

---@param channel string
---@param password string
---@return string
--- joins channels in list
--- (join [channel] [password])
M.join = function(channel, password)
  return M.JOIN .. " " .. channel .. " " .. password
end

---@param channel string
---@param nickname string
---@param message string
---@return string
--- removes client from channel, can only be used by channel operator
--- (kick [channel] [nickname] [message])
M.kick = function(channel, nickname, message)
  return M.KICK .. " " .. channel .. " " .. nickname .. " " .. message
end

---@param nickname string
---@param comment string
---@return string
--- removes client from IRC network, can only be used by IRC operator
--- (kill [nickname] [comment])
M.kill = function(nickname, comment)
  return M.KILL .. " " .. nickname .. " " .. comment
end

---@param channel string
---@param message string
---@return string
--- sends a message to an invitation only channel to request an invite
--- (knock [channel] [message])
M.knock = function(channel, message)
  return M.KNOCK .. " " .. channel .. " " .. message
end

---@param server string
---@param mask string
---@return string
--- lists server links for specific server
--- (links [server] [server mask])
M.links = function(server, mask)
  return M.LINKS .. " " .. server .. " " .. mask
end

---@param channel string
---@return string
--- lists available channels on specified server
--- (list [channel] [server])
M.list = function(channel, server)
  return M.LIST .. " " .. channel .. " " .. server
end

---@param mask string
---@return string
--- returns statistics for network
--- (luser [mask] [server])
M.lusers = function(mask, server)
  return M.LUSERS .. " " .. mask .. " " .. server
end

---@param nickname string
---@param flags string
---@param user string
---@return string
--- set user and channel modes
--- (mode [nickname] [flags] [user]) or mode [channel] [flags] [args])
--- TODO: implement both options
M.mode = function(nickname, flags, user)
  return M.MODE .. " " .. nickname .. " " .. flags .. " " .. user
end

---@param server string
---@return string
--- shows message of the day for specified server
---  (motd [server])
M.motd = function(server)
  return M.MOTD .. " " .. server
end

---@param channels string[]
---@return string
--- lists users on specified channel
--- (names [channels])
M.names = function(channels)
  return M.NAMES .. " " .. table.concat(channels, " ")
end

---@param nickname string
---@return string
--- allows a user to change their nickname
--- (nick [nickname])
M.nick = function(nickname)
  return M.NICK .. " " .. nickname
end

---@return string
--- sends a private message, but does not allow replies
---  (notice [msgtarget] [message])
M.notice = function(msgtarget, message)
  return M.NOTICE .. " " .. msgtarget .. " " .. message
end

--- authenticates a user as an operator
--- (oper [username] [password])
---@return string
M.oper = function(username, password)
  return M.OPER .. " " .. username .. " " .. password
end

---@param channels string[]
---@param message string
--- removes a user fro the specified channels
--- (part [channels] [message])
---@return string
M.part = function(channels, message)
  return M.PART .. " " .. table.concat(channels, " ") .. " " .. message
end

---@param password string
---@return string
--- sets a connection password
---  (pass [password])
M.pass = function(password)
  return M.PASS .. " " .. password
end

---@param server string
---@return string
--- tests connection to server
--- (ping [server])
M.ping1 = function(server)
  return M.PING .. " " .. server
end

---@param server1 string
---@param server2 string
---@return string
--- tests connection to server
--- (ping [server1] [server2])
M.ping2 = function(server1, server2)
  return M.PING .. " " .. server1 .. " " .. server2
end

---@param server1 string
---@param server2 string
---@return string
--- reply to a ping command
-- (pong [server1] [server2])
M.pong = function(server1, server2)
  return M.PONG .. " " .. server1 .. " " .. server2
end

---@param target string   -- channel
---@param message string
---@return string
--- sends a message to a target
--- (privmsg [target] [message])
M.privmsg = function(target, message)
  return M.PRIVMSG .. " " .. target .. " :" .. message
end

---@param message string
---@return string
--- disconnects the user from the IRC Server sending out the specified message
--- (quit [message])
M.quit = function(message)
  return M.QUIT .. " " .. message
end

--- causes the server to check and reload configuration files, only used by IRC Operator
--- (rehash)
---@return string
M.rehash = function()
  return M.REHASH
end

---@return string
--- causes the server to restart, only used by IRC Operator
--- (restart)
M.restart = function()
  return M.RESTART
end

---@return string
--- requests the server rules
--- (rules)
M.rules = function()
  return M.RULES
end

---@param server string
---@param hopcount string
---@param info string
---@return string
--- specifies that the new connection is another IRC server
--- (server [server] [hopcount] [info])
M.server = function(server, hopcount, info)
  return M.SERVER .. " " .. server .. " " .. hopcount .. " " .. info
end

---@param nickname string
---@param reserved string
---@param distribution string
---@param type string
---@param info string
---@return string
--- registers a new service on the network
--- (service [nickname] [reserved] [distribution] [type] [reserved] [info])
M.service = function(nickname, reserved, distribution, type, info)
  return M.SERVICE
    .. " "
    .. nickname
    .. " "
    .. reserved
    .. " "
    .. distribution
    .. " "
    .. type
    .. " "
    .. reserved
    .. " "
    .. info
end

---@return string
--- lists current network services
--- (servlist)
M.servlist = function()
  return M.SERVLIST
end

---@param servicename string
---@param text string
---@return string
--- same as privmsg, but the target must be a service
--- (SQUERY <servicename> <text>)
M.squery = function(servicename, text)
  return M.SQUERY .. " " .. servicename .. " " .. text
end

---@param server string
---@param comment string
---@return string
--- specified server quits the network
--- (squit [server] [comment])
M.squit = function(server, comment)
  return M.SQUIT .. " " .. server .. " " .. comment
end

---@param real_name string
---@return string
--- changes real name for registered client connection
--- (setname [real_name])
M.setname = function(real_name)
  return M.SETNAME .. " " .. real_name
end

---@param host_mask string
---@return string
--- adds or removes host mask to prevent users from sending matched users messages
--- (silence [+/-[host_mask])
M.silence = function(host_mask)
  return M.SILENCE .. " " .. host_mask
end

---@param query string
---@param server string
---@return string
--- lists statistics about specified server
--- (stats [query] [server])
M.stats = function(query, server)
  return M.STATS .. " " .. query .. " " .. server
end

---@param user string
---@param server string
---@return string
--- sends message to host users to join IRC
--- (summon [user] [server])
M.summon = function(user, server)
  return M.SUMMON .. " " .. user .. " " .. server
end

---@param server string
---@return string
--- shows time on specified server
--- (time [server])
M.time = function(server)
  return M.TIME .. " " .. server
end

---@param channel string
---@param topic string
---@return string
--- allows the topic to be shown or set for a channel
--- (topic [channel] [topic])
M.topic = function(channel, topic)
  return M.TOPIC .. " " .. channel .. " " .. topic
end

---@param target string
---@return string
--- traces the path from local host to a server or user across the IRC network
--- (trace [target])
M.trace = function(target)
  return M.TRACE .. " " .. target
end

---@param username string
---@param hostname string
---@param servername string
---@param real_name string
---@return string
--- used to set up a connection to the IRC server
--- (user [username] [hostname] [servername] [real_name])
M.user = function(username, hostname, servername, real_name)
  return M.USER .. " " .. username .. " " .. hostname .. " " .. servername .. " :" .. real_name
end

---@param username string
---@param real_name string
---@return string
M.user2 = function(username, real_name)
  return M.USER .. username .. "0 * :" .. real_name
end

---@param nickname string
---@return string
--- shows information about host
--- (userhost [nickname])
M.userhost = function(nickname)
  return M.USERHOST .. " " .. nickname
end

---@param nickname string
---@return string
--- shows IP address of user
--- (userip [nickname])
M.userip = function(nickname)
  return M.USERIP .. " " .. nickname
end

---@param server string
---@return string
--- lists users and information for specified server
--- (users [server])
M.users = function(server)
  return M.USERS .. " " .. server
end

---@param server string
---@return string
--- shows current IRC Server version
--- (version [server])
M.version = function(server)
  return M.VERSION .. " " .. server
end

---@param message string
---@return string
--- sends message to all local operators
--- (wallops [message])
M.wallops = function(message)
  return M.WALLOPS .. " " .. message
end

---@param nickname string
---@return string
--- add or remove a client from friends list
--- (watch +/-[nickname])
M.watch = function(nickname)
  return M.WATCH .. " " .. nickname
end

---@param nickname string
---@return string
--- shows list of users matching nickname
--- (who [nickname]) or of operators (who [nickname] "o")
M.who = function(nickname)
  return M.WHO .. " " .. nickname("o")
end

---@param server string
---@param nickname string
---@return string
--- shows information about specified client on specified server
--- (whois [server] [nickname])
M.whois = function(server, nickname)
  return M.WHOIS .. " " .. server .. " " .. nickname
end

---@param nickname string
---@param count number
---@param server string
---@return string
--- shows information about a user not online, the time (count) they were
--- online on the specified server
--- (whowas [nickname] count] [server])
M.whowas = function(nickname, count, server)
  return M.WHOWAS .. " " .. nickname .. " " .. count .. " " .. server
end

return M
