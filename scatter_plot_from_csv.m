% MATLAB Script to Process All .csv Files in a Folder and Save Scatter Plots

% Prompt the user to select the input folder containing .csv files
inputFolder = uigetdir('', 'Select the folder containing .csv files');
if inputFolder == 0
    disp('Input folder selection canceled.');
    return;
end

% Prompt the user to select the output folder for saving scatter plots
outputFolder = uigetdir('', 'Select the folder to save scatter plots');
if outputFolder == 0
    disp('Output folder selection canceled.');
    return;
end

% Get all .csv files in the input folder
csvFiles = dir(fullfile(inputFolder, '*.csv'));

% Check if there are .csv files in the folder
if isempty(csvFiles)
    error('No .csv files found in the selected folder.');
end

% Loop through each .csv file
for k = 1:length(csvFiles)
    % Get the full file path of the current .csv file
    inputFile = fullfile(inputFolder, csvFiles(k).name);
    
    % Read the data from the CSV file
    try
        dataTable = readtable(inputFile);
    catch
        warning('Could not read file: %s. Skipping...', csvFiles(k).name);
        continue;
    end

    % Check if required columns exist
    if ~ismember('timestamp', dataTable.Properties.VariableNames) || ...
       ~ismember('mean_svmgsum', dataTable.Properties.VariableNames)
        warning('File %s does not contain required columns. Skipping...', csvFiles(k).name);
        continue;
    end

    % Extract x and y data
    xData = dataTable.timestamp;
    yData = dataTable.mean_svmgsum;

    % Create scatter plot
    figure('Visible', 'off'); % Create an invisible figure
    scatter(xData, yData, 'filled');
    title(['Scatter Plot: ', csvFiles(k).name], 'Interpreter', 'none');
    xlabel('timestamp');
    ylabel('activity');
    grid on;

    % Save the scatter plot to the output folder
    outputFileName = fullfile(outputFolder, [csvFiles(k).name, '.png']);
    saveas(gcf, outputFileName);
    close(gcf); % Close the figure to free memory
end

% Display completion message
disp('Scatter plots created and saved successfully.');