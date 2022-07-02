local api = vim.api
local fn = vim.fn

local M = {}
local bt = require'bottom-term.core'


local function start_slime_session (cmd)
  if fn.bufnr('BottomTerm') < 0
      or fn.bufwinid('BottomTerm') < 0 then
    --- Why don't use `bt.term_toggle(cmd)`?
    --- Since it first executes the command, and then `conda_autoenv`
    --- switches to an appropriate environment. Before changing the
    --- environment, the command may be invalid or irrelevant.
    --- However, we can get back to `bt.term_toggle(cmd)` when
    --- functionality like `auenv.nvim` is added to Neovim settings.
    bt.term_toggle()
    --- `conda_autoenv` is available only after installing the Bash
    --- or Zsh settings and works in cooperation with project.nvim plugin.
  end

  --- NOTE: BottomtermToggle restores focus on a window from
  --- which it was called if 'bottom_term_focus_on_win' is true.
  --- Thus, the next line is necessary.
  api.nvim_set_current_win(fn.bufwinid('BottomTerm'))

  --- Trim `cmd`
  cmd = cmd:match'^%s*(.-)%s*$'

  if cmd ~= nil and cmd ~= '' then
    local tji = api.nvim_buf_get_var(0, 'terminal_job_id')
    api.nvim_chan_send(tji, cmd .. '\n')
  end

  local tab_var = api.nvim_tabpage_get_var
  local tnr = api.nvim_tabpage_get_number(0)

  if tab_var(tnr, 'bottom_term_horizontal') then
    bt.reverse_orient()
  end

  vim.g.slime_default_config = {
    jobid = tab_var(tnr, 'bottom_term_channel'),
    target_pane = '{top-right}',
  }
end


function M.select_session ()
  local shell = vim.env.SHELL:match('^.+/(.+)$')

  vim.ui.input(
    { prompt = 'Select interpreter [' .. shell .. '] ' },
    function (cmd) start_slime_session(cmd or '') end)
end


function M.start_ipython_session ()
  local cwid = api.nvim_get_current_win()
  local check = 'pip3 --disable-pip-version-check list 2>&1'
  check = check .. [[ | grep -qP 'matplotlib(?!-inline)' ]]

  local cmd = 'ipython'
  if os.execute(check) == 0 then
    cmd = cmd .. ' --matplotlib'
  end

  vim.g.bottom_term_focus_on_win = false
  start_slime_session(cmd)
  vim.g.bottom_term_focus_on_win = true

  api.nvim_set_current_win(cwid)
  vim.cmd 'stopinsert'
end


return M
