function folder_path = open_training_folder(folder_name)
% OPEN_TRAINING_FOLDER Opens a dialog for selecting a folder.
%
% DESCRIPTION:
%   This function opens a folder selection dialog window, allowing the user
%   to choose a directory. The selected folder path is returned and can be
%   used by the program as a reference path.
%
% INPUT:
%   folder_name (string/char) - Title of the folder selection dialog.
%
% OUTPUT:
%   folder_path (string) - Full path of the selected folder.
%
% ERRORS:
%   Throws an error if the user cancels the selection or selects an invalid folder.

    % Open folder selection dialog
    selected_path = uigetdir(pwd, folder_name);

    % Check if user cancelled (uigetdir returns 0)
    if isequal(selected_path, 0)
        error('Invalid selection: No valid folder was selected.');
    end

    % Validate if it's actually a folder
    if ~isfolder(selected_path)
        error('Invalid selection: The chosen path is not a valid folder.');
    end

    % Return folder path as string
    folder_path = string(selected_path);

end
