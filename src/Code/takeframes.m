function imgs = takeframes(v_name)

    %read video
    v = VideoReader(strcat('data/video/',v_name,'.mp4'));
    %initialzie imgs
    imgs = [];
    %read frames
    counter =1;
    counter_2 = 1;
    while hasFrame(v)
        
        videof = readFrame(v);
        current_f = double(videof);
        
        if(counter ==1 && counter_2 > 6300)
            %take memory for imgs
            [r,c,d] = size(imresize(current_f, 0.4));
            imgs = zeros(r,c,d,2100);
        end
        
        if(counter_2 >4200)
            imgs(:,:,:,counter) = imresize(current_f, 0.4);
            counter = counter + 1;
        end
        %frames limit
        if(counter > 2100) 
            break
        end
        counter_2 = counter_2 +1;
    end
end