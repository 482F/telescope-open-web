local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
-- our picker function: colors
local colors = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'colors',
      finder = finders.new_oneshot_job({ 'find' }, opts),
      -- finder = finders.new_table({
      --   results = {
      --     { 'red', '#ffeeee' },
      --     { 'green', '#eeffee' },
      --     { 'blue', '#eeeeff' },
      --   },
      --   entry_maker = function(entry)
      --     return {
      --       value = entry,
      --       display = entry[1],
      --       ordinal = entry[1],
      --     }
      --   end,
      -- }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.notify(vim.inspect(selection))
          vim.api.nvim_put({ selection.value[2] }, '', false, true)
        end)
        return true
      end,
    })
    :find()
end

local M = {}

M.setup = function(opt)
  vim.notify(vim.inspect(opt))
end

return setmetatable(M, {
  __call = function(_, ...)
    colors(require('telescope.themes').get_dropdown({}))
  end,
})
