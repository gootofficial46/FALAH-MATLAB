% Adjusted Sleep Detection with Transition Smoothing and Gap-Filling

% Parameters
windowSize = 60; % Rolling window size in minutes for smoothing
dailyNightPercentile = 25; % Nighttime activity threshold (25th percentile per day)
minContinuousSleep = 20; % Minimum continuous low activity (minutes)
minSleepDuration = 45; % Minimum sleep duration in minutes
mergeGap = 90; % Minutes to merge short breaks in sleep periods
nightStartHour = 20; % Sleep opportunity window starts at 8 PM
nightEndHour = 8; % Sleep opportunity window ends at 8 AM
gapFillingThreshold = 35; % Activity threshold for gap filling (percentile of nighttime activity)

% Allow user to select multiple files
[fileNames, pathName] = uigetfile('*.csv', 'Select Actigraphy Data Files', 'MultiSelect', 'on');

if isequal(fileNames, 0)
    disp('No files selected. Exiting...');
    return;
end

% Handle a single file or multiple files
if ischar(fileNames)
    fileNames = {fileNames};
end

% Loop through each file
for fIdx = 1:length(fileNames)
    % Load the data
    filePath = fullfile(pathName, fileNames{fIdx});
    data = readtable(filePath);
    
    % Display file being processed
    fprintf('Processing file: %s\n', fileNames{fIdx});
    
    % Check for timestamp and activity columns dynamically
    timeCol = find(contains(data.Properties.VariableNames, 'time', 'IgnoreCase', true), 1);
    activityCol = find(contains(data.Properties.VariableNames, 'svmgsum', 'IgnoreCase', true), 1);

    if isempty(timeCol) || isempty(activityCol)
        fprintf('Required columns not found in file %s. Skipping...\n', fileNames{fIdx});
        continue;
    end

    % Extract data
    time = datetime(data{:, timeCol}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    activity = data{:, activityCol};

    % Smooth activity using a rolling median
    smoothedActivity = movmedian(activity, windowSize);

    % Separate data by day
    uniqueDates = unique(dateshift(time, 'start', 'day'));
    isSleep = false(size(activity)); % Initialize sleep detection

    % Process each day separately
    for d = 1:length(uniqueDates)
        % Filter for the current day
        dayMask = (time >= uniqueDates(d)) & (time < uniqueDates(d) + days(1));
        dayTime = time(dayMask);
        dayActivity = smoothedActivity(dayMask);

        % Identify nighttime periods
        nightMask = (hour(dayTime) >= nightStartHour) | (hour(dayTime) < nightEndHour);
        nightActivity = dayActivity(nightMask);
        nightTime = dayTime(nightMask);

        if isempty(nightActivity)
            continue; % Skip if no nighttime data available
        end

        % Calculate dynamic threshold for the current day
        nightThreshold = prctile(nightActivity, dailyNightPercentile);

        % Detect low activity periods for the night
        lowActivity = nightActivity < nightThreshold;

        % Cumulative sleep detection
        cumulativeSleep = 0; % Reset cumulative counter
        detectedSleep = false(size(nightActivity)); % Initialize sleep mask for the night
        for i = 1:length(lowActivity)
            if lowActivity(i)
                cumulativeSleep = cumulativeSleep + 1;
            else
                cumulativeSleep = 0; % Reset if not low activity
            end

            if cumulativeSleep >= minContinuousSleep
                detectedSleep(i - cumulativeSleep + 1:i) = true;
            end
        end

        % Gap-filling: Fill gaps between detected sleep periods
        sleepStartIdx = find(diff([0; detectedSleep]) == 1);
        sleepEndIdx = find(diff([detectedSleep; 0]) == -1);

        for i = 1:length(sleepEndIdx)-1
            gapStart = sleepEndIdx(i) + 1;
            gapEnd = sleepStartIdx(i+1) - 1;

            if all(nightActivity(gapStart:gapEnd) < prctile(nightActivity, gapFillingThreshold))
                detectedSleep(gapStart:gapEnd) = true; % Fill the gap
            end
        end

        % Map nighttime detected sleep back to the full day
        fullDaySleep = false(size(dayActivity)); % Initialize mask for the full day
        fullDaySleep(nightMask) = detectedSleep; % Update nighttime sleep in the full day mask
        isSleep(dayMask) = isSleep(dayMask) | fullDaySleep; % Update the global sleep mask
    end

    % Group sleep periods using logical indexing
    sleepStartIdx = find(diff([0; isSleep]) == 1); % Sleep starts
    sleepEndIdx = find(diff([isSleep; 0]) == -1); % Sleep ends

    % Merge short gaps between sleep periods
    for i = length(sleepStartIdx)-1:-1:1
        if minutes(time(sleepStartIdx(i+1)) - time(sleepEndIdx(i))) <= mergeGap
            sleepEndIdx(i) = sleepEndIdx(i+1);
            sleepStartIdx(i+1) = [];
            sleepEndIdx(i+1) = [];
        end
    end

    % Filter out short sleep periods
    validSleepPeriods = (sleepEndIdx - sleepStartIdx) >= (minSleepDuration / windowSize);
    sleepStartIdx = sleepStartIdx(validSleepPeriods);
    sleepEndIdx = sleepEndIdx(validSleepPeriods);

    % Calculate sleep periods and midpoints
    if ~isempty(sleepStartIdx)
        startTimes = time(sleepStartIdx);
        endTimes = time(sleepEndIdx);
        midTimes = startTimes + (endTimes - startTimes) / 2;
    else
        startTimes = [];
        endTimes = [];
        midTimes = [];
    end

    % Plot activity and sleep periods
    figure;
    hold on;
    plot(time, activity, 'b', 'DisplayName', 'Activity Count');
    for i = 1:length(sleepStartIdx)
        % Plot only the sleep period as a shaded region
        fill([startTimes(i), endTimes(i), endTimes(i), startTimes(i)], ...
             [0, 0, max(activity), max(activity)], ...
             'g', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
    xlabel('Time');
    ylabel('Activity Count');
    title(sprintf('Refined Sleep Detection: %s', fileNames{fIdx}));
    legend('Activity Count', 'Sleep Periods');
    grid on;
    hold off;

    % Display sleep periods
    if isempty(startTimes)
        fprintf('No sleep periods detected in file: %s\n', fileNames{fIdx});
    else
        fprintf('Detected Sleep Periods for file: %s\n', fileNames{fIdx});
        sleepTable = table(startTimes, endTimes, midTimes, ...
                           'VariableNames', {'Start', 'End', 'Midpoint'});
        disp(sleepTable);
    end
end