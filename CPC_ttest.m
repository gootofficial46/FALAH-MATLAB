% MATLAB script to process sleep data and perform analyses
% Load the Excel file
data = readtable('Prelim_Results_ID.xlsx');

% Convert ID and calendar_date to strings and datetime respectively
data.ID = string(data.ID);
calendarDates = datetime(data.calendar_date, 'InputFormat', 'yyyy-MM-dd');

% Extract weekday information (1 = Sunday, 7 = Saturday)
weekdays = weekday(calendarDates);

% Compare sleep midpoint on Saturday and Sunday nights using a t-test
% Convert time strings in sleepMidpoint to datetime
sleepMidpoints = datetime(data.sleepMidpoint, 'InputFormat', 'HH:mm:ss');

% Convert datetime to fractional hours (numeric representation)
sleepMidpoints = hour(sleepMidpoints) + minute(sleepMidpoints)/60 + second(sleepMidpoints)/3600;

% Check for invalid values
validIndices = ~isnan(sleepMidpoints) & ~isinf(sleepMidpoints);

% Filter valid entries
if ~any(validIndices)
    error('No valid numeric sleep midpoint data available after filtering.');
end

% Keep only valid data
sleepMidpoints = sleepMidpoints(validIndices);
calendarDates = calendarDates(validIndices);
weekdays = weekdays(validIndices);

% Extract sleep midpoint data for Saturday and Sunday nights
saturdayMidpoints = sleepMidpoints(weekdays == 6);
sundayMidpoints = sleepMidpoints(weekdays == 5);

% Perform a t-test
if isempty(saturdayMidpoints) || isempty(sundayMidpoints)
    fprintf('Insufficient data for Saturday or Sunday nights to perform a t-test.\n');
else
    [h, p] = ttest2(saturdayMidpoints, sundayMidpoints);
    fprintf('T-test results:\n');
    if h == 0
        fprintf('No significant difference in sleep midpoint between Saturday and Sunday nights (p = %.3f).\n', p);
    else
        fprintf('Significant difference in sleep midpoint between Saturday and Sunday nights (p = %.3f).\n', p);
    end
end