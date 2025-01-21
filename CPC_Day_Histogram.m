% MATLAB script to process sleep data and create histograms
% Load the Excel file
data = readtable('Prelim_Results_ID.xlsx');

% Convert ID and calendar_date to strings and datetime respectively
data.ID = string(data.ID);
calendarDates = datetime(data.calendar_date, 'InputFormat', 'yyyy-MM-dd');

% Extract weekday information (1 = Sunday, 7 = Saturday)
weekdays = weekday(calendarDates);

% Identify weekday and weekend nights
isWeekend = (weekdays == 7) | (weekdays == 1); % Saturday (7) and Sunday (1)
isWeekday = ~isWeekend;

% Get unique participant IDs
participantIDs = unique(data.ID);

% Initialize counters for weekdays and weekends
weekdayCounts = zeros(size(participantIDs));
weekendCounts = zeros(size(participantIDs));

% Count the number of nights for each participant
for i = 1:length(participantIDs)
    participantData = data(data.ID == participantIDs(i), :); % Use string comparison
    participantDates = datetime(participantData.calendar_date, 'InputFormat', 'yyyy-MM-dd');
    participantWeekdays = weekday(participantDates);

    weekdayCounts(i) = sum((participantWeekdays ~= 7) & (participantWeekdays ~= 1));
    weekendCounts(i) = sum((participantWeekdays == 7) | (participantWeekdays == 1));
end

% Plot histograms for weekday and weekend nights
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

% Count the number of participants with sleep data for each day of the week
uniqueDays = 1:7; % Sunday (1) to Saturday (7)
participantsPerDay = zeros(size(uniqueDays));

for day = uniqueDays
    participantsWithData = unique(data.ID(weekday(calendarDates) == day));
    participantsPerDay(day) = numel(participantsWithData);
end

% Plot histogram for participants per day of the week
figure;
bar(uniqueDays, participantsPerDay);
title('Number of Participants with Sleep Data per Day of the Week');
xlabel('Day of the Week (1 = Sunday, 7 = Saturday)');
ylabel('Number of Participants');
grid on;
