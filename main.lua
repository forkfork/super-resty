local ffi = require('ffi')
require ('libc')

local boilerplate = [[

local r = function(response, status)
  local status = status or 200
  ngx.say(response)
  ngx.header["Content-Type"] = "application/json"
  ngx.status = status
end

local _M = function ()

%s

end
return _M
]]

ngx.req.read_body()
local route = ngx.var.uri

local load_code  = function ()
  local route_base64 = ngx.encode_base64(string.sub(route, 6))
  local req_route_path = "code/" .. route_base64 .. ".lua"
  local req_route_path2 = "code." .. route_base64
  local exists = ffi.C.access(req_route_path, 0)
  local fp, err = io.open(req_route_path, "w")
  if err then
    ngx.log(ngx.INFO, err)
  end
  local req_code = ngx.req.get_body_data()
  fp:write(string.format(boilerplate, req_code))
  fp:close()
  if exists ~= -1 then
    -- code exists, force an nginx reload
    local parent = ffi.C.getppid()
    ffi.C.kill(parent, 1)
    ngx.say("OK, Ready in a moment (SIGHUP to nginx as you are changing an existing route)")
  else
    -- code does not exist, prime the cache now
    ngx.say("OK")
    local code = require(req_route_path2)
    code()
  end
end

local execute_code = function ()
  local route_base64 = ngx.encode_base64(route)
  local req_route_path2 = "code." .. route_base64
  local code = require(req_route_path2)
  code()
end

if string.sub(route, 1, 5) == "/code" then
  load_code()
else
  execute_code()
end
