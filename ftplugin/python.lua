local api = vim.api
local slime_wrapper = require'slime-wrapper.core'


local buf_nmap = function (lhs, rhs)
  require'lib.utils'.buf_keymap(0, 'n', lhs, rhs)
end

local slime_send_jump = function ()
  vim.cmd [[
    execute "normal \<Plug>SlimeSendCell"
    IPythonCellNextCell
  ]]
end


buf_nmap('<Space>ip', slime_wrapper.start_ipython_session)

buf_nmap('<CR>', ':IPythonCellExecuteCell<CR>')
buf_nmap('<Leader><CR>', slime_send_jump)
buf_nmap('<Space>n', ':IPythonCellNextCell<CR>')
buf_nmap('<Space>p', ':IPythonCellPrevCell<CR>')
buf_nmap('<Space>x', ':IPythonCellClose<CR>')
buf_nmap('<Space>00', ':IPythonCellRestart<CR>')

api.nvim_create_user_command('Run', ':IPythonCellRun', {})
api.nvim_create_user_command('RunTime', ':IPythonCellRunTime', {})
api.nvim_create_user_command('Clear', ':IPythonCellClear', {})
