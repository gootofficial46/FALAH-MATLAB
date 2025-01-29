% MATLAB script to analyze sleep data and perform a t-test

% Load the Excel file
data = readtable('Prelim_Results_ID.xlsx');

% Convert ID and calendar_date to strings and datetime respectively
data.ID = string(data.ID);
if ismember('calendar_date', data.Properties.VariableNames)
    data.calendar_date = datetime(data.calendar_date, 'InputFormat', 'yyyy-MM-dd');
end

% Prompt the user to select a column
columnNames = data.Properties.VariableNames;
disp('Available columns:');
disp(columnNames);
selectedColumn = input('Enter the name of the column to analyze (e.g., sleepMidpoint, sleepDuration): ', 's');

% Ensure the selected column exists
if ~ismember(selectedColumn, columnNames)
    error('The selected column does not exist in the dataset.');
end

% Extract the selected column
selectedData = data.(selectedColumn);

% DEBUG: Check data type and print sample values
fprintf('Selected column data type: %s\n', class(selectedData));
disp('First few values of the selected column:');
disp(selectedData(1:5)); % Display first 5 values

% Detect and convert string-based time columns
if iscell(selectedData) || isstring(selectedData)
    fprintf('Detected string data in column: %s\n', selectedColumn);
    
    % Try converting to datetime (if it's a time of day like sleepMidpoint)
    try
        selectedData = datetime(selectedData, 'InputFormat', 'HH:mm:ss');
        fprintf('Converted column to datetime format.\n');
        isDuration = false;
    catch
        % If conversion fails, assume it represents a **duration** (like sleepDuration)
        fprintf('Column contains duration data (not a time of day). Converting to hours...\n');
        try
            durationData = duration(selectedData, 'InputFormat', 'hh:mm:ss');
            selectedData = hours(durationData); % Convert to fractional hours
            isDuration = true;
        catch
            error('Column contains non-time string data. Please select a valid column.');
        end
    end
else
    isDuration = false;
end

% Convert datetime times to fractional hours for analysis
if isdatetime(selectedData) && ~isDuration
    fprintf('Processing datetime data in column: %s\n', selectedColumn);
    selectedData = hour(selectedData) + minute(selectedData) / 60 + second(selectedData) / 3600;
end

% Ensure selected data is numeric before proceeding
if ~isnumeric(selectedData)
    error('Unsupported data type for analysis. Please select a numeric or time-based column.');
end

% Handle times spanning midnight (for sleepMidpoint)
if ~isDuration
    adjustedTimes = selectedData;
    adjustedTimes(adjustedTimes < 5) = adjustedTimes(adjustedTimes < 5) + 24; % Shift early times past midnight
else
    adjustedTimes = selectedData; % No adjustments needed for sleepDuration
end

% Prompt user to specify days for comparison
dayMapping = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
disp('Days of the week:');
disp(dayMapping);
day1 = input('Enter the name of the first day to compare: ', 's');
day2 = input('Enter the name of the second day to compare: ', 's');

% Validate input days
if ~ismember(day1, dayMapping) || ~ismember(day2, dayMapping)
    error('Invalid day(s) specified. Please choose from Sunday to Saturday.');
end

% Convert days to numeric weekday values
day1Idx = find(strcmp(dayMapping, day1));
day2Idx = find(strcmp(dayMapping, day2));

% Filter data for valid entries
validIndices = ~isnan(adjustedTimes) & ~isinf(adjustedTimes);
if ~any(validIndices)
    error('No valid data available in the selected column after filtering.');
end
adjustedTimes = adjustedTimes(validIndices);
weekdays = weekday(data.calendar_date(validIndices));

% Extract data for the specified days
day1Data = adjustedTimes(weekdays == day1Idx);
day2Data = adjustedTimes(weekdays == day2Idx);

% Check if sufficient data is available
if isempty(day1Data) || isempty(day2Data)
    error('Insufficient data for one or both days specified.');
end

% Calculate mean and SEM for each day
calculateStats = @(data) struct('mean', mean(data), 'sem', std(data) / sqrt(length(data)));
day1Stats = calculateStats(day1Data);
day2Stats = calculateStats(day2Data);

% Convert mean back to readable time format
if isDuration
    day1MeanTime = datestr(hours(day1Stats.mean), 'HH:MM:SS');
    day2MeanTime = datestr(hours(day2Stats.mean), 'HH:MM:SS');
else
    day1MeanTime = datestr(hours(mod(day1Stats.mean, 24)), 'HH:MM:SS');
    day2MeanTime = datestr(hours(mod(day2Stats.mean, 24)), 'HH:MM:SS');
end

% Perform a t-test
[h, p] = ttest2(day1Data, day2Data);

% Display results
fprintf('Results for %s:\n', day1);
fprintf('Mean = %s, SEM = %.3f hours\n', day1MeanTime, day1Stats.sem);
fprintf('Results for %s:\n', day2);
fprintf('Mean = %s, SEM = %.3f hours\n', day2MeanTime, day2Stats.sem);
fprintf('T-test results:\n');
if h == 0
    fprintf('No significant difference between %s and %s (p = %.3f).\n', day1, day2, p);
else
    fprintf('Significant difference between %s and %s (p = %.3f).\n', day1, day2, p);
end