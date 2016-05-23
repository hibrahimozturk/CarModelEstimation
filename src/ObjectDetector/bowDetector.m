% v = VideoReader('../data/video/031805_0815_0915.mp4');

numberOfFrames = 10;

% video = read(v, [1 numberOfFrames]);

% video = gpuArray(video);

%video = imresize(video, 0.5);

h = size(video, 1);
w = size(video, 2);

slide = 20;

% counter = 0;

threshold = 0;

boxes = struct('c', [], 'sz', [], 'mins', [], 'maxs', []);

bestWindow = zeros(numberOfFrames,5);

for imgNum=1:10
    for rate=1:1
        
        windowW = floor(w*(3/5)^rate);
        windowH = floor(windowW/2);

        verticalSliderStart = 1:slide:h;
        verticalSliderEnd = windowH:slide:h;

        horizontalSliderStart = 1:slide:w;
        horizontalSliderEnd = windowW:slide:w;

        outScoreMap = zeros(floor((h-windowH)/slide) + 1, floor((w-windowW)/slide)+ 1);
        outLabelMap = zeros(floor((h-windowH)/slide) + 1, floor((w-windowW)/slide)+ 1);

        outPerWindow = zeros(size(outScoreMap,1), size(outScoreMap, 2), 5);

        for i=1:length(verticalSliderEnd)
            for j=1:length(horizontalSliderEnd)
                window = video(verticalSliderStart(i):verticalSliderEnd(i), horizontalSliderStart(j):horizontalSliderEnd(j), imgNum );
                [labelIdx, score] = predict(categoryClassifier, window);

                %counter = counter + 1;

                outScoreMap(i, j) = score(1, 2);
                outLabelMap(i, j) = labelIdx;

                outPerWindow(i, j, 1) =   abs(score(1,2));
                outPerWindow(i, j, 2:3) = [verticalSliderStart(i), verticalSliderEnd(i)];
                outPerWindow(i, j, 4:5) = [horizontalSliderStart(j), horizontalSliderEnd(j)];
            end
        end
    end

    centerY = floor((bestWindow(imgNum, 2) + bestWindow(imgNum, 3))/2);
    centerX = floor((bestWindow(imgNum, 4) + bestWindow(imgNum, 5))/2);

    [maxCol, yOfMax] = max(abs(outScoreMap));
    [maxRow, xOfMax] = max(maxCol);
    yOfMax = yOfMax(xOfMax);
    
    bestWindow(imgNum, :) = outPerWindow(yOfMax, xOfMax, :);
    
    if(bestWindow(imgNum, 1) > threshold)
        boxes(imgNum).c = [centerX, centerY];
        boxes(imgNum).sz = (bestWindow(imgNum, 2) - bestWindow(imgNum, 3))*(bestWindow(imgNum, 4) - bestWindow(imgNum, 5));
        boxes(imgNum).mins = [bestWindow(imgNum, 2) , bestWindow(imgNum, 4)];
        boxes(imgNum).maxs = [bestWindow(imgNum, 3) , bestWindow(imgNum, 5)];
   end
end

