local statusline = require('tests.statusline').new(60, 'active')
local testdata = 'tmp/git-prompt-string/testdata'
local git_prompt_string_lualine = require('git-prompt-string-lualine')

local highlights = function(hint, fg)
  local colors = {
    clean = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkGreen')),
    },
    merging = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkBlue')),
    },
    no_upstream = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkGray')),
    },
    untracked = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkMagenta')),
    },
    dirty = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkRed')),
    },
    delta = {
      fg = string.format('#%06x', vim.api.nvim_get_color_by_name('DarkYellow')),
    },
  }
  return [[
highlights = {
    1: lualine_a_git_prompt_string_]] .. hint .. [[_normal = { bg = "#a89984", fg = "]] .. (fg or colors[hint].fg) .. [[" }
    2: lualine_transitional_lualine_a_git_prompt_string_]] .. hint .. [[_normal_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
    3: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
}
]]
end

describe('git-prompt-string-lualine', function()
  local opts
  before_each(function()
    opts = {
      options = {
        theme = 'gruvbox',
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }

    vim.opt.swapfile = false
    vim.cmd('bufdo bdelete')
    pcall(vim.cmd, 'tabdo tabclose')

    -- clear prompt
    git_prompt_string_lualine.prompt = nil
  end)

  it('should have git prompt: am', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'am'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('merging') .. [[
|{1:  (b69e688)|AM 1/1 }
{2:}
{3:                                       }|
]])
  end)

  it('should have git prompt: am_rebase', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'am_rebase'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('merging') .. [[
|{1:  (b69e688)|AM/REBASE 1/1 }
{2:}
{3:                                }|
]])
  end)

  it('should have git prompt: bare', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'bare'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('no_upstream') .. [[
|{1:  BARE:main }
{2:}
{3:                                              }|
]])
  end)

  it('should have git prompt: bisect', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'bisect'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('merging') .. [[
|{1:  main|BISECTING ↓[1] }
{2:}
{3:                                    }|
]])
  end)

  it('should have git prompt: cherry_pick', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'cherry_pick'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('untracked') .. [[
|{1:  main|CHERRY-PICKING *↕ ↑[1] ↓[1] }
{2:}
{3:                       }|
]])
  end)

  it('should have git prompt: cherry_pick_conflict', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'cherry_pick_conflict'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('dirty') .. [[
|{1:  main|CHERRY-PICKING|CONFLICT *↕ ↑[1] ↓[1] }
{2:}
{3:              }|
]])
  end)

  it('should have git prompt: clean', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'clean'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('clean') .. [[
|{1:  main }
{2:}
{3:                                                   }|
]])
  end)

  it('should have git prompt: conflict_diverged', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'conflict_diverged'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('delta') .. [[
|{1:  main ↕ ↑[1] ↓[1] }
{2:}
{3:                                       }|
]])
  end)

  it('should have git prompt: dirty_staged', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'dirty_staged'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('dirty') .. [[
|{1:  main * }
{2:}
{3:                                                 }|
]])
  end)

  it('should have git prompt: git_dir', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'git_dir'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('no_upstream') .. [[
|{1:  GIT_DIR! }
{2:}
{3:                                               }|
]])
  end)

  it('should have git prompt: no_upstream_remote', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'no_upstream_remote'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('no_upstream') .. [[
|{1:  main → mikesmithgh/test/main }
{2:}
{3:                           }|
]])
  end)

  it('should have git prompt: rebase_i', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'rebase_i'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('merging') .. [[
|{1:  main|REBASE-i 1/1 }
{2:}
{3:                                      }|
]])
  end)

  it('should have git prompt: tag', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'tag'),
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('no_upstream') .. [[
|{1:  (v1.0.0) }
{2:}
{3:                                               }|
]])
  end)

  -- option testing

  it('should not trim prompt prefix', function()
    opts.sections.lualine_a = {
      {
        'git_prompt_string',
        cwd = vim.fs.joinpath(testdata, 'clean'),
        trim_prompt_prefix = false,
      },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('clean') .. [[
|{1:   main }
{2:}
{3:                                                  }|
]])
  end)

  it('should use terminal colors when defined', function()
    local colors = {
      dirty = '#ff0000',
      clean = '#00ff00',
      delta = '#ffff00',
      merging = '#0000ff',
      untracked = '#ff00ff',
      no_upstream = '#ffffff',
    }
    vim.g.terminal_color_1 = colors.dirty
    vim.g.terminal_color_2 = colors.clean
    vim.g.terminal_color_3 = colors.delta
    vim.g.terminal_color_4 = colors.merging
    vim.g.terminal_color_5 = colors.untracked
    vim.g.terminal_color_8 = colors.no_upstream

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'dirty') },
    }
    require('lualine').setup(opts)
    statusline:expect(highlights('dirty', colors.dirty) .. [[
|{1:  main * }
{2:}
{3:                                                 }|
]])

    git_prompt_string_lualine.prompt = nil

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'clean') },
    }

    require('lualine').setup(opts)
    statusline:expect(highlights('clean', colors.clean) .. [[
|{1:  main }
{2:}
{3:                                                   }|
]])

    git_prompt_string_lualine.prompt = nil

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'conflict_diverged') },
    }

    require('lualine').setup(opts)
    statusline:expect(highlights('delta', colors.delta) .. [[
|{1:  main ↕ ↑[1] ↓[1] }
{2:}
{3:                                       }|
]])

    git_prompt_string_lualine.prompt = nil

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'bisect') },
    }

    require('lualine').setup(opts)
    statusline:expect(highlights('merging', colors.merging) .. [[
|{1:  main|BISECTING ↓[1] }
{2:}
{3:                                    }|
]])

    git_prompt_string_lualine.prompt = nil

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'untracked') },
    }

    require('lualine').setup(opts)
    statusline:expect(highlights('untracked', colors.untracked) .. [[
|{1:  main * }
{2:}
{3:                                                 }|
]])

    git_prompt_string_lualine.prompt = nil

    opts.sections.lualine_a = {
      { 'git_prompt_string', cwd = vim.fs.joinpath(testdata, 'no_upstream') },
    }

    require('lualine').setup(opts)
    statusline:expect(highlights('no_upstream', colors.no_upstream) .. [[
|{1:  main }
{2:}
{3:                                                   }|
]])
  end)
end)
