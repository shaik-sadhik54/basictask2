% Read temperature, pressure, and humidity data from a ThingSpeak channel over the past 24 hours 
% to calculate the average values and write to another channel. 
% The system also generates alerts based on temperature and pressure conditions.

% Channel ID to read data from
readChannelID = 1369889;
% Field IDs
TemperatureFieldID = 1;
PressureFieldID = 2;
HumidityFieldID = 3;
% Channel Read API Key
readAPIKey = 'TI15UDZ38496FELU';

% Read temperature, pressure, and humidity data for the last 24 hours from the channel.
[tempF, timeStamp] = thingSpeakRead(readChannelID, 'Fields', [TemperatureFieldID, PressureFieldID, HumidityFieldID], ...
    'numDays', 1, 'ReadKey', readAPIKey);

% Check if tempF is empty or does not have sufficient columns
if isempty(tempF) || size(tempF, 2) < 3
    error('Temperature, Pressure, or Humidity data is not available or does not have sufficient columns.');
end

% Calculate averages
avgTemperature = nanmean(tempF(:, 1)); % Average temperature
avgPressure = nanmean(tempF(:, 2)); % Average pressure
avgHumidity = nanmean(tempF(:, 3)); % Average humidity

% Display average values
disp(['Average Temperature for the past 24 hours is: ', num2str(avgTemperature)]);
disp(['Average Pressure for the past 24 hours is: ', num2str(avgPressure)]);
disp(['Average Humidity for the past 24 hours is: ', num2str(avgHumidity)]);



