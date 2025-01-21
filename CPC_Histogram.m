% MATLAB script to process sleep data and create histograms
% Load the Excel file
data = readtable('Prelim_Results_ID.xlsx');

% Convert calendar_date to datetime
calendarDates = datetime(data.calendar_date, 'InputFormat', 'yyyy-MM-dd');

% Extract weekday information (1 = Sunday, 7 = Saturday)
weekdays = weekday(calendarDates);

% Identify weekday and weekend nights
isWeekend = (weekdays == 7) | (weekdays == 1); % Saturday (7) and Sunday (1)
isWeekday = ~isWeekend;

% Ensure IDs are treated as strings
data.ID = string(data.ID);

% Get unique participant IDs
participantIDs = unique(data.ID);

% Initialize counters for weekdays and weekends
weekdayCounts = zeros(size(participantIDs));
weekendCounts = zeros(size(participantIDs));

% Count the number of nights for each participant
for i = 1:length(participantIDs)
    participantData = data(data.ID == participantIDs(i), :);
    participantDates = datetime(participantData.calendar_date, 'InputFormat', 'yyyy-MM-dd');
    participantWeekdays = weekday(participantDates);

    weekdayCounts(i) = sum((participantWeekdays ~= 7) & (participantWeekdays ~= 1));
    weekendCounts(i) = sum((participantWeekdays == 7) | (participantWeekdays == 1));
end

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
