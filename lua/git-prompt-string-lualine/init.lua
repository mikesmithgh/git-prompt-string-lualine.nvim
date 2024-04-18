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
  if opts.prompt_prefix then
    table.insert(cmd, '--prompt-prefix=' .. opts.prompt_prefix)
  end
  if opts.prompt_suffix then
    table.insert(cmd, '--prompt-suffix=' .. opts.prompt_suffix)
  end
  if opts.ahead_format then
    table.insert(cmd, '--ahead-format=' .. opts.ahead_format)
  end
  if opts.behind_format then
    table.insert(cmd, '--behind-format=' .. opts.behind_format)
  end
  if opts.diverged_format then
    table.insert(cmd, '--diverged-format=' .. opts.diverged_format)
  end
  if opts.no_upstream_remote_format then
    table.insert(cmd, '--no-upstream-remote-format=' .. opts.no_upstream_remote_format)
  end
  if opts.color_disabled then
    table.insert(cmd, '--color-disabled')
  end
  local stdout = vim.fn.system(cmd) or '' -- replace with vim.system if/when we no longer support neovim v9
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
      vim.uv.timer_stop(M.timer)
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
