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

% Ensure rural_urban column is categorical
data.rural_urban = categorical(data.rural_urban);
data.rural_urban = strtrim(lower(string(data.rural_urban))); % Convert and standardize

% Extract indexes for urban and rural groups
urbanIdx = find(data.rural_urban == "urban");
ruralIdx = find(data.rural_urban == "rural");

% Extract Sleep Midpoints
weekdayUrban = weekdayMidpoints(urbanIdx);
weekendUrban = weekendMidpoints(urbanIdx);
weekdayRural = weekdayMidpoints(ruralIdx);
weekendRural = weekendMidpoints(ruralIdx);

% Remove NaN values
validUrban = ~isnan(weekdayUrban) & ~isnan(weekendUrban);
validRural = ~isnan(weekdayRural) & ~isnan(weekendRural);

weekdayUrban = weekdayUrban(validUrban);
weekendUrban = weekendUrban(validUrban);
weekdayRural = weekdayRural(validRural);
weekendRural = weekendRural(validRural);

% Calculate Means and SEMs
meanWeekdayUrban = mean(weekdayUrban);
meanWeekendUrban = mean(weekendUrban);
semWeekdayUrban = std(weekdayUrban) / sqrt(length(weekdayUrban));
semWeekendUrban = std(weekendUrban) / sqrt(length(weekendUrban));

meanWeekdayRural = mean(weekdayRural);
meanWeekendRural = mean(weekendRural);
semWeekdayRural = std(weekdayRural) / sqrt(length(weekdayRural));
semWeekendRural = std(weekendRural) / sqrt(length(weekendRural));

% Perform Paired t-test
[hUrban, pUrban, ciUrban, statsUrban] = ttest(weekdayUrban, weekendUrban);
[hRural, pRural, ciRural, statsRural] = ttest(weekdayRural, weekendRural);

% Calculate Degrees of Freedom
dfUrban = length(weekdayUrban) - 1;
dfRural = length(weekdayRural) - 1;

% Function to Convert Decimal Hours to HH:MM:SS Format
convertToTimestamp = @(decimalHours) sprintf('%02d:%02d:%02d', ...
    floor(decimalHours), ...                   
    floor(mod(decimalHours * 60, 60)), ...     
    round(mod(decimalHours * 3600, 60)));      

% Convert Means and SEMs to String Format
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
fprintf('Degrees of Freedom: %d\n', dfUrban);
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
fprintf('Degrees of Freedom: %d\n', dfRural);
fprintf('p-Value: %.4f\n', pRural);
fprintf('Confidence Interval: [%s, %s]\n', ...
    convertToTimestamp(ciRural(1)), convertToTimestamp(ciRural(2)));

if pRural < 0.05
    fprintf('Significant difference detected between weekday and weekend sleep midpoints for Rural population (p < 0.05).\n');
else
    fprintf('No significant difference detected for Rural population.\n');
end