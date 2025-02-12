% Load the Excel file
data = readtable('Averaged_Sleep_Data.xlsx');

% Convert time strings to durations
data.avg_weekday_sleeponset = duration(data.avg_weekday_sleeponset, 'InputFormat', 'hh:mm:ss');
data.avg_weekday_wakeup = duration(data.avg_weekday_wakeup, 'InputFormat', 'hh:mm:ss');
data.avg_weekend_sleeponset = duration(data.avg_weekend_sleeponset, 'InputFormat', 'hh:mm:ss');
data.avg_weekend_wakeup = duration(data.avg_weekend_wakeup, 'InputFormat', 'hh:mm:ss');

% Convert durations to numeric hours (handling crossing midnight cases)
timeToNumeric = @(t) hours(t); % Converts duration to numeric hours

weekday_sleeponset_hours = timeToNumeric(data.avg_weekday_sleeponset);
weekday_wakeup_hours = timeToNumeric(data.avg_weekday_wakeup);
weekend_sleeponset_hours = timeToNumeric(data.avg_weekend_sleeponset);
weekend_wakeup_hours = timeToNumeric(data.avg_weekend_wakeup);

% Adjust for times crossing midnight (e.g., 23:30 and 00:30 should average correctly)
weekday_sleeponset_hours(weekday_sleeponset_hours < 12) = weekday_sleeponset_hours(weekday_sleeponset_hours < 12) + 24;
weekday_wakeup_hours(weekday_wakeup_hours < 12) = weekday_wakeup_hours(weekday_wakeup_hours < 12) + 24;
weekend_sleeponset_hours(weekend_sleeponset_hours < 12) = weekend_sleeponset_hours(weekend_sleeponset_hours < 12) + 24;
weekend_wakeup_hours(weekend_wakeup_hours < 12) = weekend_wakeup_hours(weekend_wakeup_hours < 12) + 24;

% Compute the correct mean
mean_weekday_sleeponset = mean(weekday_sleeponset_hours, 'omitnan');
mean_weekday_wakeup = mean(weekday_wakeup_hours, 'omitnan');
mean_weekend_sleeponset = mean(weekend_sleeponset_hours, 'omitnan');
mean_weekend_wakeup = mean(weekend_wakeup_hours, 'omitnan');

% Convert means back to HH:MM format (handling 24+ hour cases)
numericToTime = @(h) datestr(mod(h, 24)/24, 'HH:MM');

avg_weekday_sleeponset_time = numericToTime(mean_weekday_sleeponset);
avg_weekday_wakeup_time = numericToTime(mean_weekday_wakeup);
avg_weekend_sleeponset_time = numericToTime(mean_weekend_sleeponset);
avg_weekend_wakeup_time = numericToTime(mean_weekend_wakeup);

% Display Results
disp(['Average Weekday Sleep Onset: ', avg_weekday_sleeponset_time]);
disp(['Average Weekday Wake Up: ', avg_weekday_wakeup_time]);
disp(['Average Weekend Sleep Onset: ', avg_weekend_sleeponset_time]);
disp(['Average Weekend Wake Up: ', avg_weekend_wakeup_time]);
