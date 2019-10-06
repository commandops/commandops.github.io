---
title: CMANO Special Actions
description: Some examples of Special Actions for CMANO
layout: default
---

## In Game Timer

Set a timer along with a reminder for what the timer is for. When the timer goes off a pop up message will remind you what it is for.

```lua
function TimerTimeFromNowDotNetTime(addSeconds) -- Time helper cause event times are weird

    local time = ScenEdit_CurrentTime()
    local offSet = 62135596801 --number of seconds from 01-01-0001 to 01-01-1970

    local newTime = (time + offSet + addSeconds)*10000000
    local timeToUse = string.format("%18.0f",newTime)
    return timeToUse
end

function CreateTimerEvent(minutes,message)
 local t = ScenEdit_CurrentTime() --need to add something to the names to make them unique, using time

ScenEdit_SetEvent(minutes.." Minute Timer ("..message..")"..t, {mode="add",IsRepeatable=0})
ScenEdit_SetTrigger({mode="add", type="Time", name=minutes.." Minute Timer Trigger ("..message..")"..t, Time=TimerTimeFromNowDotNetTime(minutes*60) })
 ScenEdit_SetAction({mode="add", type="LuaScript", name=minutes.." Minute Timer Action ("..message..")"..t,
 scriptText='ScenEdit_SpecialMessage (ScenEdit_PlayerSide(),"Your Timer is Up:  '..message..' ")'})
ScenEdit_SetEventTrigger(minutes.." Minute Timer ("..message..")"..t, {mode="add", name=minutes.." Minute Timer Trigger ("..message..")"..t})
ScenEdit_SetEventAction(minutes.." Minute Timer ("..message..")"..t, {mode="add", name=minutes.." Minute Timer Action ("..message..")"..t})
end

local timerMinutes = ScenEdit_InputBox('How long do want the timer to be in minutes?') 
--print('Response was ' ..timerMinutes) 
local timerMessage = ScenEdit_InputBox('What do you want to call the timer?') 
--print('Response2 was ' .. timerMessage) 
CreateTimerEvent(timerMinutes,timerMessage)
```

## Deploy Recon Team from Ship or Sub

Must be within 6 miles of shore. Each ship or sub can deploy one recon unit. The deploying unit must be traveling at less than 6 mph and be no more than 30 meters deep. Running the action will pop up a box asking for a bearing to send the diver, which will then be checked to see if it is on land.

This code is part of the Starter Scen, all you need in the Special Action code part is what is below. That calls a function that is loaded at Scen Load found [here- deploy recon team](/code/deploy-recon-team.txt)


```lua
W_DeployDiversFromSelectedSub(6) -- number in parens is the max distance allowed from land.
```

## Create a Target from a Selected Ref Point

Requires a side named `Targets`.

Create a target from selected Ref Point(s), must be on land.

May take up to a minute for the targets to appear.

```lua
local side=ScenEdit_PlayerSide()
local targetSide = 'Targets'
local sideCheck =ScenEdit_GetSideOptions({side=targetSide})
print(sideCheck)
if sideCheck == nil then
ScenEdit_MsgBox ('Target Side does not exist, please create a side named Targets', 1)
return
end
local targetDBID = 2434 --cwdb is 1633 db3000 is 2434
local s = VP_GetSide({side=side})
local noRefPoints = true
local w_targetCounter = ScenEdit_GetKeyValue('w_targetCounter')
print('counter equals '..w_targetCounter)
if w_targetCounter == '' then w_targetCounter =1
print('counter was not set, now it is 1')
else
  counter=tonumber(w_targetCounter)
print('must be set to '..w_targetCounter)
end

for k,v in ipairs(s.rps) do
if v.highlighted == true then
ScenEdit_AddUnit({side=targetSide,name='Target-'..w_targetCounter,type='Facility',lat=v.latitude, lon=v.longitude,dbid=targetDBID,autodetectable='true'})
ScenEdit_DeleteReferencePoint({side=side,guid=v.guid})
--_SetReferencePoint({side=side,guid=v.guid,newname='target'})
print(v.highlighted)
w_targetCounter=w_targetCounter +1
noRefPoints=false
end --end looping thru ref points
end
if noRefPoints then
ScenEdit_MsgBox ('No Ref Points selected', 1)
end --if norefpoints
```