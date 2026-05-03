function saveConfig(filename, varName, varValue)

    % Create a table with the data and variable names
    T = table(varName, varValue, 'VariableNames', { 'Name', 'Value'} );
    % Write data to text file
%     writetable(T, strcat(filename,'.mat'));
    save(filename,'T');
end