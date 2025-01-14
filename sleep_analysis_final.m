
% Define the .csv file
csvFile = 'Sleep Summary Part 4.csv';

% Specify the column names
idColumn = 'filename';
dateColumn = 'calendar_date'; % Column for the date
sleepTimeColumn = 'sleeponset_ts'; % Column for sleep onset time
wakeTimeColumn = 'wakeup_ts'; % Column for wake time

% Step 1: Read the CSV file
try
    dataTable = readtable(csvFile);
catch
    error('Failed to read the CSV file. Ensure the file "%s" exists and is properly formatted.', csvFile);
end

% Step 2: Preprocess date and time columns
% Convert to strings if not already in string format
dataTable.(dateColumn) = string(dataTable.(dateColumn));
dataTable.(sleepTimeColumn) = string(dataTable.(sleepTimeColumn));
dataTable.(wakeTimeColumn) = string(dataTable.(wakeTimeColumn));

% Trim leading/trailing whitespace
dataTable.(dateColumn) = strtrim(dataTable.(dateColumn));
dataTable.(sleepTimeColumn) = strtrim(dataTable.(sleepTimeColumn));
dataTable.(wakeTimeColumn) = strtrim(dataTable.(wakeTimeColumn));

% Handle missing or invalid values by assigning default placeholders
dataTable.(dateColumn)(ismissing(dataTable.(dateColumn))) = "1970-01-01";
dataTable.(sleepTimeColumn)(ismissing(dataTable.(sleepTimeColumn))) = "00:00:00";
dataTable.(wakeTimeColumn)(ismissing(dataTable.(wakeTimeColumn))) = "00:00:00";

% Combine date and time into datetime columns with explicit format
try
    dataTable.sleepOnsetDatetime = datetime(dataTable.(dateColumn) + " " + dataTable.(sleepTimeColumn), ...
                                            'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    dataTable.wakeTimeDatetime = datetime(dataTable.(dateColumn) + " " + dataTable.(wakeTimeColumn), ...
                                          'InputFormat', 'yyyy-MM-dd HH:mm:ss');
catch
    error('Error combining date and time columns. Ensure the data format matches "yyyy-MM-dd HH:mm:ss".');
end

% Step 3: Adjust for overnight sleep (onset before midnight, wake after midnight)
overnight = dataTable.wakeTimeDatetime < dataTable.sleepOnsetDatetime;
dataTable.wakeTimeDatetime(overnight) = dataTable.wakeTimeDatetime(overnight) + days(1);

% Step 4: Calculate sleep duration and handle negative durations
dataTable.sleepDuration = hours(dataTable.wakeTimeDatetime - dataTable.sleepOnsetDatetime);
if any(dataTable.sleepDuration < 0)
    warning('Negative sleep durations detected. Removing problematic rows.');
    dataTable(dataTable.sleepDuration < 0, :) = [];
end

% Step 5: Calculate sleep midpoint (only the time component using timeofday)
dataTable.sleepMidpoint = timeofday(dataTable.sleepOnsetDatetime + (dataTable.wakeTimeDatetime - dataTable.sleepOnsetDatetime) / 2);

% Step 6: Extract weekdays and classify them into weekend (Friday & Saturday) or weekday
dataTable.weekday = weekday(dataTable.(dateColumn)); % 1 = Sunday, 7 = Saturday
dataTable.isWeekend = ismember(dataTable.weekday, [6, 7]); % 6 = Friday, 7 = Saturday

% Step 7: Group data by filename and perform t-tests on sleep midpoint data
filenames = unique(dataTable.(idColumn));
numFiles = length(filenames);

% Preallocate results table
fileResults = table(cell(numFiles, 1), NaN(numFiles, 1), NaN(numFiles, 1), ...
    NaN(numFiles, 1), NaN(numFiles, 1), NaN(numFiles, 1), NaN(numFiles, 1), ...
    NaN(numFiles, 1), ...
    'VariableNames', {'Filename', 'HypothesisRejected', 'PValue', 'CILower', 'CIUpper', ...
    'TStatistic', 'DegreesFreedom', 'StandardDeviation'});

% Populate results table
for i = 1:numFiles
    fileName = filenames{i};
    fileData = dataTable(strcmp(dataTable.(idColumn), fileName), :);
    
    % Extract sleep midpoints for weekends and weekdays
    weekendMidpoints = hours(fileData.sleepMidpoint(fileData.isWeekend));
    weekdayMidpoints = hours(fileData.sleepMidpoint(~fileData.isWeekend));
    
    % Perform t-test if both groups have data
    if ~isempty(weekendMidpoints) && ~isempty(weekdayMidpoints)
        [h, p, ci, stats] = ttest2(weekendMidpoints, weekdayMidpoints);
    else
        h = NaN; p = NaN; ci = [NaN, NaN]; stats = struct('tstat', NaN, 'df', NaN, 'sd', NaN);
    end
    
    % Assign results to the preallocated table
    fileResults.Filename{i} = fileName;
    fileResults.HypothesisRejected(i) = h;
    fileResults.PValue(i) = p;
    fileResults.CILower(i) = ci(1);
    fileResults.CIUpper(i) = ci(2);
    fileResults.TStatistic(i) = stats.tstat;
    fileResults.DegreesFreedom(i) = stats.df;
    fileResults.StandardDeviation(i) = stats.sd;
end

% Step 8: Save grouped data and t-test results to an Excel file
outputFile = 'Final_TTest_Per_Participant.xlsx';

% Save the grouped data by filename
originalDataGrouped = sortrows(dataTable(:, {idColumn, dateColumn, sleepTimeColumn, wakeTimeColumn, 'sleepDuration', 'sleepMidpoint'}), idColumn);
writetable(originalDataGrouped, outputFile, 'Sheet', 'Grouped Data');

% Save the t-test results for each filename
writetable(fileResults, outputFile, 'Sheet', 'T-Test Results');

fprintf('Grouped data and results have been saved to %s\n', outputFile);
