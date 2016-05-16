function [result, counter] = asg4_median(root)
    
    %read imge
    imgs = [];
    load(strcat('data/matfiles/',root));
    imgs = (frames);
    frames = [];
    

    limit = size(imgs,4);
    bck = zeros(size(imgs(:,:,:,1)));
    % take median of all frame
     bck(:,:,1) = median(imgs(:,:,1,:),4);
     bck(:,:,2) = median(imgs(:,:,2,:),4);
     bck(:,:,3) = median(imgs(:,:,3,:),4);


    %take diffenrence
    backg = uint8([]);
    for i = 1:limit

        current_f  = abs(imgs(:,:,:,i) - bck);
        current_f = rgb2gray(uint8(current_f));
        backg(:,:,:,i) = uint8(current_f);

    end
    
    %treshold all image
    backg = uint8(backg >  65) *255;
    %imerode and imdilate
    se = strel('square',3);
    sd = strel('square', 15);
    for i = 1:limit
        im_t = backg(:,:,:,i);

        im_t = imerode(im_t, se);
        im_t = imdilate(im_t, sd);
        backg(:,:,:,i) = im_t;  


    end
    backg = backg == 255;
    
    masked_im = imgs ;
    for i= 1: 3
        masked_im(:,:,i,:) = imgs(:,:,i,:) .* backg;
    end

    L = [];
    for i= 1:limit
        L(:,:,i) = bwlabel(backg(:,:,:,i),4);

    end

    centers = struct('c',[], 'sz', [], 'mins', [], 'maxs', []);
    for i=1:limit
       c_l = L(:,:,i);
       c_cordinate = [];
       c_sz =[];
       min_idx = [];
       max_idx = [];
       for j = 1: max(max(c_l))
          [r,c] = find(c_l == j);
          if size(r,1) < 150 
              continue;
          end
          rc = [r c];
          m_rc = floor(mean(rc));
          c_cordinate(j,:) = m_rc;
          c_sz(j) = size(r,1);
          min_idx(j,:) = min(rc);
          max_idx(j,:) = max(rc);
       end
       centers(i).c = c_cordinate;
       centers(i).mins = min_idx;
       centers(i).maxs = max_idx;
       centers(i).sz = c_sz;
    end
    save(strcat('data/matfiles/',root,'-objects'), 'centers','-v7.3');
    %track the ojects
    [row,clm] = size(imgs(:,:,1,1));
    current_obj = struct('centers', [], 'histg', [], 'count', [], 'id', [], 'activate' , []);
    current_obj_num = 0;
    counter = 0;
    for i=1:limit
        res = imgs(:,:,:,i);
        if current_obj_num == 0
            for j=1:size(centers(i).c,1)
                current_his =[];
                if(centers(i).sz(j) > 500)
                    %take boundry
                     b_l = centers(i).mins(j,1)+3;
                     b_r = centers(i).maxs(j,1);
                     b_t = centers(i).mins(j,2)+3;
                     b_d = centers(i).maxs(j,2);

                    curr_ob = res(b_l:b_r,b_t:b_d,:);
                    current_his(:,1) = imhist(curr_ob(:,:,1));
                    current_his(:,2) = imhist(curr_ob(:,:,2));
                    current_his(:,3) = imhist(curr_ob(:,:,3));

                    current_obj_num = current_obj_num + 1;

                    current_obj(current_obj_num).centers = centers(i).c(j,:);
                    current_obj(current_obj_num).histg = current_his;
                    current_obj(current_obj_num).count = 0;
                    current_obj(current_obj_num).activate = 0;

                    counter = counter +1;
                    current_obj(current_obj_num).id = counter;
                    res = insertText(uint8(res), [b_t+2 b_l+2],  sprintf('%.3d',counter), 'TextColor','red');
                    res(b_l:b_r,b_t-1:b_t,:) = 0;
                    res(b_l:b_r,b_d-1:b_d,:) = 0;
                    res(b_l-1:b_l,b_t:b_d,:) = 0;
                    res(b_r-1:b_r,b_t:b_d,:) = 0;
                end
            end
        else
            match = [];
            for k=1:current_obj_num
                if current_obj(k).activate == 1
                    continue;
                end
                minumum = -1;
                min_idx = -1;
                min_his = [];
                min_bounder = [];
                for j=1:size(centers(i).c,1)
                    if size(find(match==j),1) == 1
                        continue;
                    end
                    current_his =[];
                    if(centers(i).sz(j) > 500)
                        %take boundry
                         b_l = centers(i).mins(j,1)+3;
                         b_r = centers(i).maxs(j,1);
                         b_t = centers(i).mins(j,2)+3;
                         b_d = centers(i).maxs(j,2);

                        curr_ob = res(b_l:b_r,b_t:b_d,:);
                        current_his(:,1) = imhist(curr_ob(:,:,1));
                        current_his(:,2) = imhist(curr_ob(:,:,2));
                        current_his(:,3) = imhist(curr_ob(:,:,3));

                        dist = centers(i).c(j,:) - current_obj(k).centers;
                        dist = sqrt(sum(dist .* dist));

                        if( dist < 40)
                            dist_2 = current_his - current_obj(k).histg;
                            dist_2 = sqrt(sum(sum(dist_2 .* dist_2)));
                            if minumum == -1
                                minumum = dist_2;
                                min_idx = j;
                                min_his =current_his;
                                min_bounder = [b_l b_r b_d b_t];
                            else
                                if minumum > dist_2
                                    minumum = dist_2;
                                    min_idx = j;
                                    min_his =current_his;
                                    min_bounder = [b_l b_r b_d b_t];
                                end
                            end
                        end


                    end
                end
                if(minumum ~= -1)
                    match(size(match,1)+1) = min_idx;       
                    current_obj(k).centers = centers(i).c(min_idx,:);
                    current_obj(k).histg = min_his;
                    current_obj(k).count = 0;
                    current_obj(k).activate =0;
                    res = insertText(uint8(res), [min_bounder(4)+2 min_bounder(1)+2],  sprintf('%.3d',current_obj(k).id), 'TextColor','red');
                    res(min_bounder(1):min_bounder(2),min_bounder(4)-1:min_bounder(4),:) = 0;
                    res(min_bounder(1):min_bounder(2),min_bounder(3)-1:min_bounder(3),:) = 0;
                    res(min_bounder(1)-1:min_bounder(1),min_bounder(4):min_bounder(3),:) = 0;
                    res(min_bounder(2)-1:min_bounder(2),min_bounder(4):min_bounder(3),:) = 0;
                else
                    current_obj(k).count = current_obj(k).count+1;
                    %object does not exist anymore control
                    if( current_obj(k).count > 15)
                        current_obj(k).activate = 1;
                    end
                end

            end

            for j=1:size(centers(i).c,1)
                if size(find(match==j),1) == 1
                    continue;
                end
                current_his =[];
                if(centers(i).sz(j) > 500)
                    %take boundry
                     b_l = centers(i).mins(j,1)+3;
                     b_r = centers(i).maxs(j,1);
                     b_t = centers(i).mins(j,2)+3;
                     b_d = centers(i).maxs(j,2);

                    curr_ob = res(b_l:b_r,b_t:b_d,:);

                    current_his(:,1) = imhist(curr_ob(:,:,1));
                    current_his(:,2) = imhist(curr_ob(:,:,2));
                    current_his(:,3) = imhist(curr_ob(:,:,3));

                    current_obj(current_obj_num+1).centers = centers(i).c(j,:);
                    current_obj(current_obj_num+1).histg = current_his;

                    current_obj(current_obj_num+1).count = 0;

                    current_obj_num = current_obj_num + 1;
                    counter = counter +1;
                    current_obj(current_obj_num).id = counter;
                    res = insertText(uint8(res), [b_t+2 b_l+2],  sprintf('%.3d',counter), 'TextColor','red');
                    res(b_l:b_r,b_t-1:b_t,:) = 0;
                    res(b_l:b_r,b_d-1:b_d,:) = 0;
                    res(b_l-1:b_l,b_t:b_d,:) = 0;
                    res(b_r-1:b_r,b_t:b_d,:) = 0;
                end
            end
        end
        
        result(:,:,:,i) = res;
    end
end
