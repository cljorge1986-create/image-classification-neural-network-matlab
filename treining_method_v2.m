function [net, imageSize, predictedLabels, accuracy, minSetCount, ...
    confMat, confMat_norm, centroids, classes] = ...
    treining_method_v2(rootFolders, selectedFolders, choose_cnn)

% TRAINING_METHOD_V2
% Transfer learning using pretrained ResNet-50 with custom classification head
%
% INPUTS:
%   rootFolders      - Root directory path containing datasets
%   selectedFolders  - Cell array / string array of class folder names
%   choose_cnn		 - choose the cnn to use {mobilenetv2, or resnet50, or squeezenet (default)}
%
% OUTPUTS:
%   net              - Pretrained base network
%   imageSize        - Input image size required by network
%   predictedLabels  - Predicted labels for test set
%   accuracy         - Mean classification accuracy
%   minSetCount      - Minimum number of images per class
%   confMat          - Confusion matrix (absolute values)
%   confMat_norm     - Normalized confusion matrix (percentage)

if isempty(selectedFolders)
    error('No categories selected for training.');
end

selectedFolders = string(selectedFolders);

%% Load dataset
imds = imageDatastore(fullfile(rootFolders, selectedFolders), ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames', ...
    'FileExtensions', {'.jpg','.png','.jpeg','.bmp'});

tbl = countEachLabel(imds);
minSetCount = min(tbl.Count);

% Validate dataset integrity
try
    readimage(imds,1);
catch
    error("Dataset contains invalid images");
end

%% Balance dataset across classes
[trainingSet, testSet] = splitEachLabel(imds, minSetCount, 'randomize');
trainLabels = categorical(trainingSet.Labels);
testLabels  = categorical(testSet.Labels);
classes     = categories(trainLabels);
numClasses = numel(classes);
%% -----------------------------
% LOAD PRETRAINED DL NETWORK
% -----------------------------
net = imagePretrainedNetwork(choose_cnn);  % dlnetwork
imageSize = net.Layers(1).InputSize;

%% -----------------------------
% FEATURE EXTRACTOR
% -----------------------------
featureNet = net;
%class(net)

%% -----------------------------
% EXTRACT FEATURES (TRAIN)
% -----------------------------


numTrain = numel(trainingSet.Files);
trainFeatures = [];
%trainLabels = [];
h = waitbar(0,'Training network...');
step = 250;
for i = 1:numTrain
    img = readimage(trainingSet,i);
    img = imresize(img, imageSize(1:2));

    if size(img,3)==1
        img = repmat(img,1,1,3);
    end

    dlImg = dlarray(single(img),'SSC');

    feat = forward(featureNet, dlImg);

    trainFeatures(:,i) = extractdata(feat);
    trainLabels(i,1) = trainingSet.Labels(i);
    
    if mod(i,step) == 0 || i == numTrain
        waitbar(i/numTrain, h, ...
            sprintf('Testing network... %d%% (%d/%d)', ...
            round(100*i/numTrain), i, numTrain));
    end
end

close(h);
%% -----------------------------
% CLASSIFIER (SVM / ECOC)
% -----------------------------
%classifier = fitcecoc(trainFeatures', trainLabels); a toolbox não está
%disponivel
centroids = zeros(size(trainFeatures,1), numClasses);

for c = 1:numClasses
    idx = trainLabels == classes(c);
    centroids(:,c) = mean(trainFeatures(:,idx),2);
end
%% -----------------------------
% TEST FEATURES
% -----------------------------
numTest = numel(testSet.Files);
testFeatures = [];
%testLabels = [];
h = waitbar(0,'Testing network...');
step = 1000;

for i = 1:numTest
    img = readimage(testSet,i);
    img = imresize(img, imageSize(1:2));

    if size(img,3)==1
        img = repmat(img,1,1,3);
    end

    dlImg = dlarray(single(img),'SSC');

    feat = forward(featureNet, dlImg);

    testFeatures(:,i) = extractdata(feat);
    testLabels(i,1) = testSet.Labels(i);
    
    if mod(i,step) == 0 || i == numTest
        waitbar(i/numTest, h, ...
            sprintf('Testing network... %d%% (%d/%d)', ...
            round(100*i/numTest), i, numTest));
    end

end

close(h);
%% -----------------------------
% PREDICTION
% -----------------------------
%predictedLabels = predict(classifier, testFeatures');
numTest = size(testFeatures,2);
predictedLabels = strings(numTest,1);

for i = 1:numTest
    f = testFeatures(:,i);

    scores = centroids' * f;
    [~,idx] = max(scores);

    predictedLabels(i) = classes(idx);
end
%% -----------------------------
% METRICS
% -----------------------------
testLabels = categorical(testLabels);
predictedLabels = categorical(predictedLabels);

confMat = confusionmat(testLabels, predictedLabels);

accuracy = mean(diag(confMat ./ max(sum(confMat,2),1)));

confMat_norm = 100 * confMat ./ max(sum(confMat,2),1);

end