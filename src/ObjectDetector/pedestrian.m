readImages = 0;
findObjects = 1;

imageWidth = 360;
imageHeight = 240;
numberOfImages = 1099;

backgroundEstimation ='Median';

if readImages == 1
    rgbimages = zeros(imageHeight, imageWidth, 3, numberOfImages, 'uint8');
    images = zeros(imageHeight, imageWidth, numberOfImages,  'uint8');
    imagefiles = dir('../src/data/pedestrian/*.jpg');
    masks = zeros(imageHeight, imageWidth, numberOfImages, 'uint8');
    rgbhists = zeros(256*3, 14, numberOfImages);
    parfor i=1:length(imagefiles)
        rgbimages(:,:,:,i) = (imread(strcat('../src/data/pedestrian/',imagefiles(i).name)));
        images(:, :, i) = rgb2gray(rgbimages(:,:,:,i)); 
    end

end

if findObjects == 1

    labels = zeros(10, numberOfImages);
    features = zeros(256*3+2, 14, numberOfImages, 'uint32');
    outRGBimages = rgbimages;


    %1-size 2-x 3-y 4-bottom 5-left 6-top 7-right
    axes = zeros(7, 14, numberOfImages, 'uint32');
    axes(2, :, :) = imageHeight*2+1;
    axes(3, :, :) = imageWidth*2+1;

    sizeTh = 400;
    objectCounter = 1;
    matchThreshold = 1000000;

    outimages = images;
    medianBackground = im2double(median(images,3));

    currentBackground = im2double(images(:, :, 1));
    alpha = 0.02;

    maxturn = 0;
    
    for i=2:length(imagefiles)

        currentImage = im2double(images(:, :, i));

        if strcmp(backgroundEstimation, 'MovingAverage')
            previousBackground = currentBackground;
            currentBackground = alpha*currentImage+(1-alpha)*previousBackground;
            difference = abs(currentImage - currentBackground);

        elseif strcmp(backgroundEstimation, 'Median')
            difference = abs(currentImage-medianBackground);
        end

        numOfBackFrame = 5;

        e =  im2double(difference);
        thresholdedImage = im2bw(e, 0.080);
        noiseRemovedImage = imerode(thresholdedImage, ones(3,3));
        dilatedImage = imdilate(noiseRemovedImage, ones(15,15));
        labeledComponents = bwlabel(dilatedImage);
        labeledComponents(150:240, :) = 0;
        masks(:,:,i) = labeledComponents(:,:);

        n = 1;
        j = 1;
        while 1
            sizeOfComponent = sum(sum(labeledComponents(:, :) == n));
            if sizeOfComponent == 0
                if j > maxturn
                    maxturn = j;
                end
                break;
            end
            if sizeOfComponent < sizeTh
                n = n + 1;
                continue;
            end
            axes(1, j, i) = sizeOfComponent;
            [row, col] = find(labeledComponents(:, :) == n);
            axes(4, j, i) = min(row);
            axes(5, j, i) = min(col);
            axes(6, j, i) = max(row);
            axes(7, j, i) = max(col);
            axes(2, j, i) = (max(col) + min(col))/2;
            axes(3, j, i) = (max(row) + min(row))/2;
            width = (uint8(axes(7, j, i)-axes(5, j, i))/2)*2;
            height = (uint8(axes(6, j, i)-axes(4, j, i))/2)*2;
            red = rgbimages(:, :, 1, i); green = rgbimages(:, :, 2, i); blue = rgbimages(:, :, 3, i);
            rgbhists(1:256, j, i) = histcounts(red(sub2ind(size(red), row, col)), (1:257));
            rgbhists(257:256*2, j, i) = histcounts(green(sub2ind(size(green), row, col)), (1:257));
            rgbhists(256*2+1:256*3, j, i) = histcounts(blue(sub2ind(size(blue), row, col)), (1:257));
            features(1:2, j, i) = axes(2:3, j, i)*100;
            features(3:256*3+2, j, i) = rgbhists(:, j, i);
            outRGBimages(:, :,:, i) = insertShape(outRGBimages(:, :,:, i), 'rectangle', [axes(5, j, i), axes(4, j, i), width, height], 'Color', 'y');
            
            j = j + 1;
            n = n + 1;
        end
        
        if i <= numOfBackFrame
            numOfBackFrame = i-1;    
        end

        matches = cell(numOfBackFrame, 1);
        for backFrame=1:numOfBackFrame
           matches{backFrame} = matchObjects(features(:, :, i-backFrame), features(:, :, i), matchThreshold);
        end

        for q=1:j-1
            for backFrame=1:numOfBackFrame
                [V match] = find(matches{backFrame}(1, :) == q);
                if(size(match, 2) ~= 0)
                    break;
                end
            end
            if(size(match, 2) == 0)
                %there is no match new label assign
                labels(q, i) = objectCounter;
                objectCounter = objectCounter + 1;
            else 
                labels(q, i) = labels(matches{backFrame,1}(2,match), i-backFrame);
            end
        end

        for q=1:j-1
            outRGBimages(:, :, :,  i) = insertText(outRGBimages(:, :, :, i), [axes(5,q,i), axes(4,q,i)], int2str(labels(q,i)), 'FontSize', 8, 'BoxColor', 'yellow', 'TextColor', 'black');
        end
    end
end


%X = permute(outimages,[1 2 4 3]);
%movie = immovie(X, gray);
%movie2avi(movie, 'im5.avi');

for i=1:length(imagefiles)
    imwrite(outRGBimages(:,:,:,i), strcat('../src/data/out2-pedestrian/out', sprintf('%06d', i), '.jpg'));
    imwrite(masks(:,:,i), prism, strcat('../src/data/out2-pedestrian/mask', sprintf('%06d', i), '.jpg'));
end

