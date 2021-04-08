local inspect = require "inspect"
local mylib   = require "lib.mylib"

local accept

local getCurrenciesXML = [[
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCurrencies xmlns="http://tempuri.org/" />
  </soap:Body>
</soap:Envelope>
]]

function envoy_on_request(request_handle)
  accept = request_handle:headers():get("accept")
  
  -- request_handle:body(true)
  request_handle:headers():replace(":method", "POST")
  local res = request_handle:body(true):setBytes(getCurrenciesXML)

end

function envoy_on_response(response_handle)
  if accept == "application/json" then
    local res = response_handle:body()
    local jbody = mylib.xmlbody_to_json(res)
    local cl = response_handle:body():setBytes(jbody)

    response_handle:headers():replace("content-length", cl)
    response_handle:headers():replace("content-type", "application/json")
  end
end
