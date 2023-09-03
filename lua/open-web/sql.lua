local sqlite = require('sqlite')
local strfun = require('sqlite/strfun')
local tbl = require('sqlite/tbl')

local M = {}

local histories = tbl('histories', {
  id = true,
  bookmark_id = { 'text' },
  query = { 'text' },
  last_opened = { 'integer' },
})
sqlite({
  uri = vim.fn.stdpath('data') .. '/open-web-history.sqlite3',
  histories = histories,
})

M.record = function(bookmark_id, query)
  if #query <= 0 then
    return
  end
  local joined_query = vim.fn.join(query, ' ')
  local existing_history = histories:where({ query = { bookmark_id = bookmark_id, query = joined_query } })
  if existing_history == nil then
    histories:insert({ bookmark_id = bookmark_id, query = joined_query })
  end
  histories:update({
    where = { bookmark_id = bookmark_id, query = joined_query },
    set = { last_opened = vim.fn.strftime('%s') },
  })
end

M.select = function(bookmark_id)
  return histories:get({ where = { bookmark_id = bookmark_id } }) or {}
end
return M
