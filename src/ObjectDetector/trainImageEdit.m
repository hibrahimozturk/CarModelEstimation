imagesList = getAllFiles('/home/halil/Workspaces/workspace/CarModelEstimation/src/data/cardata/data/cars/gilman/grayModel/grayNotBackOfCarSmall');

for i=1:size(imagesList, 1)
    tempImg = imread(imagesList{i});

    if(size(tempImg,3) == 1)
        tempImg = imresize(tempImg, 0.5);
    else
        tempImg = imresize(rgb2gray(tempImg), 0.5);
    end

    imwrite(tempImg, strcat('/home/halil/Workspaces/workspace/CarModelEstimation/src/data/cardata/data/cars/gilman/grayModel/grayNotBackOfCarSmall/image_', num2str(i, '%.4d'), '.jpg'));
end
