%% PlotDurationTTestResults.m
% This script reads t-test results from 'Duration_tTest.xlsx' containing 
% timestamp data (Excel serial time) for duration. It converts the timestamps 
% to decimal hours for plotting and then converts the y-axis tick labels back 
% to a timestamp format (HH:MM:SS) for display.
%
% Expected Excel file columns:
%   Column 1: Group title (bar label)
%   Column 2: Mean duration for Condition 1 (Excel serial time)
%   Column 3: Standard error for Condition 1 (Excel serial time)
%   Column 4: Mean duration for Condition 2 (Excel serial time)
%   Column 5: Standard error for Condition 2 (Excel serial time)
%   Column 6: p-value from t-test

clear; close all; clc;

%% --- Specify File ---
filename = 'Duration_tTest.xlsx';

%% --- Read Data from Excel ---
data = readtable(filename);

% Extract data from the table:
labels      = data{:, 1};              % Group titles for the x-axis
means_orig  = [data{:, 2}, data{:, 4}];  % Means for Condition 1 (col2) & Condition 2 (col4)
errors_orig = [data{:, 3}, data{:, 5}];  % Standard errors for Condition 1 (col3) & Condition 2 (col5)
pvals       = data{:, 6};              % p-values (col6)

% Convert timestamps from Excel serial time (fraction of a day) to decimal hours.
% (For minutes, you could multiply by 24*60 instead.)
means_hours  = means_orig  * 24;
errors_hours = errors_orig * 24;

% Determine the number of groups and conditions.
numGroups     = size(means_hours, 1);
numConditions = size(means_hours, 2);

%% --- Create Grouped Bar Chart ---
figure;
b = bar(means_hours);    % Create a grouped bar chart using decimal hours
hold on;

% Add error bars for each condition using the XEndPoints property.
for cond = 1:numConditions
    x = b(cond).XEndPoints;  % Get x-coordinates for the current set of bars
    errorbar(x, means_hours(:, cond), errors_hours(:, cond), 'k', ...
             'linestyle', 'none', 'LineWidth', 1);
end

%% --- Add Significance Markers ---
% Determine a small vertical offset for the asterisk based on current y-axis limits.
yl = ylim;
y_range  = yl(2) - yl(1);
y_offset = 0.02 * y_range;  % 2% of the y-range

% For each group, if the p-value is less than 0.05, add an asterisk above the highest bar.
for group = 1:numGroups
    if pvals(group) < 0.05
        % Compute the x-coordinate as the average of the bar centers for this group.
        x_positions = zeros(1, numConditions);
        for cond = 1:numConditions
            x_positions(cond) = b(cond).XEndPoints(group);
        end
        x_center = mean(x_positions);
        
        % Determine the maximum y-value (bar height plus error) for this group.
        y_max = max(means_hours(group, :) + errors_hours(group, :));
        
        % Place an asterisk just above the highest bar.
        text(x_center, y_max + y_offset, '*', 'HorizontalAlignment', 'center', ...
             'FontSize', 14, 'Color', 'red');
    end
end

%% --- Finalize Plot ---
% Set the x-axis tick positions and labels using the group titles.
set(gca, 'XTick', 1:numGroups, 'XTickLabel', labels);
ylabel('Time');
title('T-Test Duration Results');
legend('Condition 1', 'Condition 2', 'Location', 'Best');

% Convert y-axis tick labels from decimal hours back to timestamp format.
% (Excel times are stored as fractions of a day, so convert hours to days by dividing by 24.)
yt = get(gca, 'YTick');
yTickLabels = arrayfun(@(x) datestr(x/24, 'HH:MM:SS'), yt, 'UniformOutput', false);
set(gca, 'YTickLabel', yTickLabels);

hold off;