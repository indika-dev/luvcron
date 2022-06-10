local cron = require("user.cron")

local scheduler = {}

scheduler.config = function()
  local c1 = cron.after(5, function()
    vim.api.nvim_command('colorscheme kanagawa')
  end)
  local timer = vim.loop.new_timer()
  timer:start(0, 1000, vim.schedule_wrap(function()
    vim.api.nvim_command('echomsg "tick"')
    if c1:update(1) then timer:close() end
  end))
end

return scheduler
