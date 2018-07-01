math.randomseed(os.time());
-- Check and set hour, used to track hour of day
local halfHour = ScenEdit_GetKeyValue("HalfHour");
halfHour = tonumber(halfHour);
if halfHour == nil then
halfHour = 30; --assume scen starts at midnight, adjust if not
print("halfHour for Scen Loaded Event = " ..halfHour); 
ScenEdit_SetWeather(15,0,0,1);
ScenEdit_SetKeyValue("HalfHour", tostring(halfHour));
local earlyClouds = math.random(8,10)/10;
ScenEdit_SetKeyValue("EarlyClouds", tostring(earlyClouds));
end




math.randomseed(os.time());
-- Check and set hour, used to track hour of day
local halfHour = 34;
ScenEdit_SetWeather(15,0,0,1);
ScenEdit_SetKeyValue("HalfHour",  tostring(halfHour));
local earlyClouds = math.random(8,10)/10;
ScenEdit_SetKeyValue("EarlyClouds", tostring(earlyClouds));
print("Scen loaded halfhour = " ..halfHour); 