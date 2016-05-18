function labels = labelImage(binary_image_container)

    %initialize labels
    labels = [];
 
    for i= 1:size(binary_image_container,4)
        
        %use bwlabel function for labeling
        labels(:,:,i) = bwlabel(binary_image_container(:,:,:,i),4);

    end



end