local slime_wrapper = require'slime-wrapper.core'
local M = {}


vim.g.slime_target = 'neovim'
vim.g.slime_dont_ask_default = 1
vim.g.slime_cell_delimiter = '# %%\\|#%%'
--- shellcheck does not error on merged '#%%'.
--- Both `#%%` and `# %%` are valid for any filetype.

vim.keymap.set('n', '<leader><CR>', '<Plug>SlimeSendCell')
--- For Python files, it will be overwritten with
--- 'SlimeSendCell' + 'IPythonCellNextCell'


--- The following global variable cannot be placed in ftplugin/python.lua,
--- since it should be declared before 'vim-ipython-cell' plugin is loaded.
vim.g.ipython_cell_tag = { '# %%', '#%%', '# In\\[\\(\\d\\+\\| \\)\\]:' }
--- flake8 will error on #%%: a space is necessary after #.

--- Default highlighting is linked to Folded.
--- Folded colors may be unset by default.
local aug_ipc = vim.api.nvim_create_augroup('IPythonCellHighlight', {})


function M.setup (conf)
  conf = conf or {}
  conf.keys = conf.keys or {}

  local default_colors = { bold=true, bg='#444d56', fg='#b2b2b2' }
  conf.colors = vim.tbl_extend('keep', conf.colors or {}, default_colors)

  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function ()
      vim.api.nvim_set_hl(0, 'IPythonCell', conf.colors)
    end,
    group = aug_ipc
  })

  local ss_key = conf.keys.select_session or '<Leader>ss'
  slime_wrapper._ip_key  = conf.keys.ipython_session or '<LocalLeader>ip'
  vim.keymap.set('n', ss_key, slime_wrapper.select_session)
end

return M
