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
  local stdout = vim.system(cmd):wait().stdout or ''
  local json = vim.json.decode(stdout == '' and '{}' or stdout)
  json.color = json.color or ''
  json.promptPrefix = json.promptPrefix or ''
  json.branchInfo = json.branchInfo or ''
  json.branchStatus = json.branchStatus or ''
  json.promptSuffix = json.promptSuffix or ''
  return json
end

M.set_prompt = function(cb, delay)
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
      if type(cb) == 'function' then
        cb()
      end
    end, delay or 500)
  end)
end

return M
