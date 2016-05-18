function backg = takeDifference(img_container,background)
   

   backg = uint8([]);
   
   for i = 1:size(img_container,4)

       current_f  = abs(img_container(:,:,:,i) - background);
       current_f = rgb2gray(uint8(current_f));
       backg(:,:,:,i) = uint8(current_f);

   end


end