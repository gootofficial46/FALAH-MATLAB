% MATLAB script to process sleep data, create histograms, and update Excel file

% Load the Excel file
data = readtable('Prelim_Results_ID_Boarding.xlsx');

% Exclude rows without a participant ID
data = data(~ismissing(data.ID) & data.ID ~= "", :);

% Convert calendar_date to datetime
calendarDates = datetime(data.calendar_date, 'InputFormat', 'yyyy-MM-dd');

% Extract weekday information (1 = Sunday, ..., 7 = Saturday)
weekdays = weekday(calendarDates);

% Identify weekend nights (Friday = 6, Saturday = 7)
isWeekend = (weekdays == 6) | (weekdays == 7); % Friday and Saturday
isWeekday = ~isWeekend;

% Ensure IDs are treated as strings
data.ID = string(data.ID);

% Get unique participant IDs
participantIDs = unique(data.ID);

% Initialize counters for weekdays and weekends
weekdayCounts = zeros(size(participantIDs));
weekendCounts = zeros(size(participantIDs));

% Initialize a table to store participant-level results
resultTable = table(participantIDs, weekdayCounts, weekendCounts, ...
    'VariableNames', {'ID', 'WeekdayNights', 'WeekendNights'});

% Count the number of nights for each participant
for i = 1:length(participantIDs)
    % Filter data for the current participant
    participantData = data(data.ID == participantIDs(i), :);

    % Extract unique calendar dates for the participant
    participantDates = unique(datetime(participantData.calendar_date, 'InputFormat', 'yyyy-MM-dd'));

    % Determine weekdays for the participant's dates
    participantWeekdays = weekday(participantDates);

    % Count weekday and weekend nights
    weekdayCounts(i) = sum(~((participantWeekdays == 6) | (participantWeekdays == 7))); % Exclude Friday and Saturday
    weekendCounts(i) = sum((participantWeekdays == 6) | (participantWeekdays == 7));   % Only Friday and Saturday
end

% Update result table with counts
resultTable.WeekdayNights = weekdayCounts;
resultTable.WeekendNights = weekendCounts;

% Write updated data back to Excel
writetable(resultTable, 'Prelim_Results_ID_Boarding_Updated.xlsx', 'Sheet', 1);

% Plot histograms
figure;
histogram(weekdayCounts);
title('Histogram of Weekday Nights');
xlabel('Number of Weekday Nights');
ylabel('Number of Participants');
grid on;

figure;
histogram(weekendCounts);
title('Histogram of Weekend Nights');
xlabel('Number of Weekend Nights');
ylabel('Number of Participants');
grid on;

fprintf('Updated Excel file created: Prelim_Results_ID_Boarding_Updated.xlsx\n');
