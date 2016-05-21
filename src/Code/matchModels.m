% [models, maxNum] = readModels('../data/cardata/data/cars/gilman/labels.info');

% v = VideoReader('../data/video/031805_0815_0915.mp4');
% 
% numberOfFrames = 2100;
% 
% frames = read(v, [1 numberOfFrames]);
%%
% grayFrames = zeros(size(frames,1)*4/10, size(frames,2)*4/10, 10, 'uint8');
% 
% for i=1:10
%     grayFrames(:, :, i) = rgb2gray(imresize(frames(:, :, :, i), 0.4));
% end


%%
matches = matchBoxes(grayFrames(:, :, :), centers(1:10), models);
