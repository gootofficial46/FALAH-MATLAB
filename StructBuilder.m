% MATLAB script to convert an Excel file into a struct and enable querying by ID

% Load the Excel file
fileName = 'Prelim_Results_ID.xlsx'; % Replace with your Excel file name
data = readtable(fileName);

% Convert the table into an array of structs, indexed by ID
uniqueIDs = unique(data.ID); % Get unique IDs
structData = struct(); % Initialize the struct

for i = 1:height(data)
    % Convert the current row to a struct and store it in structData using the ID
    currentRowStruct = table2struct(data(i, :));
    structData.(sprintf('ID_%d', data.ID(i))) = currentRowStruct;
end

% Function to query the struct by ID
function printDataByID(structData, queryID)
    fieldName = sprintf('ID_%d', queryID); % Format the ID field name
    if isfield(structData, fieldName)
        disp(structData.(fieldName)); % Display the data for the queried ID
    else
        fprintf('No data found for ID: %d\n', queryID);
    end
end

% Example usage
queryID = 20200005; % Replace with your desired ID
printDataByID(structData, queryID);
