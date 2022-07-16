local api = vim.api
local slime_wrapper = require'slime-wrapper.core'


vim.g.slime_python_ipython = 1

api.nvim_create_user_command(
  'IPythonSession',
  function ()
    slime_wrapper.start_ipython_session()
  end,
  {}
)


local buf_nmap = function (lhs, rhs)
  api.nvim_buf_set_keymap(0, 'n', lhs, rhs, {noremap=true, silent=true})
end

buf_nmap(slime_wrapper._ip_key, ':IPythonSession<CR>')

buf_nmap('<Leader><CR>', ':IPythonCellExecuteCellVerbose<CR>')
buf_nmap('<LocalLeader><CR>', ':IPythonCellExecuteCellJump<CR>')
buf_nmap('<CR>', ':IPythonCellExecuteCell<CR>')

buf_nmap('<LocalLeader>n', ':IPythonCellNextCell<CR>')
buf_nmap('<LocalLeader>p', ':IPythonCellPrevCell<CR>')
buf_nmap('<LocalLeader>x', ':IPythonCellClose<CR>')
buf_nmap('<LocalLeader>l', ':IPythonCellClear<CR>')
buf_nmap('<LocalLeader>00', ':IPythonCellRestart<CR>')

api.nvim_create_user_command('Run', ':IPythonCellRun', {})
api.nvim_create_user_command('RunTime', ':IPythonCellRunTime', {})
api.nvim_create_user_command('Clear', ':IPythonCellClear', {})
