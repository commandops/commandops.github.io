---
title: CMANO Lua Scoring Event
description: An example of how to use a single Lua Event to handle all scoring for a side.
layout: default
---

Rather than setting up numerous scoring events with muliple triggers and actions, you can use a single Lua based event to do the same thing and have it all be in one place.

**I've had some trouble using this script at the same time as a downed pilot/survivors script, seems to not always run. To fix it I have combined the action that fires the createsurvivors() function with this action that sets the score. Seemed like the survivors script would run but then the score script would be passed over, but not always. I think maybe it is too much lua to execute all at the same time. Combining them seems to work well.**

Advantages:
- all scoring for one side is in one Event with a single Action and a single Trigger (probably best to separate scoring for gaining points and losing points so maybe 2 Events if there are 2 sides)
- can be as granular as needed
- easier to maintain/edit if the scoring needs adjusting
- more flexible, anything in the unit wrapper could change the score, for example unit is on a specific mission - mission a, score = x, unit is on mission b score = z

Disadvantages:
- requires a little bit of Lua code knowledge, but not much
- brittle - if you get the syntax wrong then all scoring might be whacked
- might not play well with other Unit Destroyed scripts (one or the other may time out?)


## Event Setup

Create an event named `Blue Unit Destroyed` or whatever you wish. Keep in mind this name will show in the log (assuming you have that checked) and make sure all 3 boxes are checked and the probablitity is 100%.

Create a Trigger called `Blue Unit Destroyed` or whatever you wish, set to `Unit Destroyed` and just set the top selector for the side you want to keep score for (Blue in our case). Do not drill down and set anything else.

Create an Action, with Lua as the type. This is where all the magic is.

Top part is just some basics:  
(LUA allows you to embed comments by putting 2 dashes in front so if you see -- and then some text that is a comment)

```
local side = "Blue" -- put the side that you are keeping track of scoring for here
local currentScore = ScenEdit_GetScore(side) -- get the current score
local points = 0 --default amount of points to award, set to zero so only explicitly set scores are used
local unit = ScenEdit_UnitX() --get the unit wrapper for the unit that was destroyed
```

Next we will check if the unit destroyed is a weapon, and if so we will exit the code (return) cause weapons aren't part of the scoring normally. `Return` stops the code from running any further.

```
if unit.type == "Weapon" then
return --exit if destroyed unit is really a weapon
end
```

Now we will set up some basic scores for the 4 main unit types - facility, sub, ship and AC. Make sure to spell them right and they are all capitalized.

```
if -- initial score setup, defaults
unit.type == "Aircraft" then points = -10
elseif 
unit.type == "Ship" then points = -50
elseif 
unit.type == "Submarine" then points = -50
elseif 
unit.type == "Facility" then points = -5
end
```

So now if a unit is one of those types, say a Sub, we will override the original value of `points` (which we just set to 0 at the top) and set it to something we want like -50. It is a negative amount as we are penalizing the side for losing a unit.

Next we can drill down as much as we want, this next section is using the unit.subtype to bunch some things up - so if there are 4 ddgs in the scen, and all will incur the same penalty we can set that by using the 3203 subtype. If there are multiple subtypes that will have the same amount of points we can chain them together with an `or` statement.

Unit subtype as used here is a number, though you need to enclose it in quotes. This can be hard to find as far as a long list all in one place, but you can find it in any units wrapper, or there is a cool script by michaelm75au that creates an OOB that can be modified to show this (look at the Survivors script for an example).

<blockquote class="blockquote-danger">
   <p>Sub Type is a bad idea here, as it looks like the same sub type number can conflict with other types - so a facility and a ship may share the same sub type sometimes. If you have limited number of units it is probably ok. It is better to just use something from the units name like the examples below (F-15). I'm leaving it as an example of the code, but it you probably should not use it, use the string match part below to choose units.</p>
 </blockquote>

```
if unit.subtype == '4015' or unit.subtype == '4013' or unit.subtype == '4010' then points = -250 -- lha/lpd/lsd
elseif
	unit.subtype == '3401' then points = -20 --rib/mk6
elseif
	unit.subtype == '2010' then points = -125 --sub
elseif
	unit.subtype == '3203' then points = - 150 -- ddg
elseif
	unit.subtype == '3106' then points = -175 --cg
elseif
	unit.subtype == '3306' then points = -100
elseif
	unit.subtype == '7002' or unit.subtype == '8001' or unit.subtype == '4002' then points = -43 -- awacs/jstar/kc135
elseif
	unit.subtype == '8201' then points = -5 --scaneagle 
end
```

Well that is all well and good, but what about referencing units by name? no problem you can do that too if you know the exact name of a unit:

```
if unit.name == "Air Force 1" then points = -1000
	end
```

Don't know the entire exact name? we can use string.match to see if a unit classname contains a partial string - so say you want to cover all F-15s. You can do it, but you need to watch out for special characters, of which a dash is one. If there is a special character you need to put a percent sign in front to escape it. So instead of F-15 it would be F%-15.

```
if string.match(unit.classname, "F%-15") then points = -17
end
```

you can keep doing this as much as you like, and once you have covered all the scoring options you need, you just need to wrap it up by adding the points value to the current score and passing that in with the SetScore function:

```
currentScore = currentScore + points
print(unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points) -- not needed but handy
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```

The SetScore function takes in 2 or 3 arguments, the 3rd one is optional (the reason for the score change) above I have that showing some extra info about the unit causing the score change.

Note the .. syntax, this is needed when placing a variable like currentScore next to a String, like where I want to enclose the unit info in parenthesis. You need .. on either side of a variable that is next to a string. You also have to enclose Strings inside quotes so you end up with some odd looking code.

The print function is not required, but will show in the luahistory log which is quite handy.

If you are not at all familiar with code, the main confusion here could be the use of the equal sign - there are 2 uses of the = sign, one where you want to set a variable to a particular value: so if you want to set x to 5 it would be x = 5. You are explicitly saying that x is equal to 5. If you want to check if x is currently equal to 5 then in some sort of comparison you would see if x == 5. So one equal sign is to set a value, 2 equal signs is to compare a value.

Full code example (this is just for losing points, would need to do the same thing for adding points on unit destroyed - red):
<blockquote class="blockquote-danger">
   <p>Sub Type is a bad idea here, as it looks like the same sub type number can conflict with other types - so a facility and a ship may share the same sub type sometimes. If you have limited number of units it is probably ok. It is better to just use something from the units name like the examples below (F-15). I'm leaving it as an example of the code, but it you probably should not use it, use the string match part below to choose units.</p>
 </blockquote>
```
-- blue unit destroyed
local side = "Blue"
local currentScore = ScenEdit_GetScore(side) 
local points = 0 --default
local unit = ScenEdit_UnitX()

if unit.type == "Weapon" then
return --exit if destroyed unit is really a weapon
end

if -- initial score setup, defaults
unit.type == "Aircraft" then points = -10
elseif 
unit.type == "Ship" then points = -50
elseif 
unit.type == "Submarine" then points = -50
elseif 
unit.type == "Facility" then points = -5
end

if unit.subtype == '4015' or unit.subtype == '4013' or unit.subtype == '4010' then points = -250 -- lha/lpd/lsd
elseif
	unit.subtype == '3401' then points = -20 --rib/mk6
elseif
	unit.subtype == '2010' then points = -125 --sub
elseif
	unit.subtype == '3203' then points = - 150 -- ddg
elseif
	unit.subtype == '3106' then points = -175 --cg
elseif
	unit.subtype == '3306' then points = -100
elseif
	unit.subtype == '7002' or unit.subtype == '8001' or unit.subtype == '4002' then points = -43 -- awacs/jstar/kc135
elseif
	unit.subtype == '8201' then points = -5 --scaneagle 
end

if unit.name == "Air Force 1" then points = -1000
	end

if string.match(unit.classname, "F%-15") then points = -17
end

currentScore = currentScore + points
print(unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```

Here is another example (Scenario: 1,2 52), smaller scenario with less units to worry about (no ships or subs).  
This is the Blue side points for losing units - Trigger is Blue Unit Destroyed:

```
local side = "Blue" -- put the side that you are keeping track of scoring for here
local currentScore = ScenEdit_GetScore(side) -- get the current score
local points = 0 --default amount of points to award, set to zero so only explicitly set scores are used
local unit = ScenEdit_UnitX() --get the unit wrapper for the unit that was destroyed

if unit.type == "Weapon" then
return --exit if destroyed unit is really a weapon
end

if -- initial score setup, defaults, blue only has ac and seals to lose
unit.type == "Aircraft" then points = -200
elseif 
unit.type == "Facility" then points = -50 --seal will be 50 points
end

--blue ac in game - B-1B, B-2A, B-52H,F-35A,F-22A. Raptors and 35s will be default -200 so they are not below. 
-- % sign is there because a dash is a special character, the % tells it to not use it as a special character
if string.match(unit.classname, "B%-1B") then points = -400
end
if string.match(unit.classname, "B%-52H") then points = -250
end
if string.match(unit.classname, "B%-2A") then points = -1000
end

currentScore = currentScore + points
print("["..unit.side.."] "..unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```

Blue side scoring Action for killing Red units - Trigger is Red Unit Destroyed:

```
local side = "Blue" -- put the side that you are keeping track of scoring for here
local currentScore = ScenEdit_GetScore(side) -- get the current score
local points = 0 --default amount of points to award, set to zero so only explicitly set scores are used
local unit = ScenEdit_UnitX() --get the unit wrapper for the unit that was destroyed

if unit.type == "Weapon" then
return --exit if destroyed unit is really a weapon
end

if -- initial score setup, defaults, red only has ac and facilities
unit.type == "Aircraft" then points = 30
elseif 
unit.type == "Facility" then points = 50
end

--red ac in game all worth 30, only modifers are for facilities and inf
if unit.name == "Sector Control Station" then points = 500
	end 
if unit.name == "COMINT Station" then points = 400
	end
if unit.name == "C3M Bunker" then points = 900
	end
if unit.name == "Mech Inf Plt (VTT-323 M1973 Sinhung) APC x 3)" then points = 5
	end
if unit.name == "Inf Plt (Syrian Army)" then points = 1
	end
if unit.name == "Hospital" then points = -500
	end

currentScore = currentScore + points
print("["..unit.side.."] "..unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```
