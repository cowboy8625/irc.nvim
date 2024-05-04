---@module 'utils.models'

---@class Utils
---@field map function fun(array: T[], func: fun(arg: T): U): U[]
---@field filter function fun(array: T[], predicate: fun(arg: T): boolean): T[]
M = {}

---@generic T, U
---@param array T[]
---@param func fun(arg: T): U
---@return U[]
M.map = function(array, func)
  local result = {}
  for i, v in ipairs(array) do
    result[i] = func(v)
  end
  return result
end

---@generic T
---@param array T[]
---@param predicate fun(arg: T): boolean
---@return T[]
M.filter = function(array, predicate)
  local result = {}
  for _, v in ipairs(array) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

return M
