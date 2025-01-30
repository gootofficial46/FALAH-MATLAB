% Load Data
data = readtable('Averaged_Sleep_Data.xlsx'); % Ensure correct filename

% Ensure required columns exist
if ~all(ismember({'avg_weekday_sleepMidpoint', 'avg_weekend_sleepMidpoint'}, data.Properties.VariableNames))
    error('Required columns not found. Ensure the dataset has "avg_weekday_sleepMidpoint" and "avg_weekend_sleepMidpoint".');
end

% Convert timestamps stored as cell arrays to decimal hours
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

% Remove NaN values
validIdx = ~isnan(weekdayMidpoints) & ~isnan(weekendMidpoints);
weekdayMidpoints = weekdayMidpoints(validIdx);
weekendMidpoints = weekendMidpoints(validIdx);

% Calculate Means and SEMs
meanWeekday = mean(weekdayMidpoints);
meanWeekend = mean(weekendMidpoints);
semWeekday = std(weekdayMidpoints) / sqrt(length(weekdayMidpoints));
semWeekend = std(weekendMidpoints) / sqrt(length(weekendMidpoints));

% Perform Paired t-test
[h, p, ci, stats] = ttest(weekdayMidpoints, weekendMidpoints);

% Function to Convert Decimal Hours to HH:MM:SS Format
convertToTimestamp = @(decimalHours) sprintf('%02d:%02d:%02d', ...
    floor(decimalHours), ...                   % Hours
    floor(mod(decimalHours * 60, 60)), ...     % Minutes
    round(mod(decimalHours * 3600, 60)));      % Seconds

% Convert Means and SEMs Back to Timestamp Format
meanWeekday_str = convertToTimestamp(meanWeekday);
meanWeekend_str = convertToTimestamp(meanWeekend);
semWeekday_str = convertToTimestamp(semWeekday);
semWeekend_str = convertToTimestamp(semWeekend);

% Convert Confidence Intervals to HH:MM:SS
ci_str = [convertToTimestamp(ci(1)), convertToTimestamp(ci(2))];

% Display Results
fprintf('\n*** Whole Population ***\n');
fprintf('Mean Weekday Sleep Midpoint: %s ± %s\n', meanWeekday_str, semWeekday_str);
fprintf('Mean Weekend Sleep Midpoint: %s ± %s\n', meanWeekend_str, semWeekend_str);
fprintf('t-Statistic: %.4f\n', stats.tstat);
fprintf('p-Value: %.4f\n', p);
fprintf('Confidence Interval: [%s, %s]\n', ci_str(1), ci_str(2));

% Interpretation
if p < 0.05
    fprintf('Significant difference detected between weekday and weekend sleep midpoints (p < 0.05).\n');
else
    fprintf('No significant difference detected.\n');
end