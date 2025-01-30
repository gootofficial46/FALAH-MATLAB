% MATLAB Script: Sleep Midpoint T-Test for Boarding Groups
% Reads an Excel file, re-averages onset/offset times, groups participants by boarding status,
% correctly shifts sleep midpoints to nighttime range, and performs t-tests.

% Load the data
filePath = 'Averaged_Sleep_Data.xlsx';
data = readtable(filePath, 'TextType', 'string'); % Read text to avoid formatting issues

% Ensure necessary columns exist
requiredColumns = {'participantID', 'boardingStatus', 'avg_weekend_sleeponset', 'avg_weekend_wakeup', ...
                   'avg_weekend_sleepDuration', 'avg_weekend_sleepMidpoint', 'avg_weekday_sleeponset', 'avg_weekday_wakeup',...
                   'avg_weekday_sleepDuration', 'avg_weekday_sleepMidpoint', 'rural_urban'};
if ~all(ismember(requiredColumns, data.Properties.VariableNames))
    error('The required columns are missing from the dataset.');
end

% Convert time strings to numeric decimal hours (HH:MM:SS → Hours)
timeColumns = {'avg_weekday_sleeponset', 'avg_weekday_wakeup', 'avg_weekday_sleepMidpoint', ...
               'avg_weekend_sleeponset', 'avg_weekend_wakeup', 'avg_weekend_sleepMidpoint'};

for i = 1:length(timeColumns)
    data.(timeColumns{i}) = hours(duration(data.(timeColumns{i}))); % Convert to decimal hours
end

% Group participants by boarding status
internalIdx = strcmp(data.boardingStatus, "Internal");
halfBoarderIdx = strcmp(data.boardingStatus, "Half border");
externalIdx = strcmp(data.boardingStatus, "External");

% Extract sleep midpoints for each group (Weekday vs. Weekend)
internalWeekday = data.avg_weekday_sleepMidpoint(internalIdx);
internalWeekend = data.avg_weekend_sleepMidpoint(internalIdx);

halfBoarderWeekday = data.avg_weekday_sleepMidpoint(halfBoarderIdx);
halfBoarderWeekend = data.avg_weekend_sleepMidpoint(halfBoarderIdx);

externalWeekday = data.avg_weekday_sleepMidpoint(externalIdx);
externalWeekend = data.avg_weekend_sleepMidpoint(externalIdx);

% Remove NaN values for each group
internalValid = ~isnan(internalWeekday) & ~isnan(internalWeekend);
internalWeekday = internalWeekday(internalValid);
internalWeekend = internalWeekend(internalValid);

halfBoarderValid = ~isnan(halfBoarderWeekday) & ~isnan(halfBoarderWeekend);
halfBoarderWeekday = halfBoarderWeekday(halfBoarderValid);
halfBoarderWeekend = halfBoarderWeekend(halfBoarderValid);

externalValid = ~isnan(externalWeekday) & ~isnan(externalWeekend);
externalWeekday = externalWeekday(externalValid);
externalWeekend = externalWeekend(externalValid);

% Display the number of participants in each group
fprintf('Number of Internal participants: %d\n', numel(internalWeekday));
fprintf('Number of Half Boarder participants: %d\n', numel(halfBoarderWeekday));
fprintf('Number of External participants: %d\n', numel(externalWeekday));

% Perform t-tests and compute mean ± SEM for each group
perform_analysis('Internal', internalWeekday, internalWeekend);
perform_analysis('Half Boarder', halfBoarderWeekday, halfBoarderWeekend);
perform_analysis('External', externalWeekday, externalWeekend);

% Function to perform analysis (mean, SEM, realign times correctly, and t-test)
function perform_analysis(groupName, weekday, weekend)
    if numel(weekday) > 1 && numel(weekend) > 1
        % Correctly shift all sleep midpoints into the proper range (~22:00 - 06:00)
        weekday = shift_sleep_midpoint(weekday);
        weekend = shift_sleep_midpoint(weekend);

        % Compute Mean and SEM in decimal hours
        meanWeekday = mean(weekday);
        semWeekday = std(weekday) / sqrt(numel(weekday));
        
        meanWeekend = mean(weekend);
        semWeekend = std(weekend) / sqrt(numel(weekend));

        % Convert decimal hours back to HH:MM format
        [hhW, mmW] = decimal_to_hhmm(meanWeekday);
        [hhW_SEM, mmW_SEM] = decimal_to_hhmm(semWeekday);
        
        [hhWE, mmWE] = decimal_to_hhmm(meanWeekend);
        [hhWE_SEM, mmWE_SEM] = decimal_to_hhmm(semWeekend);

        % Display Mean ± SEM in HH:MM format
        fprintf('\n%s Group:\n', groupName);
        fprintf('Weekday Midpoint: %02d:%02d ± %02d:%02d (HH:MM)\n', hhW, mmW, hhW_SEM, mmW_SEM);
        fprintf('Weekend Midpoint: %02d:%02d ± %02d:%02d (HH:MM)\n', hhWE, mmWE, hhWE_SEM, mmWE_SEM);
        
        % Perform t-test
        [~, p, ~, stats] = ttest(weekday, weekend);
        fprintf('Paired t-test results (Weekday vs. Weekend Sleep Midpoint):\n');
        fprintf('t-statistic: %.4f\n', stats.tstat);
        fprintf('p-value: %.4f\n', p);
        
        % Interpretation
        if p < 0.05
            fprintf('Result: Significant difference in sleep midpoint between weekdays and weekends (p < 0.05).\n');
        else
            fprintf('Result: No significant difference in sleep midpoint between weekdays and weekends (p >= 0.05).\n');
        end
    else
        fprintf('\nError: Not enough valid data points for the %s group t-test.\n', groupName);
    end
end

% Function to shift sleep midpoints into expected nighttime range (22:00 - 06:00)
function adjusted = shift_sleep_midpoint(midpoints)
    adjusted = midpoints;
    for i = 1:length(midpoints)
        if midpoints(i) > 12  % If it's after noon, it's incorrectly shifted—adjust it back
            adjusted(i) = midpoints(i) - 12;
        elseif midpoints(i) < 18 && midpoints(i) > 12  % If it's between 12:00 - 18:00, shift it back to nighttime
            adjusted(i) = midpoints(i) - 12;
        end
    end
end

% Function to convert decimal hours to HH:MM format
function [hh, mm] = decimal_to_hhmm(decimalHours)
    hh = mod(floor(decimalHours), 24); % Ensure hours wrap correctly
    mm = round((decimalHours - floor(decimalHours)) * 60);
end