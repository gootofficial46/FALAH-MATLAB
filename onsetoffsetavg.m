% Load the Excel file
data = readtable('Averaged_Sleep_Data.xlsx');

% Convert time strings to numerical values (in hours)
timeToHours = @(t) hours(duration(t, 'InputFormat', 'hh:mm:ss'));

data.avg_weekend_sleeponset = timeToHours(data.avg_weekend_sleeponset);
data.avg_weekend_wakeup = timeToHours(data.avg_weekend_wakeup);
data.avg_weekday_sleeponset = timeToHours(data.avg_weekday_sleeponset);
data.avg_weekday_wakeup = timeToHours(data.avg_weekday_wakeup);

% Compute the mean for each category
mean_weekend_sleeponset = mean(data.avg_weekend_sleeponset, 'omitnan');
mean_weekend_wakeup = mean(data.avg_weekend_wakeup, 'omitnan');
mean_weekday_sleeponset = mean(data.avg_weekday_sleeponset, 'omitnan');
mean_weekday_wakeup = mean(data.avg_weekday_wakeup, 'omitnan');

% Convert back to HH:MM format
hoursToTime = @(h) datestr(h/24, 'HH:MM');

fprintf('Average Weekend Sleep Onset: %s\n', hoursToTime(mean_weekend_sleeponset));
fprintf('Average Weekend Wakeup: %s\n', hoursToTime(mean_weekend_wakeup));
fprintf('Average Weekday Sleep Onset: %s\n', hoursToTime(mean_weekday_sleeponset));
fprintf('Average Weekday Wakeup: %s\n', hoursToTime(mean_weekday_wakeup));