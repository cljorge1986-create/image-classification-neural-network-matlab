function [pathFolder, numberFolders] = listingFolders(root)

    rootFolder = fullfile(root);
    
    listing = dir(rootFolder);

    numberFolders=length(listing);

    for i=3: numberFolders
        folderName{i-2}=listing(i).name;
    end
    
    pathFolder=folderName;
    
end