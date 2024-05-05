# irc.nvim

#### Lazy

```lua
  {
    'cowboy8625/irc.nvim',
    config = function()
      local cowboy8625 = 'cowboy8625'
      local irc = require 'irc.nvim'
      irc.setup {
        opt = {
          server = 'irc.libera.chat',
          port = 6667,
          nickname = cowboy8625,
          username = cowboy8625,
          realname = cowboy8625,
          password = os.getenv 'IRC_PASSWORD',
          hide = {
            'JOIN',
            'PART',
            'QUIT',
          },
          channels = {
            'libera\\.chat',
            '#dailycodex',
          },
        },
      }
    end,
  },
```
