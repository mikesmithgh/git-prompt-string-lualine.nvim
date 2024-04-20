local lualine_require = require('lualine_require')
local M = lualine_require.require('lualine.component'):extend()
local git_prompt_string_autocmd = require('git-prompt-string-lualine.autocmd')
local git_prompt_string_lualine = require('git-prompt-string-lualine')

function M:init(options)
  local default_options = {
    colored = true,
    icons_enabled = true,
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
    cwd = nil, -- not likely to be used, primarily used for testing
  }

  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  self.highlights = {
    clean = {},
    delta = {},
    dirty = {},
    untracked = {},
    no_upstream = {},
    merging = {},
  }
  if self.options.colored then
    self.highlights = {
      clean = self:create_hl(self.options.prompt_config.color_clean, 'clean'),
      delta = self:create_hl(self.options.prompt_config.color_delta, 'delta'),
      dirty = self:create_hl(self.options.prompt_config.color_dirty, 'dirty'),
      untracked = self:create_hl(self.options.prompt_config.color_untracked, 'untracked'),
      no_upstream = self:create_hl(self.options.prompt_config.color_no_upstream, 'no_upstream'),
      merging = self:create_hl(self.options.prompt_config.color_merging, 'merging'),
    }
  end

  git_prompt_string_autocmd.setup()
  git_prompt_string_lualine.setup(self.options)
end

function M:update_status()
  if git_prompt_string_lualine.prompt == nil then
    git_prompt_string_lualine.prompt = git_prompt_string_lualine.git_prompt_string_json()
    -- trigger autocmd to start watching directory for changes
    vim.api.nvim_exec_autocmds('DirChanged', { group = 'GitPromptString' })
  end
  local prompt = git_prompt_string_lualine.prompt or {}
  if self.options.colored and prompt.color ~= '' then
    self.options.icon_color_highlight = self.highlights[prompt.color]
    self.options.color_highlight = self.highlights[prompt.color]
  end
  if self.options.trim_prompt_prefix then
    prompt.prompt_prefix = prompt.prompt_prefix:gsub('^%s+', '')
  end
  return prompt.prompt_prefix .. prompt.branch_info .. prompt.branch_status .. prompt.prompt_suffix
end

return M
