# 📍 git-prompt-string-lualine.nvim

Add [git-prompt-string](https://github.com/mikesmithgh/git-prompt-string) to your Neovim statusline! 

git-prompt-string-lualine.nvim is a [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) component for [git-prompt-string](https://github.com/mikesmithgh/git-prompt-string), a shell agnostic git prompt written in Go.

[![neovim: v0.9+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.9%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![git-prompt-string: v1.3+](https://img.shields.io/static/v1?style=flat-square&label=git-prompt-string&message=v1.3%2b&logo=git&labelColor=282828&logoColor=ff6961&color=ff6961)](https://github.com/mikesmithgh/git-prompt-string)
[![semantic-release: angular](https://img.shields.io/static/v1?style=flat-square&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)
[![test status](https://img.shields.io/github/actions/workflow/status/mikesmithgh/git-prompt-string-lualine.nvim/tests.yml?style=flat-square&logo=github&logoColor=c7c7c7&label=tests&labelColor=282828&event=push)](https://github.com/mikesmithgh/git-prompt-string-lualine.nvim/actions/workflows/tests.yml?query=event%3Apush)
[![nightly test status](https://img.shields.io/github/actions/workflow/status/mikesmithgh/git-prompt-string-lualine.nvim/tests.yml?style=flat-square&logo=github&logoColor=c7c7c7&label=nightly%20tests&labelColor=282828&event=schedule)](https://github.com/mikesmithgh/git-prompt-string-lualine.nvim/actions/workflows/tests.yml?query=event%3Aschedule)

![git-prompt-string-lualine](https://github.com/mikesmithgh/git-prompt-string-lualine.nvim/assets/10135646/d17ee2bf-e796-4246-9488-18a938a7d807)

## 📚 Prerequisites

- Neovim [v0.9+](https://github.com/neovim/neovim/releases)
- git-prompt-string [v1.3+](https://github.com/mikesmithgh/git-prompt-string)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)

## 📦 Installation

<details>

<summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
  {
    'mikesmithgh/git-prompt-string-lualine.nvim',
    enabled = true,
    lazy = true,
  }
```

</details>
<details>

<summary>Using <a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

```lua
  use({
    'mikesmithgh/git-prompt-string-lualine.nvim',
    disable = false,
    opt = true,
  })
```

</details>
<details>

<summary>Using Neovim's built-in package support <a href="https://neovim.io/doc/user/usr_05.html#05.4">pack</a></summary>

```bash
mkdir -p "$HOME/.local/share/nvim/site/pack/mikesmithgh/start/"
cd $HOME/.local/share/nvim/site/pack/mikesmithgh/start
git clone git@github.com:mikesmithgh/git-prompt-string-lualine.nvim
mkdir -p "$HOME/.config/nvim"
echo "require('git-prompt-string-lualine')" >> "$HOME/.config/nvim/init.lua"
```

</details>

## 🛠️ Setup

- Install [git-prompt-string](https://github.com/mikesmithgh/git-prompt-string) following the [Installation](https://github.com/mikesmithgh/git-prompt-string?tab=readme-ov-file#-installation) instructions.
- Install [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) following the [Installation](https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#installation) instructions.

## ⚙️ Configuration

To add git-prompt-string in a section of lualine, simply use the component name `git_prompt_string`. 

> [!IMPORTANT]\
> Make sure to use underscores in the component name `git_prompt_string`. Do not use hyphens `git-prompt-string`.
> 

For example, the following replaces the default lualine setup's component `branch` with `git_prompt_string`.

```lua
require('lualine').setup({
  sections = {
    lualine_b = { 'git_prompt_string', 'diff', 'diagnostics' },
  },
})
```

### Configuration Options

```lua
{
  trim_prompt_prefix = true, -- remove whitespace from beginning of prompt prefix
  -- git-prompt-string configuration options, see https://github.com/mikesmithgh/git-prompt-string?tab=readme-ov-file#configuration-options
  prompt_config = {
    prompt_prefix = nil,
    prompt_suffix = nil,
    ahead_format = nil,
    behind_format = nil,
    diverged_format = nil,
    no_upstream_remote_format = nil,
    color_disabled = false,
    color_clean = { fg = vim.g.terminal_color_2 or 'DarkGreen' },
    color_delta = { fg = vim.g.terminal_color_3 or 'DarkYellow' },
    color_dirty = { fg = vim.g.terminal_color_1 or 'DarkRed' },
    color_untracked = { fg = vim.g.terminal_color_5 or 'DarkMagenta' },
    color_no_upstream = { fg = vim.g.terminal_color_8 or 'DarkGray' },
    color_merging = { fg = vim.g.terminal_color_4 or 'DarkBlue' },
  },
}
```

By default, git-prompt-string-lualine.nvim attempts to use the default Neovim terminal colors, if they are defined. 
Otherwise, a default Neovim color is selected. See the configuration snippet above for more details.

The colors for git-prompt-string-lualine.nvim must be compatible with lualine.nvim. Below is a snippet of instructions from 
lualine.nvim's [README](https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#installation) regarding valid color formats.

```lua
-- Defines a custom color for the component:
--
-- 'highlight_group_name' | { fg = '#rrggbb'|cterm_value(0-255)|'color_name(red)', bg= '#rrggbb', gui='style' } | function
-- Note:
--  '|' is synonymous with 'or', meaning a different acceptable format for that placeholder.
-- color function has to return one of other color types ('highlight_group_name' | { fg = '#rrggbb'|cterm_value(0-255)|'color_name(red)', bg= '#rrggbb', gui='style' })
-- color functions can be used to have different colors based on state as shown below.
--
-- Examples:
--   color = { fg = '#ffaa88', bg = 'grey', gui='italic,bold' },
--   color = { fg = 204 }   -- When fg/bg are omitted, they default to the your theme's fg/bg.
--   color = 'WarningMsg'   -- Highlight groups can also be used.
--   color = function(section)
--      return { fg = vim.bo.modified and '#aa3355' or '#33aa88' }
--   end,
```

The following is an example of how you could modify the configuration options of the `git_prompt_string` component.

```lua
require('lualine').setup({
  sections = {
    lualine_b = {
      {
        'git_prompt_string',
        trim_prompt_prefix = false,
        prompt_config = {
          prompt_prefix = 'git(',
          prompt_suffix = ')',
          color_clean = { fg = 'LightGreen' },
          color_delta = 'WarningMsg',
          color_dirty = function()
            return 'ErrorMsg'
          end,
          color_untracked = { fg = '#b16286', bg = 'Black' },
          color_no_upstream = { fg = '#c7c7c7' },
          color_merging = { fg = 4 },
        },
      },
    },
  },
})
```

