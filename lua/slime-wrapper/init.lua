local slime_wrapper = require'slime-wrapper.core'


vim.g.slime_target = 'neovim'
vim.g.slime_dont_ask_default = 1
vim.g.slime_cell_delimiter = '#%%'
--- shellcheck doesn't error on merged '#%%' (this is why this tag's default).

--- flake8 will error on #%% to leave a space after '#'.
vim.g.ipython_cell_tag = { '# %%', '#%%', '# In\\[\\(\\d\\+\\| \\)\\]:' }
vim.g.slime_python_ipython = 1

vim.keymap.set('n', '<leader><CR>', '<Plug>SlimeSendCell')
vim.keymap.set('<leader>ss', slime_wrapper.select_session)
--- For Python files it will be overwritten with
--- 'SlimeSendCell' + 'IPythonCellNextCell'


local aug_ipc = vim.api.nvim_create_augroup(
  'IPythonCellHighlight', {clear=true})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function ()
    vim.api.nvim_set_hl(0, 'IPythonCell', {
      bold=true,
      bg='#444d56',
      fg='darkgrey'})
  end,
  group = aug_ipc
})
