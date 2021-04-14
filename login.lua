local json = require "JSON"

function envoy_on_request(rh)
  rh:logInfo("Entering on request")
  local h,b = rh:httpCall(
  "apigee",
  {
    [":method"] = "POST",
    [":path"] = "/foobar/snarf",
    [":authority"] = "emea-poc15-test.apigee.net",
    ["accept"] = "application/json",
    ["Content-Type"] = "application/json"
  },
  "{\"msg\": \"I am a little teapot\" }",
  0)

  rh:logInfo("body: "..b)

  --  parse the body and 
  -- local jsonString = tostring(b:getBytes(0, b:length()))
  local msg = json:decode(b).data

  rh:logInfo("And our message is: "..msg)
  rh:headers():add("x-apigee-message", msg)

end

function envoy_on_response(response_handle)
  --
end
