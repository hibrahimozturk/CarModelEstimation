function matches = matchsift(F1, F2, Th)
    
F1 = int64(F1);
F2 = int64(F2);

F1 = F1(:, F1(1,:) > 0);
F2 = F2(:, F2(1,:) > 0);

numberOfInputs1 = size(F1, 2);
numberOfInputs2 = size(F2, 2);

extendF2 = repmat(F2, [1 1 size(F1, 2)]);
extendF1 = repmat(F1, [1 1 size(F2, 2)]);
rotatedF1 = permute(extendF1, [1 3 2]);

diff = extendF2 - rotatedF1;
squarediff = diff .^ 2;
ssd = sum(squarediff);

ssd = reshape(ssd, [numberOfInputs2, numberOfInputs1]);

%[thRow, thCol] = find(ssd(:,:) > Th);
%ssd(sub2ind(size(ssd), thRow, thCol)) = [];

[sortedDists2, sortedIndexes2] = sort(ssd, 2);
[sortedDists1, sortedIndexes1] = sort(ssd', 2);

%matches = zeros(3, numberofinputs2);
matches = zeros(3,1);
for i=1:size(ssd,1)
    matches = findBestMatch(i, numberOfInputs1, sortedDists2, sortedIndexes2, matches);
end

[thRow, thCol] = find(matches(3,:) > Th);
matches(:, thCol) = [];

end

function matches = findBestMatch(currentBox, numberOfInputs1, sortedDists2, sortedIndexes2, matches)
for j=1:numberOfInputs1
    insertMacth = [currentBox; sortedIndexes2(currentBox,j); sortedDists2(currentBox,j)];
    [V, duplicateIndex] = find(matches(2,:) == sortedIndexes2(currentBox,j));
    if(size(duplicateIndex, 2) == 0)
        %add to matches
        matches = [matches insertMacth];
        break;
    else
        if(insertMacth(3,1) < matches(3, duplicateIndex(1)))
            %delete duplicate and find new match for removed duplicate
            deletedMatch = matches(:, duplicateIndex(1));
            matches(:, duplicateIndex(1)) = [];
            matches = [matches insertMacth];
            matches = findBestMatch(deletedMatch(1), numberOfInputs1, sortedDists2, sortedIndexes2, matches);        
            break;
        else
            continue;
        end
    end
end

end
