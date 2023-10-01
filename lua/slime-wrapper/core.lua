local api = vim.api
local bt = require'bottom-term.core'
local M = {}

local notify = function (msg, log_lvl_key)
  local log_lvl_vals = { warning=vim.log.levels.WARN, error='error' }
  vim.notify(msg, log_lvl_vals[log_lvl_key], { title = 'slime-wrapper' })
end


local function start_slime_session (cmd)
  local bh = api.nvim_get_current_buf()
  if not bt.is_visible() then
    bt.toggle()
  end
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


local function shellcmd_capture (cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()

  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end


local function has_package (check_cmd)
  local cmd = check_cmd .. '; echo $?'
  local code = shellcmd_capture(cmd)
  return tonumber(code) == 0
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

  if not has_package(check) then
    notify('IPython is not installed! Aborting..', 'error')
    return
  end

  check = 'pip3 --disable-pip-version-check list 2>&1'
  check = check .. [[ | grep -qP 'matplotlib(?!-inline)' ]]

  local cmd = 'ipython'
  if has_package(check) then
    cmd = cmd .. ' --matplotlib'
  else
    notify('Matplotlib is not installed.', 'warning')
  end

  start_slime_session(cmd)
  api.nvim_set_current_win(caller_wid)
  vim.cmd 'stopinsert'

  bt._ephemeral.ips_exists = true
  bt.opts.focus_on_caller = true
end


return M
