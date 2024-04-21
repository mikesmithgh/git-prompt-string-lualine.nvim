local M = {
  prompt = nil,
  timer = nil,
}

local opts = {}

M.setup = function(o)
  if o then
    opts = o
  end
end

M.git_prompt_string_json = function()
  local cmd = {
    'git-prompt-string',
    '--json',
    '--color-clean=clean',
    '--color-delta=delta',
    '--color-dirty=dirty',
    '--color-untracked=untracked',
    '--color-no-upstream=no_upstream',
    '--color-merging=merging',
  }
  local prompt_config = opts.prompt_config
  if prompt_config.prompt_prefix then
    table.insert(cmd, '--prompt-prefix=' .. prompt_config.prompt_prefix)
  end
  if prompt_config.prompt_suffix then
    table.insert(cmd, '--prompt-suffix=' .. prompt_config.prompt_suffix)
  end
  if prompt_config.ahead_format then
    table.insert(cmd, '--ahead-format=' .. prompt_config.ahead_format)
  end
  if prompt_config.behind_format then
    table.insert(cmd, '--behind-format=' .. prompt_config.behind_format)
  end
  if prompt_config.diverged_format then
    table.insert(cmd, '--diverged-format=' .. prompt_config.diverged_format)
  end
  if prompt_config.no_upstream_remote_format then
    table.insert(cmd, '--no-upstream-remote-format=' .. prompt_config.no_upstream_remote_format)
  end
  if prompt_config.color_disabled then
    table.insert(cmd, '--color-disabled')
  end
  local stdout = ''
  local job_id
  -- replace with vim.system if/when we no longer support neovim v9
  local status, result = pcall(vim.fn.jobstart, cmd, {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      stdout = table.concat(data, '')
    end,
  })

  if status then
    job_id = result
  else
    vim.notify_once('git-prompt-string-lualine.nvim: ERROR ' .. result, vim.log.levels.ERROR, {})
    return { error = result, color = 'error' }
  end

  vim.fn.jobwait({ job_id })
  local json = vim.json.decode(stdout == '' and '{}' or stdout)
  return {
    color = json.color or '',
    prompt_prefix = json.promptPrefix or '',
    branch_info = json.branchInfo or '',
    branch_status = json.branchStatus or '',
    prompt_suffix = json.promptSuffix or '',
  }
end

M.set_prompt = function(callback, delay)
  vim.schedule(function()
    if not M.prompt then
      M.prompt = M.git_prompt_string_json()
      return
    end
    if M.timer then
      vim.uv.timer_stop(M.timer) -- change loop to uv if/when we no longer support neovim v9
      M.timer = nil
    end
    M.timer = vim.defer_fn(function()
      M.prompt = M.git_prompt_string_json()
      M.timer = nil
      if type(callback) == 'function' then
        callback()
      end
    end, delay or 500)
  end)
end

M.set_prompt_and_refresh = function(callback, delay)
  M.set_prompt(function()
    if type(callback) == 'function' then
      callback()
    end
    require('lualine').refresh()
  end, delay)
end

return M
