Rather than setting up numerous scoring events with muliple triggers and actions, you can use a single Lua based event to do the same thing and have it all be in one place.

Advantages:
- all scoring for one side is in one Event with a single Action and a single Trigger
- can be as granular as needed, just like the normal way
- easier to maintain/edit if the scoring needs adjusting

Disadvantages:
- requires a little bit of Lua code knowledge, but not much
- brittle - if you get the syntax wrong then all scoring might be whacked
- need to know unit subtypes (number) which can be hard to find (not required but helpful to do bunches of types of units at the same time)

## Event Setup

Create an event named `Blue Unit Destroyed` or whatever you wish. Keep in mind this name will show in the log (assuming you have that checked) and make sure all 3 boxes are checked and the probablitity is 100%.

Create a Trigger called `Blue Unit Destroyed` or whatever you wish, set to `Unit Destroyed` and just set the top selector for the side you want to keep scored for (Blue in our case). Do not drill down and set anything else.

Create an Action, with Lua as the type. This is where all the magic is.

Top part is just some basics:

```
local side = "Blue" -- put the side that you are keeping track of scoring for here
local currentScore = ScenEdit_GetScore(side) -- get the current score
local points = 0 --default amount of points to award, set to zero so only explicitly set scores are used
local unit = ScenEdit_UnitX() --get the unit wrapper for the unit that was destroyed
```

Next we will check if the unit destroyed is a weapon, and if so we will exit the code (return).

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

So now if a unit is one of those types, say a Sub, we will override the original value of `points` and set it to something we want like -50. It is a negative amount as we are penalizing the side for losing a unit.

Next we can drill down as much as we want, this next section is using the unit.subtype to bunch some things up - so if there are 4 ddgs in the scen, and all will incur the same penalty we can set that by using the 3203 subtype. If there are multuple subtypes that will have the same amount of points we can chain them together with an `or` statement.

Unit subtype as used here is a number, though you need to enclose it in quotes. This can be hard to find as far as a long list all in one place, but you can find it in any units wrapper, or there is a cool script by michaelm75au that creates an OOB that can be modified to show this (look at the Survivors script for an example).

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

Don't know the entire exact name? we can use string.match to see if a unit name contains a partial string - so say you want to cover all F-15s. You can do it, but you need to watch out for special characters, of which a dash is one. If there is a special character you need to put a percent sign in front to escape it. So instead of F-15 it would be F%-15.

```
if string.match(unit.name, "F%-15") then points = -17
end
```

you can keep doing this as much as you like, and once you have covered all the scoring options you need you just need to wrap it up byt adding the points value to the current score and passing that in with the SetScore function:

```
currentScore = currentScore + points
print(unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points) -- not needed but handy
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```

The SetScore function takes in 2 or 3 arguments, the 3rd one is optional - the reason for the score change, above I have that showing some extra info about the unit causing the score change.

The print function is not required, but will show in the luahistory log which is quite handy.


Full code example:

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

if string.match(unit.name, "F%-15") then points = -17
end

currentScore = currentScore + points
print(unit.name.. " ("..UnitX().classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
ScenEdit_SetScore(side, currentScore, unit.name.. " ("..unit.classname.." Sub Type: "..unit.subtype.." ) Destroyed - Points:  "..points)
```
