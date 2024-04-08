local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require({
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
})
local M = lualine_require.require('lualine.component'):extend()
local git_prompt_string_lualine = require('git-prompt-string-lualine')

local default_options = {
  colored = true,
  icons_enabled = true,
  trim_prompt_prefix = true, -- remove whitespace from beginning of prompt prefix
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

function M:init(options)
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

  local refresh_events = {
    'DirChanged',
    'FileChangedShellPost',
    'FocusGained',
    'FocusLost',
    'SessionLoadPost',
    'VimEnter',
  }

  local refresh_user_events = {
    'FugitiveChanged',
    'VeryLazy',
  }

  vim.api.nvim_create_augroup('GitPromptStringLualineRefresh', { clear = true })
  modules.utils.define_autocmd(
    table.concat(refresh_events, ','),
    '*',
    [[lua require('git-prompt-string-lualine').set_prompt()]],
    'GitPromptStringLualineRefresh'
  )
  vim.api.nvim_create_augroup('GitPromptStringLualineUserRefresh', { clear = true })
  for _, pattern in pairs(refresh_user_events) do
    modules.utils.define_autocmd(
      'User',
      pattern,
      [[lua require('git-prompt-string-lualine').set_prompt()]],
      'GitPromptStringLualineUserRefresh'
    )
  end

  git_prompt_string_lualine.setup(self.options.prompt_config)

  local handle, err_name, err_msg = vim.uv.new_fs_event()
  if not handle then
    vim.notify(
      string.format(
        'git-prompt-string-lualine.nvim: %s, err_name: %s, err_msg: %s',
        'error creating fs_event',
        err_name or 'undefined',
        err_msg or 'undefined'
      ),
      vim.log.levels.ERROR,
      {}
    )
    return
  end

  local flags = {
    watch_entry = true, -- true = when dir, watch dir inode, not dir content
    stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
    recursive = true, -- true = watch dirs inside dirs
  }

  -- TODO: on dir change, change path for event watch
  -- TODO: only watch dir if it is a git repo, ie., git-prompt-string returns a value the first time

  ---@diagnostic disable-next-line: param-type-mismatch
  vim.uv.fs_event_start(
    handle,
    '.',
    flags,
    vim.schedule_wrap(function()
      git_prompt_string_lualine.set_prompt(function()
        require('lualine').refresh()
      end)
    end)
  )
end

function M.update_status(self)
  if git_prompt_string_lualine.prompt == nil then
    git_prompt_string_lualine.prompt = git_prompt_string_lualine.git_prompt_string_json()
  end
  local prompt = git_prompt_string_lualine.prompt or {}
  if self.options.colored and prompt.color ~= '' then
    self.options.icon_color_highlight = self.highlights[prompt.color]
    self.options.color_highlight = self.highlights[prompt.color]
  end

  if self.options.trim_prompt_prefix then
    prompt.promptPrefix = prompt.promptPrefix:gsub('^%s+', '')
  end
  return prompt.promptPrefix .. prompt.branchInfo .. prompt.branchStatus .. prompt.promptSuffix
end

return M
