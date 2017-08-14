--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this part defines the framework of the addon.

BrewmasterTools = {}


--[[
Our goal here is to provide a consistent way to add a module.
load.lua should understand, soley from the data provided to this function,
how to build options for a module, and control a module's behavior - start,
stop features, tweak settings, etc. I consider this layer of abstraction worth
the trouble, so that in the future, updating functionality does not require
updating design beyond the minimal testing to ensure that design is still sane.
]]

--dummy function. Is this necessary?
local function dummy() end
BrewmasterTools.modules = {}
function BrewmasterTools.AddModule(name,  api, init, controlFrame, controlScripts)
  --incorporate the module, and implant the functions
  --for now, just add the table to main table at [name]
  if type(name) ~= "string" then
    error("BrewmasterTools: Improper argument #1 to AddModule: name must be a string.")
  elseif type(api) ~= "table" then
    error("BrewmasterTools: Improper argument #2 to AddModule: api must be a table.")
  elseif BrewmasterTools.modules[name] then
    error("BrewmasterTools: A module by the name of "..name.." already exists.")
  elseif type(init) ~= "function" then
    error("BrewmasterTools: Improper argument #3 to AddModule: init must be a function")
  elseif controlFrame then
    if type(controlFrame) ~= 'table' or type(controlFrame[0]) ~= 'userdata' then
      error("BrewmasterTools: Improper argument #4 to AddModule: controlFrame must be a frame.")
    elseif type(controlScripts) ~= 'table' then
      error("BrewmasterTools: Improper argument #5 to AddModule: controlScripts must be a table.")
    end
  else
    BrewmasterTools.modules[name] = {
      api = api,
      init = init,
      controlFrame = controlFrame,
      controlScripts = controlScripts,
    }
    for k,v in pairs(api) do
      if BrewmasterTools[k] then
        print("Brwemastertools - Warning: module",name,"has attempted to add API method",k,"which already exists. The results of this API call will be unpredictable.")
        --ensure that anything using the api doesn't trigger an attempt to call a nil value
        BrewmasterTools[k] = dummy
      end
    end
  end
end
