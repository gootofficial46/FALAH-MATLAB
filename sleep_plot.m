% Script to analyze actigraphy data and categorize activity levels

% Prompt user to load actigraphy data
[fileName, pathName] = uigetfile('*.csv', 'Select the Actigraphy Data File');
if isequal(fileName, 0)
    disp('No file selected. Exiting...');
    return;
end

% Load the data
filePath = fullfile(pathName, fileName);
data = readtable(filePath);

% Assume the data has columns: 'Timestamp' and 'ActivityCount'
time = datetime(data.timestamp, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
activity = data.mean_svmgsum;

% Define thresholds for activity levels (adjust as needed)
thresholdSleep = 3;     % Below this value is considered sleep
thresholdInactivity = 10; % Between sleep and low activity
thresholdLowActivity = 50; % Between low and high activity
thresholdHighActivity = Inf; % Above this is high activity

% Categorize activity levels
activityLevel = zeros(size(activity)); % Initialize activity levels
activityLevel(activity <= thresholdSleep) = 1; % Sleep
activityLevel(activity > thresholdSleep & activity <= thresholdInactivity) = 2; % Inactivity
activityLevel(activity > thresholdInactivity & activity <= thresholdLowActivity) = 3; % Low activity
activityLevel(activity > thresholdLowActivity) = 4; % High activity

% Plot the data
figure;
hold on;

% Define colors for different activity levels
colors = [0, 0, 1; % Blue for sleep
          0, 1, 0; % Green for inactivity
          1, 1, 0; % Yellow for low activity
          1, 0, 0]; % Red for high activity

for i = 1:4
    % Plot each activity level
    idx = (activityLevel == i);
    plot(time(idx), activity(idx), '.', 'Color', colors(i, :));
end

% Customize the plot
legend('Sleep', 'Inactivity', 'Low Activity', 'High Activity');
xlabel('Time');
ylabel('Activity Count');
title('Actigraphy Data with Activity Levels');
grid on;
hold off;