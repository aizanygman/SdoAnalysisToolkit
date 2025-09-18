%sdoStack = cellzcat(sdoCell(:,10));
%sdoStackTwo = cellzcat(sdoCell(1,:)');
% Flatten two SDO matrices into vectors
%{
A = sdoCell{1,10}(:);  % zDelay = 1
B = sdoCell{10,10}(:); % zDelay = 10

% Compute Pearson correlation
r = corr(A, B);
disp(['Correlation between zDelay 1 and 10: ', num2str(r)]);
%}
% correlation by state, column

fixed_d = 10;               % Fix duration
nStates = size(sdoCell{1, fixed_d}, 1);  
corrByCol = zeros(nStates, N_SHIFTS);   % One row per state, one col per zDelay

for ss = 1:N_SHIFTS
    sdo = sdoCell{ss, fixed_d};
    
    for st = 1:nStates
        % Compute correlation of each state with itself at zDelay=1
        baseCol = sdoCell{1, fixed_d}(:,st);
        targetCol = sdo(:,st);
        corrByCol(st, ss) = corr(baseCol, targetCol);
    end
end

% Plot as heatmap
imagesc(corrByCol); colorbar;
xlabel('zDelay'); ylabel('Post-Spike State');
title('Column-wise Correlation Across zDelays');
