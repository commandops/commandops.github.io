math.randomseed(os.time());
local scenarioWeather = ScenEdit_GetWeather();
local clouds = scenarioWeather.undercloud;
-- Check and set hour, used to track hour of day
local halfHour = ScenEdit_GetKeyValue("HalfHour");
halfHour = tonumber(halfHour);
-- early clouds is used for the early morning hours to have the change be slower
local earlyClouds = ScenEdit_GetKeyValue("EarlyClouds");
earlyClouds = tonumber(earlyClouds);
print("halfHour = " ..halfHour);
print("early clouds = " ..earlyClouds);

if halfHour >=0 and halfHour <=10  then
halfHour = halfHour + 1;
local rain = 0;
local seas = 1
-- if there is heavy fog add light rain
	if earlyClouds >= 1.06 then 
		rain = 4;
		seas = 3
	end
ScenEdit_SetWeather(28,rain,earlyClouds,seas);
ScenEdit_SetKeyValue("HalfHour", tostring(halfHour));
earlyClouds = earlyClouds - .02;
ScenEdit_SetKeyValue("EarlyClouds", tostring(earlyClouds));

elseif halfHour >= 11 and halfHour <=35 then
clouds = clouds - .04;
  if clouds <= .05 then clouds = 0;
  end
halfHour = halfHour + 1;
ScenEdit_SetWeather(31,0,clouds,2);
ScenEdit_SetKeyValue("HalfHour", tostring(halfHour));

elseif halfHour >=36 and halfHour <=46 then
clouds = clouds +.07;
halfHour = halfHour + 1;
ScenEdit_SetWeather(29,0,clouds,3);
ScenEdit_SetKeyValue("HalfHour", tostring(halfHour));

elseif halfHour == 47 then
clouds = .7;
halfHour = 0;
ScenEdit_SetWeather(29,0,clouds,2);
local w = ScenEdit_GetWeather();
local wtemp = w.temp;
local wclouds = w.undercloud;
local wseas = w.seastate;
local wrain = w.rainfall;
ScenEdit_SetKeyValue("HalfHour", tostring(halfHour));
--reset earlyClouds - random, 1.1 is heavy fog, .7 is cloudy
earlyClouds = math.random(7,11)/10;
ScenEdit_SetKeyValue("EarlyClouds", tostring(earlyClouds));
print (earlyClouds);
local TimeVar = ScenEdit_CurrentTime();
TimeVar = TimeVar + 7200; --adjust time to key west
local time = (os.date("%A %B %d %H%M ",TimeVar));

local fogMessage = "";
local veryHeavyFog = "*****VERY HEAVY FOG TONIGHT, LIGHT RAIN*****<br><br>We expect to see very heavy fog and light rain starting in the next 30-40 minutes, the Sea State will also increase slightly while it is raining. The rain should not last long. The fog will last for several hours, then should begin to clear by 0600. Solid low clouds will persist till mid morning. We expect clear skies for at least an hour or two in the late afternoon."
local heavyFog = "***HEAVY FOG TONIGHT***<br><br>We expect to see heavy fog starting in the next 30-40 minutes, lasting for several hours. The fog should begin to clear by 0430. Solid low clouds will persist till mid morning. We expect clear skies for at least an hour or two in the late afternoon."
local moderateFog = "**MODERATE FOG TONIGHT**<br><br>We expect to see fog tonight starting in the next 30-40 minutes, lasting for a couple hours. The fog should begin to clear by 0300. Solid low clouds should start to break up by early morning. We expect clear skies for a few hours this afternoon."
--local lightFog = "***LIGHT FOG TONIGHT*** We expect to see fog tonight starting in the next hour, lasting for an hour or so. It should clear quickly and we still expect clear skies for several hours this afternoon."
local noFog = "No fog tonight, skies should be clear by late morning with several hours of clear skies."
  	if earlyClouds <= .8 then fogMessage = noFog;
  		elseif earlyClouds == .9 then fogMessage = moderateFog;
  			elseif earlyClouds == 1 then fogMessage = heavyFog;
  				elseif earlyClouds == 1.1 then fogMessage = veryHeavyFog;
  			end

ScenEdit_SpecialMessage(ScenEdit_PlayerSide(), '<div style="text-transform: uppercase;font-family:Courier New;"><p>' .. time .. ' (KeyWest)</p><P>COMMANDER,</P><P>CURRENT WEATHER REPORT,</P> TEMPERATURE: ' .. wtemp .. 'C (High: 41C, Low: 25C) <br>RAIN STATE: ' .. wrain .. '<br>CLOUD LEVEL: Moderate middle clouds, 7-16k feet, light high clouds 27-30k feet<br>SEA STATE: ' .. wseas .. '<p>' .. fogMessage .. '</p><p>It looks like the weather for the next few days should be more of the same, night and morning low clouds with a chance of fog in the very early morning hours.</p><p>Sea State has been fairly mild, usually 1-2 in the early morning, increasing to 3 in the afternoon and evening.</p></div>');
else
 print("Something is wrong, halfhour not set?");
end

print(ScenEdit_GetWeather());


