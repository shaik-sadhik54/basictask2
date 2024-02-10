% Read temperature, pressure, and humidity data from a ThingSpeak channel over the past 24 hours 
% to calculate the high and low temperatures and write to another channel. 

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

% Check if tempF is not empty and has at least one row and one column
if ~isempty(tempF) && size(tempF, 2) >= 1
    % Calculate the maximum and minimum temperatures
    [maxTempF, maxTempIndex] = max(tempF(:, 1));
    [minTempF, minTempIndex] = min(tempF(:, 1));
    
    % Calculate the average temperature
    avgTemperature = nanmean(tempF(:, 1));
    
    % Display the maximum, minimum, and average temperatures
    disp(['Maximum Temperature for the past 24 hours is: ', num2str(maxTempF)]);
    disp(['Minimum Temperature for the past 24 hours is: ', num2str(minTempF)]);
    disp(['Average Temperature for the past 24 hours is: ', num2str(avgTemperature)]);
else
    % Display an error message if tempF is empty or has insufficient columns
    disp('Error: Temperature data not available');
    maxTempF = NaN;
    minTempF = NaN;
    avgTemperature = NaN;
end

% Check if humidity data is available
if size(tempF, 2) >= 3
    % Calculate the average humidity
    avgHumidity = nanmean(tempF(:, 3));
    disp(['Average Humidity for the past 24 hours is: ', num2str(avgHumidity)]);
else
    % Display an error message if humidity data is not available
    disp('Error: Humidity data not available');
    avgHumidity = NaN;
end

% Check if pressure data is available
if size(tempF, 2) >= 2
    % Calculate the average pressure
    avgPressure = nanmean(tempF(:, 2));
    disp(['Average Pressure for the past 24 hours is: ', num2str(avgPressure)]);
else
    % Display an error message if pressure data is not available
    disp('Error: Pressure data not available');
    avgPressure = NaN;
end

% Write maximum temperature, minimum temperature, average pressure, average temperature, and average humidity to another channel
writeChannelID = 1369893;
% Enter the Write API Key
writeAPIKey = 'YMAK01DU9P9V9AOD';

% Write maximum temperature, minimum temperature, average pressure, average temperature, and average humidity to another channel
thingSpeakWrite(writeChannelID, 'Fields', [3, 4, 2, 1, 5], 'Values', {maxTempF, minTempF, avgPressure, avgTemperature, avgHumidity}, 'WriteKey', writeAPIKey);

% Set up alerts for weather conditions
alertApiKey = 'TAKP7C5XU9ZEVJ8GFZRXC';
alertUrl = "https://api.thingspeak.com/alerts/send";
options = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertApiKey]);
alertSubject = sprintf("Weather Forecast Notification");

% Check weather conditions and send alerts
if(avgTemperature < 26 && avgHumidity > 80 && avgPressure < 100600)
    disp('It is expected to rain in 30 mins')
    alertBody = 'Chennai Weather Prediction today: It is expected to rain in 30 mins';
    % Send a rain forecast alert
    webwrite(alertUrl, "body", alertBody, "subject", alertSubject, options);
else
    disp('The weather is clear today!')
    alertBody = 'Chennai Weather Prediction today: The weather is clear today!';
end

