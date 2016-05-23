setDir  = fullfile('../data/cardata/data/cars/gilman/grayModel');

imgSets = imageSet(setDir, 'recursive');

[trainingSets,testSets] = partition(imgSets,0.3,'randomize');

bag = bagOfFeatures(trainingSets,'Verbose',true);

categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

confMatrix = evaluate(categoryClassifier, testSets);
