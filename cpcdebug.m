% Read the table
data = readtable('Prelim_Results_ID_Boarding.xlsx');

% Display variable types
varTypes = varfun(@class, data, 'OutputFormat', 'cell');
disp(table(data.Properties.VariableNames', varTypes', 'VariableNames', {'ColumnName', 'DataType'}));