% MATLAB Script to generate overlaid histograms for 'avg_weekend_sleepMidpoint' and 'avg_weekday_sleepMidpoint'
% with a smooth rolling average line

% Read data from the Excel file
filename = 'Averaged_Sleep_Data.xlsx';
data = readtable(filename);

% Detect if data is stored as serial dates or text timestamps
if isnumeric(data.avg_weekend_sleepMidpoint)
    weekend_midpoints = timeofday(datetime(data.avg_weekend_sleepMidpoint, 'ConvertFrom', 'excel'));
else
    weekend_midpoints = timeofday(datetime(data.avg_weekend_sleepMidpoint, 'InputFormat', 'HH:mm:ss'));
end

if isnumeric(data.avg_weekday_sleepMidpoint)
    weekday_midpoints = timeofday(datetime(data.avg_weekday_sleepMidpoint, 'ConvertFrom', 'excel'));
else
    weekday_midpoints = timeofday(datetime(data.avg_weekday_sleepMidpoint, 'InputFormat', 'HH:mm:ss'));
end

% Remove NaN values resulting from conversion errors
weekend_midpoints = weekend_midpoints(~isnan(weekend_midpoints));
weekday_midpoints = weekday_midpoints(~isnan(weekday_midpoints));

% Define bin edges for consistency
binEdges = min([weekend_midpoints; weekday_midpoints]):minutes(30):max([weekend_midpoints; weekday_midpoints]);

% Compute histogram counts
[counts_weekend, edges] = histcounts(weekend_midpoints, binEdges);
[counts_weekday, ~] = histcounts(weekday_midpoints, binEdges);

% Compute bin centers
binCenters = edges(1:end-1) + diff(edges)/2;

% Plot overlaid histograms
figure;
hold on;
histogram(weekend_midpoints, binEdges, 'FaceColor', 'b', 'FaceAlpha', 0.5);
histogram(weekday_midpoints, binEdges, 'FaceColor', 'r', 'FaceAlpha', 0.5);

% Compute rolling average (moving mean)
windowSize = 5; % Adjust as needed
rolling_avg_weekend = movmean(counts_weekend, windowSize);
rolling_avg_weekday = movmean(counts_weekday, windowSize);

% Plot rolling average lines
plot(binCenters, rolling_avg_weekend, '-b', 'LineWidth', 2);
plot(binCenters, rolling_avg_weekday, '-r', 'LineWidth', 2);

xlabel('Sleep Midpoint (Time of Day)');
ylabel('Frequency');
title('Overlaid Histogram of Sleep Midpoints with Rolling Average');
legend({'Weekend Data', 'Weekday Data', 'Weekend Rolling Avg', 'Weekday Rolling Avg'});
grid on;
hold off;
