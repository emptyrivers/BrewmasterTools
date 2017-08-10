--Copyright (c) 2017 by Rivers. See ..\LICENSE.md for details

--this part defines the framework of the addon.

BrewmasterTools = {}




function BrewmasterTools.AddModule(name,  tbl)
  --incorporate the module, and implant the functions
  --for now, just add the table to main table at [name]
  if type(name) ~= "string" then
    error("Improper arguments to AddModule: name must be a string.")
  elseif type(tbl) ~= "table" then
    error("Improper arguments to AddModule: module must be a table.")
  elseif BrewmasterTools[name] then
    error("A module by the name of "..name.." already exists.")
  else
    for k,v in pairs(tbl) do
      if not BrewmasterTools[k] then
        BrewmasterTools[k] = v
      end
    end
  end
end
