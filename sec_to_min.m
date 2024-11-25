% MATLAB Script to Convert CSV Files from 1 Row per Second to 1 Row per Minute

% Prompt the user to select the input folder containing .csv files
inputFolder = uigetdir('', 'Select the folder containing .csv files');
if inputFolder == 0
    disp('Input folder selection canceled.');
    return;
end

% Prompt the user to select the output folder for saving processed files
outputFolder = uigetdir('', 'Select the folder to save processed .csv files');
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

    % Check if there is a 'timestamp' column
    if ~ismember('timestamp', dataTable.Properties.VariableNames)
        warning('File %s does not contain a ''timestamp'' column. Skipping...', csvFiles(k).name);
        continue;
    end

    % Convert timestamp to datetime format
    try
        dataTable.timestamp = datetime(dataTable.timestamp, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    catch
        warning('Could not parse timestamps in file: %s. Skipping...', csvFiles(k).name);
        continue;
    end

    % Add a new column for minute-level grouping
    dataTable.MinuteGroup = dateshift(dataTable.timestamp, 'start', 'minute');

    % Identify numeric variables only
    numericVars = varfun(@isnumeric, dataTable, 'OutputFormat', 'uniform');
    numericVarNames = dataTable.Properties.VariableNames(numericVars);

    % Group the data by minute and calculate the mean for numeric columns
    groupedData = varfun(@mean, dataTable, ...
        'GroupingVariables', 'MinuteGroup', ...
        'InputVariables', numericVarNames);

    % Rename 'MinuteGroup' back to 'timestamp'
    groupedData.Properties.VariableNames{'MinuteGroup'} = 'timestamp';

    % Write the processed data to a new CSV file
    outputFileName = fullfile(outputFolder, csvFiles(k).name);
    writetable(groupedData, outputFileName);

    % Display a message for each processed file
    disp(['Processed and saved: ', csvFiles(k).name]);
end

% Display completion message
disp('All files have been processed successfully.');