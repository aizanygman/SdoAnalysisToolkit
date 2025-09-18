function analyzeSdoStruct(sdoStruct)
% Analyze and mine SDO data by clustering, frequency comparison, energy surface tracking, and peak capture.
% Input:
%   sdoStruct - Array of structures with SDO and metadata.

if isempty(sdoStruct)
    error('sdoStruct is empty.');
end

% 1. Extract and visualize spike frequencies
frequencies = [sdoStruct.frequency];
figure; 
subplot(2,2,1);
histogram(frequencies);
xlabel('Spike Frequency (Hz)');
ylabel('Count');
title('Spike Frequency Distribution');

% 2. Vectorize SDOs for clustering
N = length(sdoStruct);
sdoVectors = zeros(N, numel(sdoStruct(1).sdoMatrix));
for i = 1:N
    sdoVectors(i, :) = sdoStruct(i).sdoMatrix(:)';
end

% 3. Cluster SDOs
numClusters = 4;
[idx, centroids] = kmeans(sdoVectors, numClusters, 'Replicates', 5);

% Visualize cluster centroids
subplot(2,2,2);
for k = 1:numClusters
    subplot(2,2,k+2);
    imagesc(reshape(centroids(k,:), size(sdoStruct(1).sdoMatrix)));
    title(['Cluster ' num2str(k)]);
    colorbar;
end

% 4. Track Energy Surface SDOs
uniqueSurfaces = unique({sdoStruct.energySurfaceID});
figure;
for i = 1:length(uniqueSurfaces)
    idxSurf = strcmp({sdoStruct.energySurfaceID}, uniqueSurfaces{i});
    sdosForSurface = cat(3, sdoStruct(idxSurf).sdoMatrix);
    meanSDO = mean(sdosForSurface, 3);
    
    subplot(ceil(length(uniqueSurfaces)/2),2,i);
    imagesc(meanSDO);
    title(['Energy Surface: ' uniqueSurfaces{i}]);
    colorbar;
end

% 5. Visualize Peak SDO values
peakVals = [sdoStruct.peakSDO];
figure;
bar(peakVals);
xlabel('SDO Sample Index');
ylabel('Peak SDO Value');
title('Peak SDO Across Samples');

end
