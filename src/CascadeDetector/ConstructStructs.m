
imagesList = getAllFiles('/home/halil/Workspaces/workspace/CarModelEstimation/src/data/cardata/data/cars/gilman/cropped');

current = struct('imageFilename', [], 'objectBoundingBoxes', []);

for i=1:size(imagesList, 1)
    current(i).imageFilename = imagesList{i, 1};
    tempImg = imread(current(i).imageFilename);
    imwrite(tempImg, strcat('/home/halil/Workspaces/workspace/CarModelEstimation/src/data/cardata/data/cars/gilman/cropped/backOfCar/image_', num2str(i, '%.4d'), '.jpg'));
%     current(i).objectBoundingBoxe = [1, 1, size(tempImg, 2), size(tempImg, 1)];
end




