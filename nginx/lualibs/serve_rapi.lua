local program, param =
ngx.var.program, ngx.var.param

-- helper function to indicate not valid request
local function return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Access-Control-Allow-Origin"] = "*"
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

if not(program == "calc" or program == "deriv") then
  return_not_found("invalid program. only calc and deriv are supported")
end

local R = require "rclient"  
local r = R.connect()
r.text1 = param

local status, exception
-- catch errors
status, exception = pcall(function() 
  if program == "calc" then
  	r "text1 <- eval(parse(text=text1))"
  else
  	r "text1 <- deparse(D(parse(text=text1),'x'))"
  end
end)


local res
if not status then
	res  = exception
else
	res  = unpack(r.text1)
end

status = r.disconnect

--[How do I add Access-Control-Allow-Origin in NGINX?](http://serverfault.com/questions/162429/how-do-i-add-access-control-allow-origin-in-nginx)
ngx.header["Access-Control-Allow-Origin"] = "*"
ngx.header["Content-Type"] = "text/plain"
ngx.say("param: " .. param)
ngx.say("result: " .. res)
ngx.exit(0)