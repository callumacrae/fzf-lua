local core = require "fzf-lua.core"
local shell = require "fzf-lua.shell"
local config = require "fzf-lua.config"
local actions = require "fzf-lua.actions"

local function get_current_colorscheme()
  if vim.g.colors_name then
    return vim.g.colors_name
  else
    return 'default'
  end
end

local M = {}

M.colorschemes = function(opts)

  opts = config.normalize_opts(opts, config.globals.colorschemes)
  if not opts then return end

  local prev_act = shell.action(function (args)
    if opts.live_preview and args then
      local colorscheme = args[1]
      vim.cmd("colorscheme " .. colorscheme)
    end
  end)

  local current_colorscheme = get_current_colorscheme()
  local current_background = vim.o.background
  local colors = vim.list_extend(opts.colors or {}, vim.fn.getcompletion('', 'color'))

  -- must add ':nohidden' or fzf ignore the preview action
  -- disabling our live preview of colorschemes
  opts.fzf_opts['--preview'] = prev_act
  opts.fzf_opts['--no-multi'] = ''
  opts.fzf_opts['--preview-window'] = 'nohidden:right:0'

  core.fzf_wrap(opts, colors, function(selected)

    -- reset color scheme if live_preview is enabled
    -- and nothing or non-default action was selected
    if opts.live_preview and (not selected or #selected[1]>0) then
      vim.o.background = current_background
      vim.cmd("colorscheme " .. current_colorscheme)
      vim.o.background = current_background
    end

    if selected then
      actions.act(opts.actions, selected)
    end

    if opts.post_reset_cb then
      opts.post_reset_cb()
    end

  end)()

end

return M
