M = {}

local json    = require "JSON"
local xml2lua = require "xml2lua"
local handler = require "xmlhandler.tree"

function M.jsonbody_to_xml(b)
  local jsonString = tostring(b:getBytes(0, b:length()))
  local nbody = json:decode(jsonString)
  local xmlstr = xml2lua.toXml(nbody,"body")
  return xmlstr
end

function M.xmlbody_to_json(b)
  local parser = xml2lua.parser(handler)
  parser:parse(b:getBytes(0, b:length()))

  local nbody = json:encode(handler.root)
  return nbody
end

return M
