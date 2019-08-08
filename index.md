---
layout: raw
title: Commandops CMANO Stuff
description: Just some random CMANO stuff
active: yes
---
{% include home-top.html %} 

Check land units on a mission to see if they still have ammo - if not return them to a specific location.

```
local returnCourse = { [1] = { latitude='20.0176142061058', longitude='-75.9143283023575', TypeOf = 'ManualPlottedCourseWaypoint'} }

local m = ScenEdit_GetMission ('Crimson Commonwealth', 'Assault - Industrial')
--print(#m.unitlist)

for i =1,#m.unitlist do
local u = SE_GetUnit({guid=m.unitlist[i]})
print(u.name)
local ammo =0
for k,v in pairs(u.mounts) do --outer mounts loop
for k,v in pairs(u.mounts[k].mount_weapons) do --loop thru each mounts weapons
print(v.wpn_name..' '.. v.wpn_current)
ammo = ammo + v.wpn_current
print("total ammo: "..ammo)
end
end
if ammo == 0 then
print('unit is out of ammo, should send back to LZ')
ScenEdit_AssignUnitToMission(u.name, 'NONE')
u.course = returnCourse
else
print('unit still has ammo')
end
print('-------------------')
end
```

{% include home-bottom.html %} 
