function [net,imageSize,classifier,accurate, Imgstreinadasporpasta, ...
mConfusion, mConfusionp, centroid, classes]=loadConfig(filename)
    % Create a table with the data and variable names
    vars = load(strcat(filename,'.mat'));
    
    net=vars.T.Value{1,1};
    imageSize=vars.T.Value{2,1};
    classifier=vars.T.Value{3,1};
    accurate=vars.T.Value{4,1};
    Imgstreinadasporpasta=vars.T.Value{5,1}; 
    mConfusion=vars.T.Value{6,1}; 
    mConfusionp=vars.T.Value{7,1};
    centroid=vars.T.Value{8,1};
    classes=vars.T.Value{9,1};
end
