% Define the .csv file
csvFile = 'Sleep Summary Part 4.csv';

% Specify the column name that contains IDs
idColumn = 'filename';

% Specify the columns to be read for sleep onset and wake time
sleepOnsetColumn = 'sleeponset_ts'; % Column for sleep onset times
wakeTimeColumn = 'wakeup_ts';     % Column for wake times

% Specify the column name for the date of data collection
dateColumn = 'calendar_date'; % Update this to match your actual column name

% Step 1: Read the CSV file
try
    dataTable = readtable(csvFile);
catch
    error('Failed to read the CSV file. Ensure the file "%s" exists and is properly formatted.', csvFile);
end

% Step 2: Check if required columns exist
requiredColumns = {idColumn, sleepOnsetColumn, wakeTimeColumn, dateColumn};
missingColumns = setdiff(requiredColumns, dataTable.Properties.VariableNames);
if ~isempty(missingColumns)
    error('The following columns are missing in the data: %s', strjoin(missingColumns, ', '));
end

% Step 3: Ensure data columns are strings for processing
if ~iscell(dataTable.(sleepOnsetColumn))
    dataTable.(sleepOnsetColumn) = string(dataTable.(sleepOnsetColumn));
end
if ~iscell(dataTable.(wakeTimeColumn))
    dataTable.(wakeTimeColumn) = string(dataTable.(wakeTimeColumn));
end
if ~iscell(dataTable.(dateColumn))
    dataTable.(dateColumn) = string(dataTable.(dateColumn));
end

% Step 4: Convert time strings to numeric (fractions of a day)
try
    dataTable.SleepOnsetNumeric = timeToNumeric(dataTable.(sleepOnsetColumn));
    dataTable.WakeTimeNumeric = timeToNumeric(dataTable.(wakeTimeColumn));
catch ME
    rethrow(ME);
end

% Step 5: Convert dates to datetime format
try
    dataTable.DateCollected = datetime(dataTable.(dateColumn), 'InputFormat', 'yyyy-MM-dd'); % Adjust format as needed
catch
    error('Failed to convert dates in column "%s". Ensure the format matches "yyyy-MM-dd".', dateColumn);
end

% Step 6: Add a column for the day of the week
dataTable.DayOfWeek = day(dataTable.DateCollected, 'name');

% Step 7: Calculate the sleep midpoint for each row
dataTable.SleepMidpointNumeric = ...
    mod(dataTable.SleepOnsetNumeric + ...
    (dataTable.WakeTimeNumeric - dataTable.SleepOnsetNumeric) / 2, 1);

% Step 8: Convert numeric midpoint back to HH:mm format in 12-hour clock
dataTable.SleepMidpoint = numericToTime(dataTable.SleepMidpointNumeric);

% Step 9: Group data by unique IDs and display
uniqueIDs = unique(dataTable.(idColumn));
for i = 1:length(uniqueIDs)
    currentID = uniqueIDs{i};
    
    % Filter the data for the current ID
    filteredData = dataTable(strcmp(dataTable.(idColumn), currentID), :);
    
    % Display the grouped data under the ID heading
    fprintf('\nData for ID: %s\n', currentID);
    disp(filteredData(:, {dateColumn, 'DayOfWeek', sleepOnsetColumn, wakeTimeColumn, 'SleepMidpoint'}));
end

% Helper function: Convert time strings (HH:mm:ss or HH:mm) to numeric (fraction of a day)
function numericTime = timeToNumeric(timeStrings)
    % Ensure input is a string array
    if iscell(timeStrings)
        timeStrings = string(timeStrings);
    end
    
    % Initialize output array with the same number of rows as input
    numericTime = nan(size(timeStrings));
    
    % Parse each time string
    for i = 1:numel(timeStrings)
        timeParts = sscanf(char(timeStrings(i)), '%d:%d:%d'); % Split into [hours, minutes, seconds]
        if isempty(timeParts)
            error('Invalid time format: %s', timeStrings(i));
        elseif numel(timeParts) == 2
            timeParts(3) = 0; % Add seconds if not provided
        end
        % Convert to numeric
        numericTime(i) = (timeParts(1) + timeParts(2) / 60 + timeParts(3) / 3600) / 24;
    end
end

% Helper function: Convert numeric (fraction of a day) to time strings (HH:mm in 12-hour format with subtraction)
function timeStrings = numericToTime(numericTime)
    totalMinutes = round(numericTime * 24 * 60); % Convert to total minutes
    hours = mod(floor(totalMinutes / 60), 24);  % Ensure hours wrap around 24
    minutes = mod(totalMinutes, 60);

    % Subtract 12 from hours above 12
    adjustedHours = arrayfun(@(h) (h > 12) * (h - 12) + (h <= 12) * h, hours);
    
    % Convert to time strings
    timeStrings = arrayfun(@(h, m) sprintf('%02d:%02d', h, m), adjustedHours, minutes, 'UniformOutput', false);
end