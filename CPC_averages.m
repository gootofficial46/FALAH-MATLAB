% MATLAB script to process sleep data from Excel

% Read Excel file
data = readtable('Prelim_Results_ID_Boarding.xlsx', 'ReadVariableNames', true);

% Convert calendar_date to datetime
data.calendar_date = datetime(strtrim(string(data.calendar_date)), 'InputFormat', 'yyyy-MM-dd');

% Convert timestamps to datetime format, handling empty cells
data.sleeponset_ts = datetime(strtrim(string(data.sleeponset_ts)), 'InputFormat', 'HH:mm:ss', 'Format', 'HH:mm:ss');
data.wakeup_ts = datetime(strtrim(string(data.wakeup_ts)), 'InputFormat', 'HH:mm:ss', 'Format', 'HH:mm:ss');
data.sleepMidpoint = datetime(strtrim(string(data.sleepMidpoint)), 'InputFormat', 'HH:mm:ss', 'Format', 'HH:mm:ss');

% Convert ID column to string to handle cell type
data.ID = string(data.ID);

% Function to convert time to hours since previous midnight
convertToElapsedHours = @(t) hours(timeofday(t));

% Identify unique participants
participants = unique(data.ID);

% Initialize result table
results = table();

for i = 1:length(participants)
    participantID = participants(i);
    participantData = data(strcmp(data.ID, participantID), :);
    boardingStatus = unique(participantData.BoardingStatus); % Assume unique per participant
    
    % Determine weekend and weekday nights
    weekendData = participantData(weekday(participantData.calendar_date) == 6 | weekday(participantData.calendar_date) == 7, :);
    weekdayData = participantData(~ismember(weekday(participantData.calendar_date), [6, 7]), :);
    
    % Convert time to elapsed hours for proper averaging
    weekend_sleeponset_hours = convertToElapsedHours(weekendData.sleeponset_ts);
    weekend_wakeup_hours = convertToElapsedHours(weekendData.wakeup_ts);
    weekend_midpoint_hours = convertToElapsedHours(weekendData.sleepMidpoint);
    
    weekday_sleeponset_hours = convertToElapsedHours(weekdayData.sleeponset_ts);
    weekday_wakeup_hours = convertToElapsedHours(weekdayData.wakeup_ts);
    weekday_midpoint_hours = convertToElapsedHours(weekdayData.sleepMidpoint);
    
    % Handle past-midnight cases (e.g., sleep onset at 23:30, wake at 07:00)
    weekend_sleeponset_hours(weekend_sleeponset_hours < 12) = weekend_sleeponset_hours(weekend_sleeponset_hours < 12) + 24;
    weekday_sleeponset_hours(weekday_sleeponset_hours < 12) = weekday_sleeponset_hours(weekday_sleeponset_hours < 12) + 24;
    
    % Compute correct averages in hours
    avg_weekend_sleeponset = mean(weekend_sleeponset_hours, 'omitnan');
    avg_weekend_wakeup = mean(weekend_wakeup_hours, 'omitnan');
    avg_weekend_sleepDuration = mean(weekendData.sleepDuration, 'omitnan');
    avg_weekend_sleepMidpoint = mean(weekend_midpoint_hours, 'omitnan');
    
    avg_weekday_sleeponset = mean(weekday_sleeponset_hours, 'omitnan');
    avg_weekday_wakeup = mean(weekday_wakeup_hours, 'omitnan');
    avg_weekday_sleepDuration = mean(weekdayData.sleepDuration, 'omitnan');
    avg_weekday_sleepMidpoint = mean(weekday_midpoint_hours, 'omitnan');
    
    % Convert averaged hours back to valid 24-hour time format
    avg_weekend_sleeponset = duration(0, 0, mod(avg_weekend_sleeponset, 24) * 3600);
    avg_weekend_wakeup = duration(0, 0, mod(avg_weekend_wakeup, 24) * 3600);
    avg_weekend_sleepMidpoint = duration(0, 0, mod(avg_weekend_sleepMidpoint, 24) * 3600);
    
    avg_weekday_sleeponset = duration(0, 0, mod(avg_weekday_sleeponset, 24) * 3600);
    avg_weekday_wakeup = duration(0, 0, mod(avg_weekday_wakeup, 24) * 3600);
    avg_weekday_sleepMidpoint = duration(0, 0, mod(avg_weekday_sleepMidpoint, 24) * 3600);
    
    % Append to results without including calendar_date
    results = [results; table(participantID, boardingStatus, avg_weekend_sleeponset, avg_weekend_wakeup, avg_weekend_sleepDuration, avg_weekend_sleepMidpoint, avg_weekday_sleeponset, avg_weekday_wakeup, avg_weekday_sleepDuration, avg_weekday_sleepMidpoint)];
end

% Save results to new Excel file
writetable(results, 'Averaged_Sleep_Data.xlsx');







