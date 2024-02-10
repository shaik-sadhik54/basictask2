% Weather Report System

% Channel ID to read data from
readChannelID = 1369889;
% Field IDs
TemperatureFieldID = 1;
HumidityFieldID = 2;
RainfallFieldID = 3;
% Channel Read API Key
readAPIKey = 'TI15UDZ38496FELU';


% Read temperature, humidity, and rainfall data for the last 24 hours from the channel.
[data, timeStamp] = thingSpeakRead(readChannelID, 'Fields', [TemperatureFieldID, HumidityFieldID, RainfallFieldID], ...
    'numDays', 1, 'ReadKey', readAPIKey);

% Check if data is empty
if isempty(data)
    disp('Error: No data retrieved from the channel.');
    return; % Exit the script
end

% Check if the data array has at least 1 row and 3 columns
if size(data, 1) < 1 || size(data, 2) < 3
    disp('Error: Insufficient data retrieved from the channel.');
    return; % Exit the script
end

avgTemperature = nanmean(data(:,1)); % Average temperature
avgHumidity = nanmean(data(:,2)); % Average humidity
totalRainfall = nansum(data(:,3)); % Total rainfall

display(avgTemperature, 'Average Temperature for the past 24 hours is');
display(avgHumidity, 'Average Humidity for the past 24 hours is');
display(totalRainfall, 'Total Rainfall for the past 24 hours is');

% Write average temperature, humidity, and total rainfall to another channel
writeChannelID = YOUR_WRITE_CHANNEL_ID;
% Write API Key
writeAPIKey = 'YOUR_WRITE_API_KEY';

thingSpeakWrite(writeChannelID, 'Fields', [1, 2, 3], 'Values', {avgTemperature, avgHumidity, totalRainfall}, 'WriteKey', writeAPIKey);

% Alerts for extreme events
alertApiKey = 'YOUR_ALERT_API_KEY';
alertUrl = "https://api.thingspeak.com/alerts/send";
options = weboptions("HeaderFields", ["ThingSpeak-Alerts-API-Key", alertApiKey]);
alertSubject = sprintf("Weather Report Alert");

if avgTemperature > 35
    disp('Extreme Heat Alert!')
    alertBody = 'Extreme Heat Alert! Take necessary precautions.';
    % Send a red alert
    webwrite(alertUrl, "body", alertBody, "subject", alertSubject, options);
elseif totalRainfall > 100
    disp('Heavy Rainfall Alert!')
    alertBody = 'Heavy Rainfall Alert! Be prepared for flooding.';
    % Send a red alert
    webwrite(alertUrl, "body", alertBody, "subject", alertSubject, options);
elseif totalRainfall > 50 || avgTemperature > 30
    disp('Yellow Alert: Possible Rain or High Temperature')
    alertBody = 'Yellow Alert: Possible Rain or High Temperature. Stay vigilant.';
    % Send a yellow alert
    webwrite(alertUrl, "body", alertBody, "subject", alertSubject, options);
else
    disp('No extreme events detected.')
end
