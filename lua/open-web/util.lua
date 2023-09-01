local M = {}

local escape = function(target)
  local escapes = {
    [' '] = '%%20',
    ['<'] = '%%3C',
    ['>'] = '%%3E',
    ['#'] = '%%23',
    ['%'] = '%%25',
    ['+'] = '%%2B',
    ['{'] = '%%7B',
    ['}'] = '%%7D',
    ['|'] = '%%7C',
    ['\\'] = '%%5C',
    ['^'] = '%%5E',
    ['~'] = '%%7E',
    ['['] = '%%5B',
    [']'] = '%%5D',
    ['‘'] = '%%60',
    [';'] = '%%3B',
    ['/'] = '%%2F',
    ['?'] = '%%3F',
    [':'] = '%%3A',
    ['@'] = '%%40',
    ['='] = '%%3D',
    ['&'] = '%%26',
    ['$'] = '%%24',
  }
  return target:gsub('.', escapes)
end

M.search = function(model, queries)
  local target = model
  for key, value in pairs(queries) do
    target = target:gsub('%${' .. key .. '}', escape(value))
  end
  local open_cmd = vim.fn.extend({ 'cmd.exe', '/c', 'start' }, { target })

  vim.fn.jobstart(open_cmd, { detach = true })
end

return M
