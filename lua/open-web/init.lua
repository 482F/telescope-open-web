local util = require('open-web/util')
local sql = require('open-web/sql')
local pickers = require('telescope/pickers')
local finders = require('telescope/finders')
local conf = require('telescope/config').values
local actions = require('telescope/actions')
local action_state = require('telescope/actions/state')

local M = {}

local root_tbl = {}

M.open_bookmarks = function(tbl, opts)
  opts = opts or {}
  tbl = tbl or root_tbl
  pickers
    .new(opts, {
      prompt_title = 'open-web',
      finder = finders.new_table({
        results = tbl,
        entry_maker = function(entry)
          local display = entry.name
          if entry.desc ~= nil then
            display = display .. ': ' .. entry.desc
          end

          return {
            value = entry,
            display = display,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local value = action_state.get_selected_entry().value
          if value.model == nil then
            M.open_bookmarks(value, opts)
          else
            M.open_bookmark(value, opts)
          end
        end)
        return true
      end,
    })
    :find()
end

M.open_bookmark = function(bookmark, opts)
  local histories = sql.select(bookmark.id)
  histories = vim.fn.sort(histories, function(h1, h2)
    local o1 = h1.last_opened
    local o2 = h2.last_opened
    if o1 == o2 then
      return 0
    elseif o1 < o2 then
      return 1
    else
      return -1
    end
  end)
  pickers
    .new(opts, {
      prompt_title = bookmark.name,
      finder = finders.new_table({
        results = histories,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.query,
            ordinal = entry.query,
          }
        end,
      }),
      sorter = require('telescope/sorters').fuzzy_with_index_bias(opts),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '', M.actions.get_direct_searcher(bookmark)) -- Ctrl-*
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selected = action_state.get_selected_entry()
          if selected == nil then
            M.open_web(bookmark.id, bookmark.top, {})
          else
            M.open_web(bookmark.id, bookmark.model, vim.fn.split(selected.value.query, ' '))
          end
        end)
        return true
      end,
    })
    :find()
end

M.open_web = function(id, model, query)
  sql.record(id, query)
  util.search(model, query)
end

M.setup = function(opt)
  local ext_config = opt.ext_config
  local config = opt.config
  root_tbl = ext_config.bookmarks
end

M.actions = {}

M.actions.get_direct_searcher = function(bookmark)
  return function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local prompt = current_picker:_get_prompt()

    local model = bookmark.model
    if prompt == '' then
      model = bookmark.top
    end
    M.open_web(bookmark.id, model, { prompt })
    actions.close(prompt_bufnr)
  end
end

return setmetatable(M, {
  __call = function(_, ...)
    M.open_bookmarks(nil)
  end,
})
