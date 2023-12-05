local insert = table.insert
local concat = table.concat
local format = string.format
local rep = string.rep

local _M = {}

function _M:emit(fmt, ...)
	if type(fmt) == "function" then
		insert(self._code, { self._indent, fmt, ... })
	else
		insert(self._code, rep("  ", self._indent) .. format(fmt, ...))
	end
end

function _M:block(head, ...)
	local save_indent = self._indent
	local args, done, generator = {...}

	head = {head}
	for i,v in ipairs(args) do
		if type(v) == "function" then
			generator, done = v, args[i+1]
			break
		end
		head[#head+1] = v
	end

	self:emit(format(unpack(head)))
	self._indent = save_indent + 1

	generator()

	self._indent = save_indent

	if done ~= false then
		self:emit(type(done) == "string" and done or "end")
	end
end

function _M:code()
	for line, code in ipairs(self._code) do
		if type(code) == "table" then
			local _code  = self._code
			self._code, self._indent = {}, code[1]

			code[2](unpack(code, 3))

			_code[line] = concat(self._code, "\n")
			self._code = _code
		end
	end

	return concat(self._code, "\n")
end

function _M:load(...)
	return load(self:code())(...)
end

function _M:dump(strip)
	return string.dump(self:load(), strip or true)
end

local mt = {
	__index = _M,
	__call = function(t, ...)
		t.emit(t, ...)
	end,
	__tostring = function(t)
		return t:code()
	end
}

return function()
	return setmetatable({ _indent = 0, _code = {} }, mt)
end
