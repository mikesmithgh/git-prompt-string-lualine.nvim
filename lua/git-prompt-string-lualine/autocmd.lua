local git_prompt_string_lualine = require('git-prompt-string-lualine')
local M = {}

local function notify_fs_err(msg, err_name, err_msg)
  vim.notify(
    string.format(
      'git-prompt-string-lualine.nvim: %s, err_name: %s, err_msg: %s',
      msg,
      err_name or 'undefined',
      err_msg or 'undefined'
    ),
    vim.log.levels.ERROR,
    {}
  )
end

local handle_dir_change = function(fs_handle)
  local success, err_name, err_msg = fs_handle:stop()
  if not success then
    notify_fs_err('error stopping fs_handle', err_name, err_msg)
    return
  end

  if git_prompt_string_lualine.prompt.branch_info == '' then
    return
  end

  local flags = {
    watch_entry = true, -- true = when dir, watch dir inode, not dir content
    stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
    recursive = true, -- true = watch dirs inside dirs
  }

  ---@diagnostic disable-next-line: param-type-mismatch
  success, err_name, err_msg = fs_handle:start('.', flags, function()
    git_prompt_string_lualine.set_prompt_and_refresh()
  end)
  if not success then
    notify_fs_err('error starting fs_handle', err_name, err_msg)
  end
end

M.setup = function()
  local fs_handle, err_name, err_msg = vim.uv.new_fs_event()
  if not fs_handle then
    notify_fs_err('error creating fs_event', err_name, err_msg)
    return
  end

  local refresh_events = {
    DirChanged = {
      pattern = '*',
      callback = function()
        handle_dir_change(fs_handle)
      end,
    },
    FileChangedShellPost = { pattern = '*' },
    FocusGained = { pattern = '*' },
    FocusLost = { pattern = '*' },
    SessionLoadPost = { pattern = '*' },
    VimEnter = { pattern = '*' },
    User = { pattern = { 'FugitiveChanged', 'VeryLazy' } },
  }

  for event, opts in pairs(refresh_events) do
    vim.api.nvim_create_autocmd(event, {
      group = vim.api.nvim_create_augroup('GitPromptString', { clear = false }),
      pattern = opts.pattern,
      callback = function(ev)
        git_prompt_string_lualine.set_prompt_and_refresh(function()
          local refresh_event = refresh_events[ev.event]
          if refresh_event and type(refresh_event.callback) == 'function' then
            refresh_event.callback()
          end
        end, 0)
      end,
    })
  end
end

return M
