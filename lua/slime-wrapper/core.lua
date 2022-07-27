local api = vim.api
local bt = require'bottom-term.core'
local M = {}


local function start_slime_session (cmd)
  local bh = api.nvim_get_current_buf()
  bt.execute(cmd)

  if vim.t.bottom_term_horizontal then
    bt.reverse_orientation()
  end

  vim.g.slime_default_config = {
    jobid = vim.t.bottom_term_channel,
    target_pane = '{top-right}',
  }

  --- Manually set `b:slime_config`. It is necessary to update
  --- when closing BottomTerm instance and spawning a new one.
  api.nvim_buf_set_var(bh, 'slime_config', vim.g.slime_default_config)
  bt._ephemeral.ss_exists = true
end


function M.select_session ()
  if bt._ephemeral and bt._ephemeral.ss_exists then
    if bt._ephemeral.ips_exists then
      bt.terminate()
    else
      bt.toggle()
      return
    end
  end

  local shell = vim.env.SHELL:match('^.+/(.+)$')

  vim.ui.input(
    { prompt = 'Select interpreter [' .. shell .. '] ' },
    function (cmd) start_slime_session(cmd or '') end)
    --- TODO: do nothing on cancel (i.e., <Esc> and <C-c>).
end


function M.start_ipython_session ()
  if bt._ephemeral and bt._ephemeral.ss_exists then
    if bt._ephemeral.ips_exists then
      bt.toggle()
      return
    else
      bt.terminate()
    end
  end

  local caller_wid = api.nvim_get_current_win()
  local check = "command -v ipython | grep -q 'ipython'"

  --- NOTE: The following checks work only when piping to grep.
  if os.execute(check) ~= 0 then
    print('IPython is not installed! Aborting..')
    return
  end

  check = 'pip3 --disable-pip-version-check list 2>&1'
  check = check .. [[ | grep -qP 'matplotlib(?!-inline)' ]]

  local cmd = 'ipython'
  if os.execute(check) == 0 then
    cmd = cmd .. ' --matplotlib'
  end

  start_slime_session(cmd)
  api.nvim_set_current_win(caller_wid)
  vim.cmd 'stopinsert'

  bt._ephemeral.ips_exists = true
  bt.opts.focus_on_caller = true
end


return M
