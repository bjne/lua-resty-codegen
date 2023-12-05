local code = require "lib.resty.codegen"()

code:block([[return function()]], function()
	code[[print("foo")]]
end)

print(code:code())
print(loadstring(code:code())()())
