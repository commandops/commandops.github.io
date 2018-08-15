---
title: Survivors Script for CMANO
description: Somewhat complicated script to create survivors when a unit such as an Aircraft is destroyed
layout: default
---

Last Updated: August 15, 2018

I got a little carried away with a downed pilot script made by Angster (and modified by TyphoonFr/Gunner98). I added a bunch of configuration options, and made it so any type of unit can rescue a survivor.

Example Scenario with units ready to be destroyed: [Survivors Scenario](/assets/scens/search-and-rescue23.scen) (if it opens as a text file, just save it without the .txt extension in your scen folder)

Major changes: 

- survivor instead of pilot as any unit can have a survivor (ships or AC, probably ground units but that is not tested) 
- configurable number of survivors based on unit subtype (set in event action) 
- configurable max speed and altitude for pickup - ie rescue unit must be below 100 ft and 10 kts (subs must be surfaced) 
- configurable success and failure scores, which are multiplied by number of survivors
- configurable max success/failure scores
- survivor unit is a life raft if over water, ground unit if on ground (actual dbids are configurable, beware the type). All survivors of a given unit are represented by that one unit 
- survivor unit is set to a configurable neutral side - which must exist (needed to allow pickup by different types of units) 
- configurable time it takes to rescue each survivor. 
- configurable crew survival percent for multi crew units. Can be used in tandem with the trigger firing percentage likelihood 
- enhanced survivor message 
- survivor time to live is set to a random time between 30 minutes and 30 hours. Hard coded but could be made more easily configurable 


For it to work you need the following:

- A side named Survivors, should be neutral to enemy, friendly to player side, although having it be neutral to the player side may add some fun to it as then I think you would have to actually search for/detect the unit first. Name is configurable.
- an Event to load the main script
	- Trigger is scen loaded
	- Action is lua with the main script
	- should be repeatable
- an Event to create survivors when a unit is lost	
	- Trigger is Unit Lost, set to the side you want, and the type of unit lost - Air/Ship etc. You probably don't need to drill into specific units as that can be set in the Action.
	- you may want more than one trigger for this event - one for AC another for Ships for example.
	- Action is lua code	
- an Event named exactly: `Event - Start SAR Target Pickup` this event must have that exact name because the script is going to add and delete triggers and actions to that Event, if it doesn't exist with that name it won't work
	- Trigger is Scen Loaded (not sure why, I think it is just so that there is a Trigger when there are no survivors)
	- Action is lua code


-----

### Event - Create Survivors

- Create a new Event, named: Create Survivors - or whatever you like
- Create a Trigger - type is Unit Lost, set to what type of unit lost you want to create a survivor, for instance Aircraft or Ships. You don't need to be specific as that can be handled in the Action. So choosing the player side and setting it to Aircraft is perfect and we will use that as the example.
- Create an Action named Create Survivors or whatever you like

The action can be simple or more complex depending on how precise you want the survivors to be.

At its simplest it can be:  
`CreateDownedPilotFromTriggerUnit(ScenEdit_UnitX())`

This will assume any Aircraft shot down will have a chance of having one survivor.

This can be extended by passing in a second parameter into the function - which would be the number of potential survivors (or passengers). So if you still want a basic lua script but want to always have 2 potential passengers/survivors you can do:
'CreateDownedPilotFromTriggerUnit(ScenEdit_UnitX(),2)'

Now we can extend that basic formula using some more advanced lua. Lets say you want the base number of survivors to be 1, so we'll set a local variable called `crew` to a value of 1:  
`local crew = 1`

Then we can change the original one line to pass in the variable crew:  
`CreateDownedPilotFromTriggerUnit(ScenEdit_UnitX(),crew)`

Nothing has really changed, any AC destroyed will have a potential survivor count of 1.

Now we can start specifying which particular units have a crew that is not 1. The easiest way I have found to do this is to use a units subtype to categorize things. I think subtypes are the same thing as what is in the Unit Lost Trigger under the actual type of say Aircraft... so a subtype is like MPA or AEW or Bomber - so you can get a bunch of units without needing to do anything complicated. So lets say that an AEW unit like an AWACs plane has 0 potential survivors. To do that you need the subtype number for AEW which is 4002. I haven't found an easy way to know what the subtype numbers are so there is a function in the main script that will print out all the units on your side (OOB) with their subtype. You can do this by running `GetOOBWithSubType()` in the lua console.

Using lua we can check if the unit that was destroyed - UnitX() has a subtype = '4002' and if it does we'll change the value of out crew variable to 0:  
```
local crew = 1 --default
if 
ScenEdit_UnitX().subtype == '4002' then crew = 0 --AEW has no chance of survivors
end
```

We can keep doing this and even chain things with an Or statement if some unit subtypes have the same number of potential survivors. You can also use unit.classname to clarify even more, as well as use And statements:  

```
---Create Survivor
local crew = 1 --default
if 
ScenEdit_UnitX().subtype == '6001' or ScenEdit_UnitX().subtype == '8001'  then crew = 3  --sh60 or kc135
elseif 
 ScenEdit_UnitX().subtype == '6002'  or ScenEdit_UnitX().subtype == '3101'  then crew = 12 --mpa or bomber?
elseif 
ScenEdit_UnitX().subtype == '7101' and ScenEdit_UnitX().classname ~= 'C-17A Globemaster III SOLL' then crew = 7 --transport but not c-17s
elseif 
ScenEdit_UnitX().classname == 'C-17A Globemaster III SOLL' then crew = 26 --transport c-17s 7101 conflicts with mv-22 and ch53
elseif
ScenEdit_UnitX().subtype == '3106' then crew = 350 --CG
elseif 
ScenEdit_UnitX().subtype == '3203' then crew = 150 --DDG
elseif 
ScenEdit_UnitX().subtype == '4002' or ScenEdit_UnitX().subtype == '7002'  then crew = 12 -- E3 Sentry Jstars
end

CreateDownedPilotFromTriggerUnit(ScenEdit_UnitX(),crew)
```

Since there is only one action to create a survivor, if you want survivors for both Ships and AC you can control them all in this one Action. You will still need separate Triggers so you can exclude weapons and what not from making survivors.

UAV subtypes should automatically be excluded from having survivors, there were 2 different subtypes that I found for UAVs, but there could be more - if so you would need to list them in the Action by their subtype and set the crew to 0. 

The above example uses subtype to change the crew value, but this part has nothing to do with the script, so you can use anything you want, such as the unit name.

-----

### Event - Start SAR Target Pickup

- Create a new Event, named: Event - Start SAR Target Pickup
	- Must be named exactly as listed!
- Create a Trigger - type is Scenario Loaded set to repeat
- Create an Action named SAR Action set to lua, though the name is not important

The code to go in the Action is:
```
----Start SAR - Scen loaded/repeats
if ScenEdit_UnitX() then
    StartSARTargetPickup(ScenEdit_UnitX())
end
```

The SAR Action is what happens when a unit attempts to rescue a survivor. The trigger for it will automagically be created when a survivor is created. When a survivor is created, the script will create Triggers with Unit Remains in Area.

---

### The Main Script

- Create an Event named Load Scripts, set to repeat.
- Use a Trigger of Scenario Loaded (you already have one from one of the above Events)
- Create an Action called Load Scripts or whatever you like set to lua

The top of the main script has a bunch of configurable options. For the most part the names are self explanatory.

Below is the main script code, put this in the lua for the Action.

<embed style="background-color: #f6f6f6;" width="100%" height="800px" src="/code/survivors.txt">

### Additional Notes

The script should only create survivors if an AC is airborne, or a ship is at sea/underway. That is done by checking the unit.condition, but there could be other conditions that could have survivors, I just don't have any way to know what they are. Some that I have seen are Docked (ships), Refueling, Manoeuvering to refuel, On final approach and Parked. There may be something like 'Changing Course' that is normal while Airborne/Underway.

UAVs should not trigger survivors, but that depends on them being subtype 8201 or 8202. There may be other subtypes for UAVs.

I've thought of extending this script to handle the unit destroyed scoring... say an AC with 10 potential survivors is shot down, if there are 0 survivors the score could be -25. If there are 10 survivors the score could be -15, then the rescued survivor score could be 0 but the failed rescue could be -10. Seems a little too involved, but could be fairly easily done I think.	

As for unit destroyed scoring, the way this script handles the potential crew/passengers - all in one action - could also work for unit destroyed scoring. Why have 10 different actions/triggers/events to handle 10 different types of units when  they could all be in the same Event set? all you need is the lua with the if/elseif statements and the unit types or names. Seems a lot easier and more robust. 


