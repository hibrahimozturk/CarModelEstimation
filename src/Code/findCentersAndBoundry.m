function info_container = findCentersAndBoundry(label_container)


centers = struct('c',[], 'sz', [], 'mins', [], 'maxs', []);
    for i=1:size(label_container,3)
       c_l = label_container(:,:,i);
       c_cordinate = [];
       c_sz =[];
       min_idx = [];
       max_idx = [];
       for j = 1: max(max(c_l))
          [r,c] = find(c_l == j);
          if size(r,1) < 1500 
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

info_container = centers;

end