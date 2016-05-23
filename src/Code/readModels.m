function [models, maxNumOfFeatures] = readModels(infoPath)

info = readInfo(infoPath);
maxNumOfFeatures = 0;
models = struct('modelDef', 'model', 'modelFeatures', 'sift', 'modelPath', 'path');

for i=1:length(info)
    models(i).modelDef = info(i).modelDef;
    models(i).modelPath = info(i).modelPath;
    img = rgb2gray(imresize(imread(info(i).modelPath), 0.4));
    surfPoints = detectSURFFeatures(img);
    [features, centers] = extractFeatures(img, surfPoints);
%     [points, features] = vl_sift(single(img));
%     features = features';
    if(size(features, 1) > maxNumOfFeatures)
        maxNumOfFeatures = size(features, 1);        
    end
    models(i).modelFeatures = features;
end

end


function info = readInfo(infoPath) 
%Returns models and locations

info = struct('modelDef', 'model', 'modelPath', 'path');

infoFile = fopen(infoPath);

tline = fgets(infoFile);

parts = strsplit(infoPath, '/');

lastPart = parts(length(parts));
lastPartLength = length(lastPart{1});
rootPathForImages = infoPath(1:(length(infoPath)- lastPartLength));

i = 0;
while ischar(tline)
    i = i + 1;
    clearPath = tline(3:length(tline));
    modelPath = strcat(rootPathForImages, clearPath);
    modelDef = fgets(infoFile);        
    info(i).modelDef = modelDef;
    info(i).modelPath = modelPath;
    tline = fgets(infoFile); 
end

fclose(infoFile);

end
