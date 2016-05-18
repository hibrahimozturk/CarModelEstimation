function bck =  takeMedianBackground(img_container)

    bck = zeros(size(img_container(:,:,:,1)));
    % take median of all frame
    bck(:,:,1) = median(img_container(:,:,1,:),4);
    bck(:,:,2) = median(img_container(:,:,2,:),4);
    bck(:,:,3) = median(img_container(:,:,3,:),4);
end
