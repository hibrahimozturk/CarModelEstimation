function background = tresholdAndFinding(background)

    background = uint8(background >  50) *255;
    
    %imdilation
    
    %creta a dilation struct
    sd = strel('square', 9);
    
    for i = 1:size(background,4)
        
        %take current backgrouund
        im_t = background(:,:,:,i);
        
        %use dialtion to current background
        im_t = imdilate(im_t, sd);
        
        %saving
        background(:,:,:,i) = im_t;  

    end
    
    %convert to binary image
    background = (background == 255);


end