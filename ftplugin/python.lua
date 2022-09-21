local fn = vim.fn
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


--- To slightly extend the functionality, we redefine the function of
--- highlighting cell delimiters (namely, `g:slime_wrapper_hl_pat`
--- is introduced).
vim.cmd [[
  function! UpdateCellHighlight()
    if g:ipython_cell_highlight_cells == 0
      return
    endif

    if index(g:ipython_cell_highlight_cells_ft, &filetype) >= 0
      if !exists('w:ipython_cell_match')
        let w:ipython_cell_match=matchadd('IPythonCell', g:slime_wrapper_hl_pat)
      endif
    else
      if exists('w:ipython_cell_match')
        call matchdelete(w:ipython_cell_match)
        unlet w:ipython_cell_match
      endif
    endif
  endfunction
]]


local buf_nmap = function (lhs, rhs)
  api.nvim_buf_set_keymap(0, 'n', lhs, rhs, {noremap=true, silent=true})
end

function _G.clear_trip ()
  local cwid = api.nvim_get_current_win()
  vim.cmd 'IPythonCellClear'
  api.nvim_set_current_win(fn.bufwinid(vim.t.bottom_term_name))
  vim.defer_fn(function ()
    api.nvim_set_current_win(cwid)
  end, 50)  -- small delay to gain focus
end

buf_nmap(slime_wrapper._ip_key, ':IPythonSession<CR>')

buf_nmap('<Leader><CR>', ':IPythonCellExecuteCellVerbose<CR>')
buf_nmap('<LocalLeader><CR>', ':IPythonCellExecuteCellJump<CR>')
buf_nmap('<CR>', ':IPythonCellExecuteCell<CR>')

buf_nmap('<LocalLeader>n', ':IPythonCellNextCell<CR>')
buf_nmap('<LocalLeader>p', ':IPythonCellPrevCell<CR>')
buf_nmap('<LocalLeader>x', ':IPythonCellClose<CR>')
buf_nmap('<LocalLeader>l', ':call v:lua.clear_trip()<CR>')
buf_nmap('<LocalLeader>00', ':IPythonCellRestart<CR>')

api.nvim_create_user_command('Run', ':IPythonCellRun', {})
api.nvim_create_user_command('RunTime', ':IPythonCellRunTime', {})
api.nvim_create_user_command('Clear', ':IPythonCellClear', {})
