---
title: CMANO Starter Scenario
description: The starter scenario has some basic things preset, such as a bunch of helper functions, a couple special actions and some basic scoring. 
layout: default
---

I try to keep the Starter Scen up to date in the [Matrix forum](http://www.matrixgames.com/forums/tm.asp?m=4588613).

Reference for what is included:

## Before You Do Anything Else:

- Update the DB version to the most recent one you want to use
- Turn on Scenario Features (Cargo, AC damage etc)
- Delete the handful of units in the Atlantic (9 total between Red and Blue)
- Set the time to whatever you need it to be
- Check Side names and edit as needed. Keep the Blue side as the primary player side, and Red as the primary enemy side. There is some basic scoring setup for those sides, and they should still work even after you change the names. The Event, Trigger and Action names will still be Blue and Red (feel free to edit them) but the triggers themselves should still be correct even if you change the names as they are guid based.

The downed pilot/survivors script is loaded but not enabled. You can enable it by un-commenting the lines at the bottom of the Blue Unit Destroyed Action.

### Scoring via Lua Actions

Simple scoring is setup for both Red and Blue and should work correctly from either side.

Scoring is controlled by 2 Lua Actions - one for Red Unit Destroyed and one for Blue Unit Destroyed. 

You can get as granular as needed with the scoring by adding elseif statements to check different unit properties such as the unit name or classname. 

ex: string.match(unit.classname, "F%-15") then points = -17

The % is to escape the dash which is an illegal character in string.match. To use string.match you pass in 2 things - the string to check (unit.classname) and the thing you want to see if is there - in this case f-15 which needs to be f%-15 to allow the dash. Once you have the elseif set then you change the Points to whatever you want. If you are using the Survivors script then you can do the same thing in that same elseif to change the Crew variable.

### Available Special Actions

1) In Game Timer - all needed code is in the Special Action.


2) Deploy Recon unit from a ship or sub. Each ship or sub can deploy one recon unit. In order to do so the ship or sub must be within  a set distance from land (default 2.5 miles but configurable in the Action code), and must be traveling at less than 6 mph, and at a depth of less than 31m. the code for this is loaded on scen load via a lua action. The Special Action code is just to call the main function. When using the Special Action the user will be prompted for a bearing to send the recon team out on, and that is where the check for land worthyness will happen. If you don't want ships or subs to be able to deploy a recon team just delete the Special Action. If you want to limit the number of units that can deploy a recon unit an easy hack is to make more than one Special Action but make them not repeatable. This would not limit which units could deploy a recon unit, but you would be limiting how many recon teams could be deployed.

### Available Functions 

Below is a list of functions already loaded into this scenario via on Scenario Load Events.

There are 5 Lua actions loading functions on scen load.

1) SAR - Downed Pilot - Survivors Script (via angster/TyphoonFr modified by Whicker) - (Actually 2 Actions for these)  
2) Create Random Bios (via Whicker)  
3) Place Unit Randomly (via Whicker / KnightHawk75)  
4) Deploy Recon team from subs/ships  
5) Misc Helpers (via https://github.com/rjstone/cmano-lua-helpers)  

#### Survivors Script

The Survivors Script is loaded but not enabled. You can enable it by going to the Blue Unit Destroyed Action and un-commenting the last line. There are other Survivor related bits here and there but they can be ignored if you are not using it. That one line is what creates a Survivor.

There are additional configuration options for the Survivors Script located in the main script located under actions - Lua - Load SAR Script.

The potential number of survivors can be controlled by the number of crew passed in. This can be done in the same manner and in the same elseif section as the Lua scoring.

###### function W_RandomBios(side,topLeftPoint,topRightPoint,bottomRightPoint,bottomLeftPoint,spacingInMiles,minDepth,distanceJitter,angleJitter, addMoreColumns, addMoreRows)  
-- requires 4 Reference points (should be a rectangle)  
-- requires Tool_EmulateNoConsole(true) if running from the console or you get a mission error    
-- ex: W_RandomBios('Biologics','RP-1','RP-2','RP-3','RP-4',37,-40,10,10,2,2)  
-- minDepth should be negative  
-- the more jitter (angle or distance) the more random  


###### function W_PlaceUnitRandomly(side, ship, distance, bmin, bmax, mindepth,randomalt)  
-- side and ship are only required parameters, if you need one at the end then you have to set all previous ones  
-- bmin and bmax default to 1 and 360, used to control bearing of where unit can move to ex bmin=90, bmax=180 unit will be placed south east of current location if possible.  
-- distance defaults to 100 miles  
-- minDepth defaults to -20 meters  
-- randomalt is for AC  (boolean) defaults to false, you can set depth to anything it is ignored for AC (use 0)   
-- W_PlaceUnitRandomly('Blue', 'CG 16 Leahy', 125, 30, 230, -100)   
-- W_PlaceUnitRandomly('Blue', 'F-14D Tomcat', 125,1,33,0,true)  

function W_GetUnitProps(unitName)
--prints full unit wrapper    
--W_GetUnitProps({name='F-14D Tomcat', guid='78407e18-3841-4f63-bcc2-df202cc3dc3c'})
--W_GetUnitProps('F-14D Tomcat')

function W_GetSideProps(sideName)  
--prints full Side wrapper wrapper, may be memory hog  
--W_GetSideProps('Red')  

function W_GetSideUnitTotals(sideName)  
--prints the number of ships, subs, AC and facilities on a side, may be memory hog  
--W_GetSideUnitTotals('Red')  

function W_GetTableCount(table)  
-- Count the number of items in a table regardless of table type.   

function W_PathOffset()  
 -- calculates a small number like .002 to be used as an offset to a course (Escape from port uses this)  
--  offset = W_PathOffset() or print(W_PathOffset)  

function W_GetCourse(side,unitname)  
 -- prints the course of the unit passed in, use this to get a course to escape from a port (also returns it)  
--  W_GetCourse('Blue','F-14D Tomcat')  

function W_EscapeFromPort(unitx,newCourse)  
 -- used to help ships escape a port. Create an Event with trigger of unit enters area (around port but not including it)  
--  You need to create a course that will work, then assign that to a variable (NOT local) and pass it in along with unitx   
You can also use it with a specific unit by passing in a table with the guid - name is optional but it comes along with it when you right click and choose get Unit ID. This also works if you pass in the function for W_GetCourse with a unit specified in that.  
-- W_EscapeFromPort({name='CG 16 Leahy', guid='cde0f12a-3eec-4613-8527-fa9fc92ec98f'},course)  
-- W_EscapeFromPort({name='CG 16 Leahy', guid='cde0f12a-3eec-4613-8527-fa9fc92ec98f'}, W_GetCourse('Blue','F-14D Tomcat'))  

function W_OverWater(latitude, longitude)  
-- check if location is over water, returns true/yes if over water  
-- print(W_OverWater('26.7837580250281','-72.7095962123351'))  

function W_RandomLetter()  
-- returns a random uppercase letter. Used to modify a unit name  
-- print(W_RandomLetter())  

function W_DrawRPCircleAroundUnit(sidename, unit_name, radius, numpts, nameprefix, firstindex)  
 -- Draw 5nmi radius circle around "US" unit named "My Ship" with 12 points labeled B-1 to B-12  
--  W_DrawRPCircleAroundUnit("Blue", "F-14D Tomcat", 5, 12, "B-", 1)  

function W_DrawRPCircle(sidename, location, radius, numpts, nameprefix, firstindex)  
-- Draw a 30nmi radius circle for side "Blue" around Atlanta with 12 points labeled ATL-1 through ATL-12 like a clock.  
-- W_DrawRPCircle("Blue", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30, 12, "ATL-", 1)    
-- Last three arguments are optional and have default values if not specified.  
-- W_DrawRPCircle("Blue", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30)  

function W_DeleteReferencePointsByPrefix(sidename, prefix, firstindex, lastindex)  
-- Delete all reference points for a side with a given prefix and a given range of numbers after the prefix.  
-- Does not return true/false Example usage:  
-- Delete all reference points for "Blue" named B-1 through B-12.  
-- W_DeleteReferencePointsByPrefix("Blue", "B-", 1, 12)  

function W_AssignUnitsToMission(nameprefix, startcount, endcount, missioname)  
-- Assign Units to Mission by name prefix  
-- Written by Kevin Kinscherf (2016-12-9)  
-- "Functionized" by NimrodX  
-- Usage example:  
-- W_AssignUnitsToMission("Hawk #", 1, 3, "test") assigns Hawk #'s 1-3 to mission test 


function W_TimeFromNow(MinutesFromNow)  
-- returns the time x minutes from now in a format that can be used to set a mission start time, or a trigger time. Used by W_SetMissionStartTime  
-- currentMission.starttime =W_TimeFromNow(60)  
-- print(W_TimeFromNow(120))  

function W_SetMissionStartTime(sideName,missionName,minutesFromNow)  
-- Set mission to start x minutes from current game time "now"  
-- W_SetMissionStartTime('Blue','test',120)  

function W_ActivateMission(sideName,missionName)  
-- Set a mission active by side,name.  
 
function W_DeactivateMission(sideName,missionName)  
-- Set mission inactive by side,name.   

function W_RefuelUnitIfLow(side, name, minfuel, fueltype)  
-- Refuel Unit if Low  
-- This will change the onboard fuel for an aircraft depending upon some condition.  
-- If the fuel level goes below 'minfuel' it will be reset to the maximum allowed for the aircraft.  
-- To check this level constantly there must be a trigger condition such as one based on time that checks  
-- every 15 minutes. So call this in the action for that repeatable event.  
-- Example usage:  
-- W_RefuelUnitIfLow("Civilian", "Jumbo Jet", 22000) -- refuel to max if fuel gets below 22,000  
-- Defaults to airplane fuel but a different fuel type can be set as the 4th argument.   

function W_ConfirmSpecialAction(actionDescription)  
-- pops up a special mesage box to confirm you want to execute a special action  
