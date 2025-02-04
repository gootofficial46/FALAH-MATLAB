%% analyze_sleep.m
% This script reads sleep duration data from an Excel file and performs a series 
% of paired t-tests. The Excel file is assumed to have:
%   Column 1: Weekday sleep duration (numeric)
%   Column 2: Weekend sleep duration (numeric)
%   Column 3: Student type ('external', 'half-border', 'internal')
%   Column 4: Location ('rural', 'urban')

% Clear the workspace and the command window
clear; clc;

%% Read Data from Excel
filename = 'Averaged_Sleep_Data.xlsx';  % Change this to your file name if different
data = readtable(filename);

% Extract the columns
weekdayDuration = data{:,9};   % Column 1: Weekday sleep duration
weekendDuration = data{:,5};   % Column 2: Weekend sleep duration
studentType     = data{:,2};   % Column 3: Student type
location        = data{:,11};   % Column 4: Location

%% 1. Overall Paired t-test: Weekday vs. Weekend Duration for All Students
% Remove pairs with missing values
validOverall = ~(isnan(weekdayDuration) | isnan(weekendDuration));
wdOverall = weekdayDuration(validOverall);
weOverall = weekendDuration(validOverall);

if length(wdOverall) < 2
    fprintf('Overall: Not enough valid data for t-test (only %d valid pair(s)).\n\n', length(wdOverall));
else
    % Calculate mean and SEM for weekday and weekend durations
    meanWeekday = mean(wdOverall);
    semWeekday  = std(wdOverall, 0) / sqrt(length(wdOverall));
    meanWeekend = mean(weOverall);
    semWeekend  = std(weOverall, 0) / sqrt(length(weOverall));
    
    % Convert the mean and SEM values to timestamp format
    weekdayMeanTS = dec2time(meanWeekday);
    weekdaySemTS  = dec2time(semWeekday);
    weekendMeanTS = dec2time(meanWeekend);
    weekendSemTS  = dec2time(semWeekend);
    
    % Perform the paired t-test
    [~, p, ~, stats] = ttest(wdOverall, weOverall);
    
    fprintf('Overall Paired t-test (Weekday vs. Weekend):\n');
    fprintf('  Weekday: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekday, weekdayMeanTS, semWeekday, weekdaySemTS);
    fprintf('  Weekend: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekend, weekendMeanTS, semWeekend, weekendSemTS);
    fprintf('  t(%d) = %.3f, p = %g\n\n', stats.df, stats.tstat, p);
end

%% 2. Paired t-tests by Student Type ('external', 'half-border', 'internal')
uniqueTypes = unique(studentType);
for i = 1:length(uniqueTypes)
    type = uniqueTypes{i};
    idx = strcmp(studentType, type);
    wd = weekdayDuration(idx);
    we = weekendDuration(idx);
    
    % Remove pairs with missing values
    validIdx = ~(isnan(wd) | isnan(we));
    wd = wd(validIdx);
    we = we(validIdx);
    
    if length(wd) < 2
        fprintf('Student Type: %s - Not enough valid data for t-test (only %d valid pair(s)).\n\n', type, length(wd));
    else
        % Calculate mean and SEM for weekday and weekend durations
        meanWeekday = mean(wd);
        semWeekday  = std(wd, 0) / sqrt(length(wd));
        meanWeekend = mean(we);
        semWeekend  = std(we, 0) / sqrt(length(we));
        
        % Convert to timestamp format
        weekdayMeanTS = dec2time(meanWeekday);
        weekdaySemTS  = dec2time(semWeekday);
        weekendMeanTS = dec2time(meanWeekend);
        weekendSemTS  = dec2time(semWeekend);
        
        % Perform the paired t-test
        [~, p, ~, stats] = ttest(wd, we);
        
        fprintf('Paired t-test for Student Type: %s\n', type);
        fprintf('  Weekday: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekday, weekdayMeanTS, semWeekday, weekdaySemTS);
        fprintf('  Weekend: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekend, weekendMeanTS, semWeekend, weekendSemTS);
        fprintf('  t(%d) = %.3f, p = %g\n\n', stats.df, stats.tstat, p);
    end
end

%% 3. Paired t-tests by Location ('rural' and 'urban')
uniqueLocations = unique(location);
for i = 1:length(uniqueLocations)
    loc = uniqueLocations{i};
    idx = strcmp(location, loc);
    wd = weekdayDuration(idx);
    we = weekendDuration(idx);
    
    % Remove pairs with missing values
    validIdx = ~(isnan(wd) | isnan(we));
    wd = wd(validIdx);
    we = we(validIdx);
    
    if length(wd) < 2
        fprintf('Location: %s - Not enough valid data for t-test (only %d valid pair(s)).\n\n', loc, length(wd));
    else
        % Calculate mean and SEM for weekday and weekend durations
        meanWeekday = mean(wd);
        semWeekday  = std(wd, 0) / sqrt(length(wd));
        meanWeekend = mean(we);
        semWeekend  = std(we, 0) / sqrt(length(we));
        
        % Convert to timestamp format
        weekdayMeanTS = dec2time(meanWeekday);
        weekdaySemTS  = dec2time(semWeekday);
        weekendMeanTS = dec2time(meanWeekend);
        weekendSemTS  = dec2time(semWeekend);
        
        % Perform the paired t-test
        [~, p, ~, stats] = ttest(wd, we);
        
        fprintf('Paired t-test for Location: %s\n', loc);
        fprintf('  Weekday: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekday, weekdayMeanTS, semWeekday, weekdaySemTS);
        fprintf('  Weekend: Mean = %.3f (%s), SEM = %.3f (%s)\n', meanWeekend, weekendMeanTS, semWeekend, weekendSemTS);
        fprintf('  t(%d) = %.3f, p = %g\n\n', stats.df, stats.tstat, p);
    end
end

%% Local Function: dec2time
function timeStr = dec2time(decVal)
    % dec2time converts a decimal hour value to a timestamp string in HH:MM format.
    % For example, 8.25 becomes '08:15'
    hours = floor(decVal);
    minutes = round((decVal - hours) * 60);
    % Adjust in case rounding produces 60 minutes
    if minutes == 60
        hours = hours + 1;
        minutes = 0;
    end
    timeStr = sprintf('%02d:%02d', hours, minutes);
end