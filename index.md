---
layout: home
title: Commandops CMANO Stuff
description: Just some random CMANO stuff
active: yes
---

### Remove Sensors from all Air Units with a Specific DBID

```lua
local a,b,c,d = W_GetSideUnitTotalsTable('Blue') --special function in starter scen
for k,v in ipairs(a) do
local u = ScenEdit_GetUnit({guid=v})
if u.dbid == 310 then
print(u.name)
ScenEdit_UpdateUnit({guid=v,mode='remove_sensor',dbid=937})
ScenEdit_UpdateUnit({guid=v,mode='remove_sensor',dbid=444})
end
--print(u.name) 
end

```

### Create a handful of sides via script

```lua

local W_sides ={ {side='Blue',awareness='Normal',proficiency='Regular'}, {side='Red', awareness='Normal',proficiency='Regular'},{side='Targets',awareness='Blind',proficiency='Regular'},{side='Bios',awareness='Blind',proficiency='Regular'},{side='Survivors',awareness='Blind',proficiency='Regular'} }
--proficiency values - Novice, Cadet, Regular, Veteran, Ace


function W_SetupSides()
 for k,v in ipairs(W_sides) do
print('Creating side: '..v.side)
 ScenEdit_AddSide({side=v.side})
 ScenEdit_SetSideOptions({side=v.side,awareness=v.awareness,proficiency=v.proficiency})
end

ScenEdit_SetSidePosture ('Blue', 'Red', 'H')
ScenEdit_SetSidePosture ('Red', 'Blue', 'H')
ScenEdit_SetSidePosture ('Survivors', 'Blue', 'F')
ScenEdit_SetSidePosture ('Blue', 'Survivors', 'F')
ScenEdit_SetSidePosture ('Blue', 'Targets', 'U')
ScenEdit_SetSidePosture ('Targets', 'Blue', 'U')

ScenEdit_MsgBox ('The sides should be setup, please double check them. Also you should change the Bios, Targets and Survivors to Computer only. If you plan to use the Create Targets Special Action I think it works better with Collective Responsibility set to No.', 1)

end--function end
W_SetupSides()
``` 