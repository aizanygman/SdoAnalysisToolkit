%% sdo_testing.m
% Hierarchical SDO analysis & storage

% ======== Load Data ========
if ~exist('xtData', 'var') || ~exist('ppData', 'var')
    [fpath_xt, fdir1] = uigetfile('*.mat', 'Open example xtData'); 
    [fpath_pp, fdir2] = uigetfile('*.mat', 'Open example ppData'); 

    ffile1 = fullfile(fdir1, fpath_xt); 
    ffile2 = fullfile(fdir2, fpath_pp); 

    xtData0 = load(ffile1); 
    ppData0 = load(ffile2); 
    xtfield = fields(xtData0); 
    ppfield = fields(ppData0); 
    xtData = xtData0.(xtfield{1}); 
    ppData = ppData0.(ppfield{1}); 
end

% Example channel mapping
XT_CH_NO = 6;  % muscle channel
PP_CH_NO = 4;  % neuron channel

% ======== Initialize Data Wrappers ========
xtdc = xtDataCell(); 
xtdc.import(xtData);
xtdc.dataField = 'envelope';
xtdc.mapMethod = 'log';
xtdc.nBins = 40;
xtdc = xtdc.discretize();

ppdc = ppDataCell(); 
ppdc.import(ppData);
ppdc.nShuffles = 1;
ppdc.shuffle();

% ======== SDO Loop Parameters ========
N_SHIFTS = 10; 
N_DURA = 20;

% ======== Create Empty Struct ========
frogStruct = struct();  
f = 1;  % Frog index
frogStruct(f).frogID = 'FrogA'; % optional metadata

n = PP_CH_NO; % neuron index
m = XT_CH_NO; % muscle index
idx = 1;      % sdo index counter

% ======== Loop Over Shifts & Durations ========
smm = sdoMultiMat(); 

for ss = 1:N_SHIFTS
    for d = 1:N_DURA
        % Copy & set params
        smm_temp = copy(smm);
        smm_temp.px0DuraMs  = -d;
        smm_temp.px1DuraMs  = d;
        smm_temp.nShift = ss;

        % Compute SDO
        smm_temp.compute(xtdc, ppdc, XT_CH_NO, PP_CH_NO, 'backgroundSubtraction', 1);
        sdoMat = smm_temp.getSdos(1, 1);

        % Background SDO & bootstrap
        try
            % jointBackgroundSDO = smm_temp.getBackgroundSdo(XT_CH_NO, PP_CH_NO);
            jointBackgroundSDO = smm_temp.getNormSdos(XT_CH_NO, 1, 1);
        catch
            jointBackgroundSDO = [];
        end
        if ~isempty(jointBackgroundSDO)
            M = SAT.sdoUtils.normpdfcol2unity(jointBackgroundSDO);
            [px0, px1] = smm_temp.getPx0Px1(xtdc, ppdc, XT_CH_NO, PP_CH_NO);
            px0star = M * px0;
            bootSDOs = SAT.sdoUtils.bootstrapSDOs(px0star, px1, 100);
        else
            bootSDOs = [];
        end

        % ======== Extract Features ========
        peakValue = max(sdoMat(:));
        isSignificant = peakValue > mean(sdoMat(:)) + 2*std(sdoMat(:));

        % ======== Store in Struct ========
        frogStruct(f).neurons(n).muscles(m).sdos(idx).matrix = sdoMat;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).background = jointBackgroundSDO;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).bootstrap = bootSDOs;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).peakValue = peakValue;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).isSignificant = isSignificant;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).shift = ss;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).dura = d;

        idx = idx + 1; % increment SDO index
    end
end

% ======== Save Struct ========
save('frogStruct.mat', 'frogStruct');
disp('frogStruct saved.');


%% ====== Test Struct Access ======
% Load 
if ~exist('frogStruct','var')
    load('frogStruct.mat');
end

% Check top-level frog
disp("Frog ID:");
disp(frogStruct(1).frogID);

% Check neurons
disp("Neuron fields:");
disp(fieldnames(frogStruct(1).neurons));

% Access neuron 4
neuronIndex = 4;
disp("Neuron struct:");
disp(frogStruct(1).neurons(neuronIndex));

% Check muscles under neuron 4
muscleIndex = 6;
disp("Muscle struct:");
disp(frogStruct(1).neurons(neuronIndex).muscles(muscleIndex));

% Access first SDO under that muscle
disp("First SDO info:");
disp(frogStruct(1).neurons(neuronIndex).muscles(muscleIndex).sdos(1));

% Access its matrix
sdoMat = frogStruct(1).neurons(neuronIndex).muscles(muscleIndex).sdos(1).matrix;
disp("Size of first SDO matrix:");
disp(size(sdoMat));

% Plot the first SDO 
figure;
imagesc(sdoMat);
title('First SDO Matrix');
xlabel('State j');
ylabel('State i');
colorbar;

