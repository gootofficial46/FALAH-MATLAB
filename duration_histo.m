%% plotSleepHistograms.m
% This script reads sleep duration data from an Excel file and plots overlayed
% histograms for weekday and weekend sleep durations. In addition, it computes a
% smooth rolling average (using a moving average filter) of the histogram counts
% and overlays these smooth lines on the histograms.
%
% Assumptions:
%   - The Excel file 'sleep_data.xlsx' contains at least two columns:
%       Column 1: Weekday sleep duration (in decimal hours)
%       Column 2: Weekend sleep duration (in decimal hours)

clear; clc;

%% Read Data from Excel
filename = 'Averaged_Sleep_Data.xlsx';  % Adjust the filename/path if needed
data = readtable(filename);

% Extract weekday and weekend durations.
% (Adjust the column indices if your file differs.)
weekdayDuration = data{:,9};
weekendDuration = data{:,5};

% Remove any NaN values.
weekdayDuration = weekdayDuration(~isnan(weekdayDuration));
weekendDuration = weekendDuration(~isnan(weekendDuration));

%% Determine Common Histogram Bins
% To overlay the histograms, use common bin edges.
allData = [weekdayDuration; weekendDuration];
numBins = 20;  % Adjust as needed
binEdges = linspace(min(allData), max(allData), numBins+1);
binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

%% Create the Histogram Plot
figure;
hold on;

% Plot the weekday histogram.
hWeekday = histogram(weekdayDuration, binEdges, ...
    'FaceColor', 'blue', 'FaceAlpha', 0.5, 'EdgeColor', 'none');

% Plot the weekend histogram.
hWeekend = histogram(weekendDuration, binEdges, ...
    'FaceColor', 'red', 'FaceAlpha', 0.5, 'EdgeColor', 'none');

%% Compute and Plot Smooth Rolling Average Lines
% Extract the histogram counts from the histogram objects.
countsWeekday = hWeekday.Values;
countsWeekend = hWeekend.Values;

% Specify a window size for the rolling (moving) average.
windowSize = 3;  % Adjust as desired

% Compute the moving average (smooth data) of the counts.
smoothWeekday = smoothdata(countsWeekday, 'movmean', windowSize);
smoothWeekend = smoothdata(countsWeekend, 'movmean', windowSize);

% Overlay the smooth rolling average lines.
plot(binCenters, smoothWeekday, 'b-', 'LineWidth', 2);
plot(binCenters, smoothWeekend, 'r-', 'LineWidth', 2);

%% Formatting the Plot
xlabel('Sleep Duration (hours)');
ylabel('Count');
title('Overlayed Histogram of Sleep Durations with Smooth Rolling Average');
legend('Weekday', 'Weekend', 'Weekday Rolling Avg', 'Weekend Rolling Avg', ...
    'Location', 'best');
grid on;
hold off;