% [models, maxNum] = readModels('../data/cardata/data/cars/gilman/labels.info');
%%
v = VideoReader('../data/video/031805_0815_0915.mp4');

numberOfFrames = 1000;

frames = read(v, [1 numberOfFrames]);



% grayFrames = zeros(size(frames,1)*4/10, size(frames,2)*4/10, 10, 'uint8');
% 
% for i=1:50
%     grayFrames(:, :, i) = rgb2gray(imresize(frames(:, :, :, i+300), 1));
% end

%%

% load('../data/matfiles/031805_0815_0915-objects-part1.mat');
% matches = matchBoxes(grayFrames(:, :, :), centers(1:10), models);
