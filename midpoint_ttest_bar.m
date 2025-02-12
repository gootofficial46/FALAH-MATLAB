% Load data from Excel
filename = 'Midpoint_tTest.xlsx'; % Adjust filename if necessary
data = readtable(filename);

% Assign correct column names
weekdays_column = data.Properties.VariableNames{2}; % Mean Weekday Midpoint
weekends_column = data.Properties.VariableNames{4}; % Mean Weekend Midpoint
weekday_sem_column = data.Properties.VariableNames{3}; % Weekday SEM
weekend_sem_column = data.Properties.VariableNames{5}; % Weekend SEM

% Extract necessary data
weekdays_hours = data.(weekdays_column); % Mean weekday midpoint (decimal hours)
weekends_hours = data.(weekends_column); % Mean weekend midpoint (decimal hours)
weekdays_sem = data.(weekday_sem_column); % Weekday SEM (decimal hours)
weekends_sem = data.(weekend_sem_column); % Weekend SEM (decimal hours)
group_names = data.Group; % Group names

% Define colors for bars
weekday_color = [218, 168, 162] / 255;  % HEX #DAA8A2 (light red-pink)
weekend_color = [143, 158, 201] / 255;  % HEX #8F9EC9 (light blue-gray)

% Dynamically set y-ticks for HH:MM format
y_min = floor(min([weekdays_hours; weekends_hours]) * 24); % Convert to hours
y_max = ceil(max([weekdays_hours; weekends_hours]) * 24);  % Convert to hours
y_ticks = y_min:(1/4):y_max; % 15-minute intervals
y_labels = arrayfun(@(x) sprintf('%02d:%02d', floor(x), round(mod(x,1)*60)), y_ticks, 'UniformOutput', false);

% Create figure with three panels
figure;

%% 🔹 Panel 1: Whole Population
subplot(1,3,1);
hold on;

whole_population_idx = strcmp(group_names, 'Whole Population');
bar_data = [weekdays_hours(whole_population_idx), weekends_hours(whole_population_idx)];
sem_data = [weekdays_sem(whole_population_idx), weekends_sem(whole_population_idx)];

% Plot bars
bar_handle = bar(1:2, bar_data, 'FaceColor', 'flat');
bar_handle.CData(1, :) = weekday_color;
bar_handle.CData(2, :) = weekend_color;

% Add error bars
errorbar(1:2, bar_data, sem_data, 'k', 'LineStyle', 'none');

% Add significance marker
text(1.5, max(bar_data + sem_data) * 1.01, '*', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Adjust y-axis
ylim([y_min/24 y_max/24]); % Convert back to decimal hours
yticks(y_ticks / 24);      % Convert ticks to decimal hours
yticklabels(y_labels);

set(gca, 'XTick', 1:2, 'XTickLabel', {'Weekday', 'Weekend'});
ylabel('Midpoint (HH:MM)');
title('Whole Population', 'FontSize', 20);
hold off;

%% 🔹 Panel 2: Full-Boarder, Half-Boarder, Day Students
subplot(1,3,2);
hold on;

% Extract data for internal groups
internal_groups = ["Internal", "External", "Half-boarder"];
internal_idx = ismember(group_names, internal_groups);

% Reshape bar_data and sem_data into a 3x2 matrix
bar_data = [weekdays_hours(internal_idx), weekends_hours(internal_idx)];
sem_data = [weekdays_sem(internal_idx), weekends_sem(internal_idx)];

% Plot grouped bars
bar_handle = bar(bar_data, 'grouped');

% Assign consistent colors for weekday and weekend
for i = 1:length(bar_handle)
    if i == 1
        bar_handle(i).FaceColor = weekday_color;
    else
        bar_handle(i).FaceColor = weekend_color;
    end
end

% Add error bars
groupwidth = min(0.8, size(bar_data, 2)/(size(bar_data, 2)+1.5));
for i = 1:size(bar_data, 2)
    x = (1:size(bar_data, 1)) - groupwidth/2 + (2*i-1) * groupwidth / (2*size(bar_data, 2));
    errorbar(x, bar_data(:, i), sem_data(:, i), 'k', 'LineStyle', 'none');
end

% Add significance marker
text(2, max(bar_data(2, :) + sem_data(2, :)) * 1.01, '*', ...
    'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Adjust y-axis
ylim([y_min/24 y_max/24]);
yticks(y_ticks / 24);
yticklabels(y_labels);

% Set x-axis labels
set(gca, 'XTick', 1:3, 'XTickLabel', {'Full-Boarder', 'Half-Boarder', 'Day Student',});
ylabel('Midpoint (HH:MM)');
title('Full-Boarder, Half-Boarder, and Day Students', 'FontSize', 20);
hold off;

%% 🔹 Panel 3: Rural vs. Urban
subplot(1,3,3);
hold on;

rural_urban_groups = ["Rural", "Urban"];
rural_urban_idx = ismember(group_names, rural_urban_groups);
bar_data = [weekdays_hours(rural_urban_idx), weekends_hours(rural_urban_idx)];
sem_data = [weekdays_sem(rural_urban_idx), weekends_sem(rural_urban_idx)];

% Plot grouped bars
bar_handle = bar(bar_data, 'grouped');
for i = 1:length(bar_handle)
    if i == 1
        bar_handle(i).FaceColor = weekday_color;
    else
        bar_handle(i).FaceColor = weekend_color;
    end
end

% Add error bars
for i = 1:size(bar_data, 2)
    x = (1:size(bar_data, 1)) - groupwidth/2 + (2*i-1) * groupwidth / (2*size(bar_data, 2));
    errorbar(x, bar_data(:, i), sem_data(:, i), 'k', 'LineStyle', 'none');
end

% Add significance marker
text(2, max(bar_data(2, :) + sem_data(2, :)) * 1.01, '*', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Add legend
legend({'Weekday', 'Weekend'}, 'Location', 'northeastoutside', 'FontSize', 14);

% Adjust y-axis
ylim([y_min/24 y_max/24]);
yticks(y_ticks / 24);
yticklabels(y_labels);

set(gca, 'XTick', 1:2, 'XTickLabel', {'Rural', 'Urban'});
ylabel('Midpoint (HH:MM)');
title('Rural and Urban', 'FontSize', 20);
hold off;

% Improve layout
set(gcf, 'Position', [100, 100, 1400, 400]);
sgtitle('Mean Sleep Midpoint by Population', 'FontSize', 26);