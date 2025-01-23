% MATLAB Script: match_keywords_to_ids.m
% This script matches IDs and their corresponding statuses from a CSV file 
% to an Excel file, considering multiple keywords across all columns.

% Clear workspace and command window
clear;
clc;

% Prompt user to select the first CSV file
[file1, path1] = uigetfile('*.csv', 'Select the first CSV file (with IDs and statuses)');
if isequal(file1, 0)
    disp('No file selected. Exiting...');
    return;
end
file1Path = fullfile(path1, file1);

% Prompt user to select the second Excel file
[file2, path2] = uigetfile('*.xlsx', 'Select the second Excel file (with IDs)');
if isequal(file2, 0)
    disp('No file selected. Exiting...');
    return;
end
file2Path = fullfile(path2, file2);

% Read data from the CSV and Excel files
file1Data = readtable(file1Path, 'ReadVariableNames', false);
file2Data = readtable(file2Path);

% Define the keywords to search for
keywords = {'Internal', 'Half border', 'External'};

% Extract relevant data from the first file
% Assume the first row is not data and that IDs are in the 2nd column
ids = file1Data{2:end, 2};  % IDs are assumed to be in the 2nd column
statuses = strings(size(ids));  % Initialize statuses as empty strings

% Search for keywords in all columns and assign statuses
for i = 2:height(file1Data)  % Start from the second row
    for j = 1:width(file1Data)  % Search all columns
        cellValue = string(file1Data{i, j});
        if any(contains(cellValue, keywords))
            statuses(i-1) = cellValue;  % Assign the matching status
            break;  % Stop searching once a status is found for the row
        end
    end
end

% Create a table with IDs and statuses from the first file
extractedData = table(ids, statuses, 'VariableNames', {'ID', 'BoardingStatus'});

% Ensure IDs in both files are strings for proper merging
file2Data.ID = string(file2Data.ID);
extractedData.ID = string(extractedData.ID);

% Match the statuses to the second file using IDs
updatedData = outerjoin(file2Data, extractedData, 'Keys', 'ID', 'MergeKeys', true);

% Save the updated data to a new Excel file
outputFile = fullfile(path2, 'Updated_Results_With_Statuses.xlsx');
writetable(updatedData, outputFile);
disp(['The updated file has been saved to: ', outputFile]);