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

local function dummy() end

BrewmasterTools.modules = {}

function BrewmasterTools.AddModule(name, module, overrideAPI)
  assert(type(name) == "string", "BrewmasterTools: Improper argument #1 to AddModule: name must be a string.")
  assert(not BrewmasterTools.modules[name], "BrewmasterTools: A module by the name of "..name.." already exists.")
  assert(type(module.Init) == 'function', "BrewmasterTools: "..name.." requires an Init method.")
  assert(type(module.Enable) == 'function', "BrewmasterTools: "..name.." requires an Enable method.")
  assert(type(module.Disable) == 'function', "BrewmasterTools: "..name.." requires a Disable method.")
  assert(type(module.scripts) == 'table', "BrewmasterTools: "..name.." requires a scripts attribute.")
  BrewmasterTools.modules[name] = module
  if not BrewmasterTools.loaded and module.api then
    for k,v in pairs(module.api) do
      if BrewmasterTools[k] and not overrideAPI then
        print("Brwemastertools - Warning: module",name,"has attempted to add API method",k,"which already exists. The results of this API call will be unpredictable.")
        --ensure that anything using the api doesn't trigger an attempt to call a nil value
        BrewmasterTools[k] = dummy
      end
    end
  else
    BrewmasterTools.LoadModule(BrewmasterTools.modules[name])
  end
end

function BrewmasterTools.LoadModule(module)
  module:Init()
  if module.api then
    for name, func in pairs(module.api) do
      BrewmasterTools[name] = func
    end
  end
end
