function matches = matchBoxes(frames, centers, models)

matches = struct('c',[], 'sz',[],  'mins',[],  'maxs', [], 'models', [], 'modelMetrics', [], 'modelPaths', []);

for i=1:size(centers, 2)
    currentFrame = centers(i);

    matches(i).c = currentFrame.c;
    matches(i).sz = currentFrame.sz;
    matches(i).mins = currentFrame.mins;
    matches(i).maxs = currentFrame.maxs;

    numberOfBox = size(centers(i).c, 1); 
    for j=1:numberOfBox
        box = frames(currentFrame.mins(j, 1):currentFrame.maxs(j,1), currentFrame.mins(j, 2):currentFrame.maxs(j, 2), i);
        [points, boxFeatures] = vl_sift(single(box));
        boxFeatures = boxFeatures';
%         surfPoints = detectSURFFeatures(box);
%         [boxFeatures, c] = extractFeatures(box, surfPoints);

        matchMetric = zeros(size(models,2), 1);
        for k=1:size(models, 2)
            [indexPairs, metric] = matchFeatures(boxFeatures, models(k).modelFeatures);
            matchMetric(k, 1) = mean(metric);
        end

        [bestMatchV, BestMatchModelIndex] = min(matchMetric);
        matches(i).models = [matches(i).models, models(BestMatchModelIndex).modelDef];
        matches(i).modelMetrics = [matches(i).modelMetrics, bestMatchV];
        matches(i).modelPaths = [matches(i).modelPaths, models(BestMatchModelIndex).modelPath];

    end
end

end
