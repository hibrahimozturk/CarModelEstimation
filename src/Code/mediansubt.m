
%initialize video name
v_name = '031805_0815_0915';

%take frames on video
imgs = takeframes(v_name);

%take frames number
limit = size(imgs,4);

%take median background
bck =  takeMedianBackground(imgs);

%take diffenrence
backg = takeDifference(imgs,bck);
    
%treshold and dialtion
backg = tresholdAndFinding(backg);
    
%label results
L = labelImage(backg);
   
% take centers and boundry 
centers = findCentersAndBoundry(L);

    %track the ojects
    [row,clm] = size(imgs(:,:,1,1));
    current_obj = struct('centers', [], 'histg', [], 'count', [], 'id', [], 'activate' , [], 'sz', [],'mins', [], 'maxs', [], 'framenum', []);
    current_obj_num = 0;
    counter = 0;
    for i=1:limit
        res = imgs(:,:,:,i);
        if current_obj_num == 0
            for j=1:size(centers(i).c,1)
                current_his =[];
                if(centers(i).sz(j) > 1500)
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
                    current_obj(current_obj_num).sz = centers(i).sz(j);
                    current_obj(current_obj_num).mins = centers(i).mins(j,:);
                    current_obj(current_obj_num).maxs = centers(i).maxs(j,:);
                    current_obj(current_obj_num).framenum = i;
                    counter = counter +1;
                    current_obj(current_obj_num).id = counter;
                    
                    res = insertText(uint8(res), [b_t+2 b_l+2],  sprintf('%.3d',counter), 'TextColor','red');
                    res = insertShape(res, 'rectangle', [b_t+1, b_l+1, (b_d-b_t), (b_r-b_l)], 'Color', 'black');
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
                c_limit = size(centers(i).c,1);
                for j=1:c_limit
                    if size(find(match==j),1) == 1
                        continue;
                    end
                    current_his =[];
                    if(centers(i).sz(j) > 1500)
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

                        if( dist < 100)
                            if((((abs((current_obj(k).mins(1,1)-current_obj(k).maxs(1,1)))*1.2)      > ...
                                    (abs((centers(i).mins(j,1)-centers(i).maxs(j,1)))))            && ...
                                    ((abs((current_obj(k).mins(1,2)-current_obj(k).maxs(1,2)))*1.2) > ...
                                    (abs((centers(i).mins(j,2)-centers(i).maxs(j,2)))))) || ...
                                    (centers(i).mins(j,2) ==1 && centers(i).maxs(j,1) == size(res,1)))
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
                            else
                                before_im = imgs(:,:,:,current_obj(k).framenum);
                                
                                template = rgb2gray(uint8(before_im(current_obj(k).mins(1,1):current_obj(k).maxs(1,1), ...
                                               current_obj(k).mins(1,2):current_obj(k).maxs(1,2),:)));
                               
                                A=[];
                                A = rgb2gray(uint8(res));
                                
                                c = normxcorr2(template,A);
                               
                                if(max(c(:)) > 0.7)
                                    [ypeak, xpeak] = find(c==max(c(:)));
                                    yoffSet = ypeak-size(template,1);
                                    xoffSet = xpeak-size(template,2);
%                                     A =res;
%                                     A =insertShape(A, 'rectangle', [xoffSet+1, yoffSet+1, size(template,2), size(template,1)], 'Color', 'y');
%                                     figure,imshow(uint8(A));
                                    idx = size(centers(i).sz,2)+1;
                                    centers(i).sz(idx) = current_obj(k).sz;
                                    centers(i).mins(idx,:) = [abs(yoffSet)+1 abs(xoffSet)+1];
                                     if(abs(yoffSet)+size(template,1) >= size(res,1))
                                        h_limit_1 = size(res,1) -2;
                                    else
                                        h_limit_1 = abs(yoffSet)+size(template,1);
                                    end
                                    if(abs(xoffSet)+size(template,2) >= size(res,2))
                                        h_limit_2 = size(res,2) -2;
                                    else
                                        h_limit_2 = abs(xoffSet)+size(template,2);
                                    end
                                    centers(i).maxs(idx,:) = [h_limit_1 h_limit_2];
                                    centers(i).c(idx,:) = floor(mean([centers(i).mins(idx,:);centers(i).maxs(idx,:)]));
                                    minumum = 0;
                                    min_idx = idx;
                                    min_his =current_obj(k).histg;
                                    min_bounder = [centers(i).mins(idx,1)+3 centers(i).maxs(idx,1) centers(i).maxs(idx,2) centers(i).mins(idx,2)+3];
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
                    current_obj(k).sz = centers(i).sz(min_idx);
                    current_obj(k).mins = centers(i).mins(min_idx,:);
                    current_obj(k).maxs = centers(i).maxs(min_idx,:);
                    current_obj(k).framenum = i;
                    
                    res = insertText(uint8(res), [min_bounder(4)+2 min_bounder(1)+2],  sprintf('%.3d',current_obj(k).id), 'TextColor','red');
                    
                    res = insertShape(res, 'rectangle', [min_bounder(4)+1, min_bounder(1)+1, ...
                                                         min_bounder(3)-min_bounder(4),      ...
                                                         min_bounder(2)-min_bounder(1)], 'Color', 'black');
                
                else
                    current_obj(k).count = current_obj(k).count+1;
                    %object does not exist anymore control
                    if( current_obj(k).count > 1)
                        current_obj(k).activate = 1;
                    end
                end

            end

            for j=1:size(centers(i).c,1)
                if size(find(match==j),1) == 1
                    continue;
                end
                current_his =[];
                if(centers(i).sz(j) > 1500)
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
                    current_obj(current_obj_num+1).sz = centers(i).sz(j);
                    current_obj(current_obj_num+1).mins = centers(i).mins(j,:);
                    current_obj(current_obj_num+1).maxs = centers(i).maxs(j,:);
                    current_obj(current_obj_num+1).count = 0;
                    current_obj(current_obj_num+1).framenum = i;
                    current_obj(current_obj_num+1).activate = 0;
                    current_obj_num = current_obj_num + 1;
                    counter = counter +1;
                    current_obj(current_obj_num).id = counter;
                    res = insertText(uint8(res), [b_t+2 b_l+2],  sprintf('%.3d',counter), 'TextColor','red');
                    res = insertShape(res, 'rectangle', [ b_t+1, b_l+1, (b_d-b_t), (b_r-b_l)], 'Color', 'black');
                    
                end
            end
        end
        
        result(:,:,:,i) = res;
    end

for j=1:size(result,4)
        imwrite(uint8(result(:,:,:,j)), strcat('Data/frames/',v_name,'/in', sprintf('%.6d',j+6483),'.jpg'));
end