# Slime-Wrapper to Mimic Jupyter in Vim

This project is wrapper around the two plugins:  
* [vim-slime](https://github.com/jpalardy/vim-slime)
* [vim-ipython-cell](https://github.com/hanschen/vim-ipython-cell)

The new functionality that the wrapper enables is an easier launching and
terminating process of an IPython session, subjectively better mappings, and
some bug fixes, that further might be incorporated in [vim-ipython-cell](
https://github.com/hanschen/vim-ipython-cell). However, the better decision is
to re-write the latter in Lua or at least VimL (see 
[problems](#problems-with-dependencies)).


## Installation

With [**Packer**](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'rxi/json.lua',
  run = 'mkdir -p lua/json && mv json.lua lua/json/init.lua',
}

use {
  'lukoshkin/slime-wrapper.nvim',
  requires = {
    'jpalardy/vim-slime',
    'hanschen/vim-ipython-cell',
    'lukoshkin/bterm.nvim',
    'lukoshkin/auenv.nvim',
  },
  config = function ()
    require'auenv'.setup()
    require'bottom-term'.setup()

    --- Installing with defaults
    -- require'slime-wrapper'.setup()

    --- Your custom configuration
    require'slime-wrapper'.setup {
      keys = {
        select_session = '<Leader>ss',
        ipython_session = '<LocalLeader>ip',
      },
      --- Cell delimiter
      colors = {
        bold=true,
        bg='#444d56',
        fg='#b2b2b2'
      },
    }
  end
}
```

For better customization and understanding of the underlying dependencies,  
visit [bterm.nvim](https://github.com/lukoshkin/bterm.nvim) and
[auenv.nvim](https://github.com/lukoshkin/auenv.nvim) sites.


## Mappings

Valid only for Python files.

`<CR>` - execute a cell.  
`<Leader><CR>` - execute a cell (verbose: using `%cpaste`).  
`<LocalLeader><CR>` - execute a cell and jump to the next cell.

`<LocalLeader>n` - jump to the next cell.  
`<LocalLeader>p` - jump to the previous cell.  
`<LocalLeader>x` - close all plots (send `plt.close('all')`).  
`<LocalLeader>l` - clear IPython screen.  
`<LocalLeader>00` - restart IPython session.

`:Run` - run the whole script.  
`:RunTime` - run the whole script and measure the execution time.  
`:Clear` - clear IPython screen.

---

**Select slime session**&ensp; ─ &ensp;`<Leader>ss` &emsp;_(works for any
filetype)_ <br> **Start IPython session**&ensp; ─ &ensp;`<LocalLeader>ip`

**Cell delimiters:**
`# %%`,&ensp; `#%%`,&ensp; `'# In [ ]`,&ensp; `# In [<num>]`  
The first two delimiters are valid for any filetype.

---

_NOTE:_ one can map `<LocalLeader>` to `<Space>` :  
`vim.g.maplocalleader = '<Space>'`


## Problems with Dependencies

* After wrapping with `slime-wrapper.nvim`, the chain of function calls looks
  like this:

  **Lua** (slime-wrapper) **→ Python** (vim-ipython-cell) **→ VimL → C**

  If not building on top of existing plugins but writing from scratch, it is
  possible to reduce the number of elements in the chain to **2**. Currently,
  it is not a goal, just a remark.

* `IPythonCell...` commands are available for any filetype. Not just Python ft.
