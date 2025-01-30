% Load Data
data = readtable('Averaged_Sleep_Data.xlsx'); % Ensure correct filename

% Check Available Columns
disp(data.Properties.VariableNames);

% Ensure required columns exist
if ~all(ismember({'avg_weekday_sleepMidpoint', 'avg_weekend_sleepMidpoint', 'rural_urban'}, data.Properties.VariableNames))
    error('Required columns not found. Ensure the dataset has "avg_weekday_sleepMidpoint", "avg_weekend_sleepMidpoint", and "rural_urban".');
end

% Convert timestamps stored as cell arrays
convertToHours = @(x) hour(datetime(string(x), 'InputFormat', 'HH:mm:ss')) + ...
                      minute(datetime(string(x), 'InputFormat', 'HH:mm:ss')) / 60 + ...
                      second(datetime(string(x), 'InputFormat', 'HH:mm:ss')) / 3600;

if iscell(data.avg_weekday_sleepMidpoint)
    weekdayMidpoints = convertToHours(data.avg_weekday_sleepMidpoint);
else
    weekdayMidpoints = convertToHours(string(data.avg_weekday_sleepMidpoint));
end

if iscell(data.avg_weekend_sleepMidpoint)
    weekendMidpoints = convertToHours(data.avg_weekend_sleepMidpoint);
else
    weekendMidpoints = convertToHours(string(data.avg_weekend_sleepMidpoint));
end

% Debug: Print first few values to confirm conversion
disp('Sample converted weekday sleep midpoints:');
disp(weekdayMidpoints(1:5));

disp('Sample converted weekend sleep midpoints:');
disp(weekendMidpoints(1:5));

% Ensure rural_urban column is categorical
data.rural_urban = categorical(data.rural_urban);

% Convert rural_urban to string if it’s categorical or another format
if iscategorical(data.rural_urban)
    data.rural_urban = string(data.rural_urban); % Convert categorical to string
elseif isnumeric(data.rural_urban)
    error("rural_urban column is numeric, please check dataset!"); % Unexpected case
elseif iscell(data.rural_urban)
    data.rural_urban = string(data.rural_urban); % Convert cell array to string
end

% Trim spaces and standardize to lowercase
data.rural_urban = strtrim(lower(data.rural_urban));

% Debug: Print unique values to check for issues
disp("Unique values in rural_urban column:");
disp(unique(data.rural_urban));

% Ensure indexes are logical and match data size
urbanIdx = find(data.rural_urban == "urban");
ruralIdx = find(data.rural_urban == "rural");

% Debug: Print first few indexes
fprintf("First few Urban Indexes: %s\n", mat2str(urbanIdx(1:min(5,end))));
fprintf("First few Rural Indexes: %s\n", mat2str(ruralIdx(1:min(5,end))));

% Extract Sleep Midpoints (ENSURING Correct Indexing)
weekdayUrban = weekdayMidpoints(urbanIdx);
weekendUrban = weekendMidpoints(urbanIdx);
weekdayRural = weekdayMidpoints(ruralIdx);
weekendRural = weekendMidpoints(ruralIdx);

% Debug: Print first few extracted values
disp("Urban Weekday Midpoints:");
disp(weekdayUrban(1:min(5,end)));

disp("Urban Weekend Midpoints:");
disp(weekendUrban(1:min(5,end)));

disp("Rural Weekday Midpoints:");
disp(weekdayRural(1:min(5,end)));

disp("Rural Weekend Midpoints:");
disp(weekendRural(1:min(5,end)));

% Remove NaN values from each subset
validUrban = ~isnan(weekdayUrban) & ~isnan(weekendUrban);
validRural = ~isnan(weekdayRural) & ~isnan(weekendRural);

weekdayUrban = weekdayUrban(validUrban);
weekendUrban = weekendUrban(validUrban);
weekdayRural = weekdayRural(validRural);
weekendRural = weekendRural(validRural);

% Debug: Check valid data counts
fprintf("Valid Urban Data Points After Filtering: %d\n", length(weekdayUrban));
fprintf("Valid Rural Data Points After Filtering: %d\n", length(weekdayRural));

% Calculate Means and SEMs
meanWeekdayUrban = mean(weekdayUrban);
meanWeekendUrban = mean(weekendUrban);
semWeekdayUrban = std(weekdayUrban) / sqrt(length(weekdayUrban));
semWeekendUrban = std(weekendUrban) / sqrt(length(weekendUrban));

meanWeekdayRural = mean(weekdayRural);
meanWeekendRural = mean(weekendRural);
semWeekdayRural = std(weekdayRural) / sqrt(length(weekdayRural));
semWeekendRural = std(weekendRural) / sqrt(length(weekendRural));

% Perform Paired t-test for Urban
[hUrban, pUrban, ciUrban, statsUrban] = ttest(weekdayUrban, weekendUrban);

% Perform Paired t-test for Rural
[hRural, pRural, ciRural, statsRural] = ttest(weekdayRural, weekendRural);

% Function to Convert Decimal Hours to HH:MM:SS Format
convertToTimestamp = @(decimalHours) sprintf('%02d:%02d:%02d', ...
    floor(decimalHours), ...                   % Hours
    floor(mod(decimalHours * 60, 60)), ...     % Minutes
    round(mod(decimalHours * 3600, 60)));      % Seconds

% Convert Means and SEMs Back to Timestamp Format
meanWeekdayUrban_str = convertToTimestamp(meanWeekdayUrban);
meanWeekendUrban_str = convertToTimestamp(meanWeekendUrban);
semWeekdayUrban_str = convertToTimestamp(semWeekdayUrban);
semWeekendUrban_str = convertToTimestamp(semWeekendUrban);

meanWeekdayRural_str = convertToTimestamp(meanWeekdayRural);
meanWeekendRural_str = convertToTimestamp(meanWeekendRural);
semWeekdayRural_str = convertToTimestamp(semWeekdayRural);
semWeekendRural_str = convertToTimestamp(semWeekendRural);

% Display Results for Urban Population
fprintf('\n*** Urban Population ***\n');
fprintf('Mean Weekday Sleep Midpoint: %s ± %s\n', meanWeekdayUrban_str, semWeekdayUrban_str);
fprintf('Mean Weekend Sleep Midpoint: %s ± %s\n', meanWeekendUrban_str, semWeekendUrban_str);
fprintf('t-Statistic: %.4f\n', statsUrban.tstat);
fprintf('p-Value: %.4f\n', pUrban);
fprintf('Confidence Interval: [%s, %s]\n', ...
    convertToTimestamp(ciUrban(1)), convertToTimestamp(ciUrban(2)));

if pUrban < 0.05
    fprintf('Significant difference detected between weekday and weekend sleep midpoints for Urban population (p < 0.05).\n');
else
    fprintf('No significant difference detected for Urban population.\n');
end

% Display Results for Rural Population
fprintf('\n*** Rural Population ***\n');
fprintf('Mean Weekday Sleep Midpoint: %s ± %s\n', meanWeekdayRural_str, semWeekdayRural_str);
fprintf('Mean Weekend Sleep Midpoint: %s ± %s\n', meanWeekendRural_str, semWeekendRural_str);
fprintf('t-Statistic: %.4f\n', statsRural.tstat);
fprintf('p-Value: %.4f\n', pRural);
fprintf('Confidence Interval: [%s, %s]\n', ...
    convertToTimestamp(ciRural(1)), convertToTimestamp(ciRural(2)));

if pRural < 0.05
    fprintf('Significant difference detected between weekday and weekend sleep midpoints for Rural population (p < 0.05).\n');
else
    fprintf('No significant difference detected for Rural population.\n');
end