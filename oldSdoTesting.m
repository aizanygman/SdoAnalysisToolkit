%% sdoAnalysis_demo (OOP)
%
% Demonstration of the SDO Analysis Toolkit; 
% Run an SDO analysis using the Object-Oriented Programming (OOP)
% class-method data wrappers. 
%

% This can be used as a framework for designing custom SDO analysis

%_______________________________________
% Copyright (C) 2023 Trevor S. Smith
% Drexel University College of Medicine
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%__________________________________________


% // Default Demo-data loader
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

% __ Example SMU x EMG
%XT_CH_NO = 8; 
%PP_CH_NO = 12; 
% __ Example IN x EMG
XT_CH_NO = 6; 
PP_CH_NO = 4; 

% __ Initialize and populate an 'xtDataCell' class

xtdc = xtDataCell(); 
xtdc.import(xtData); 
%
xtdc.dataField = 'envelope'; 
%xtdc.dataField = 'raw'; 
%xtdc.mapMethod = 'logsigned'; 
xtdc.mapMethod = 'log';
%xtdc.mapMethod = 'linearsigned'; 
xtdc.nBins      = 40; 
%
xtdc = xtdc.discretize(); %state-map signal

% __ Initialize and populate a 'ppDataCell', class


ppdc = ppDataCell(); 
ppdc.import(ppData); 
% // Shuffle Spiketimes 
ppdc.nShuffles = 1; 
ppdc.shuffle; 

% __ Generate pre-spike (px0) and post-spike (px1) 'pxt' classes; 
%// Prespike
px0 = pxtDataCell(); 
px0.duraMs = -40; 
%px0.duraMs = -10; % Negative here to refer to data -before- spiking event;
px0.import(xtdc, ppdc, XT_CH_NO, PP_CH_NO); 

%// PostSpike
px1 = pxtDataCell(); 
px1.duraMs = 40; 
px1.import(xtdc, ppdc, XT_CH_NO, PP_CH_NO); 

% __ compute the sdo from the 'sdoMat' class as the difference between probability distributions; 


% Construct the multi-comparisons class
smm = sdoMultiMat(); 
%{
smm.px0DuraMs = -30;
smm.px1DuraMs = 30;
smm.zDelay = 10;
% Calculate the SDOs 
smm.compute(xtdc,ppdc, 'parallelCompute', 1, 'backgroundSubtraction', 1); 
%}

N_SHIFTS = 10; 
N_DURA = 20;

sdoCell = cell(N_SHIFTS, N_DURA);
backgroundSDOCell = cell(N_SHIFTS, N_DURA);
bootSdoCell = cell(N_SHIFTS, N_DURA);

for ss = 1:N_SHIFTS
    for d = 1:N_DURA
        smm_temp = copy(smm); % produce temporary copy of reference sdoMultiMat from memory, keeping the same properties)
        smm_temp.px0DuraMs  = -d; 
        smm_temp.px1DuraMs  = d; 
        smm_temp.nShift = ss; 
        %
        smm_temp.compute(xtdc,ppdc, XT_CH_NO, PP_CH_NO, 'backgroundSubtraction', 1); 
        %
        sdoCell{ss,d} = smm_temp.getSdos(1,1); % 1st xt channel, 1st ppChanne
        
        %{
        % save joint background SDO
        %jointBackgroundSDO = smm_temp.nullSDO{XT_CH_NO, PP_CH_NO};
        jointBackgroundSDO = smm_temp.getBackgroundSdo(XT_CH_NO, PP_CH_NO);

        % normalize background SDO columns to form left-Markov matrix
        M = SAT.sdoUtils.normpdfcol2unity(jointBackgroundSDO);

        % get actual pre/post distributions used in SDO
        [px0, px1] = smm_temp.getPx0Px1(xtdc, ppdc, XT_CH_NO, PP_CH_NO);
        px0star = M * px0;  % predicted px1 based on background

        % bootstrap shuffled SDOs (~100 resamples)
        N_SHUFF = 100;
        bootSDOs = SAT.sdoUtils.bootstrapSDOs(px0star, px1, N_SHUFF);  % returns (nStates, nStates, N_SHUFF)
        
        % store all in organized cell arrays
        backgroundSDOCell{ss,d} = jointBackgroundSDO;
        bootSdoCell{ss,d} = bootSDOs;
        %}
    end
end

% === Create frogStruct ===
frogStruct = struct();
f = 1; % Frog index
n = PP_CH_NO; % neuron index (based on pp channel)
m = XT_CH_NO; % muscle index (based on xt channel)

idx = 1;
for ss = 1:N_SHIFTS
    for d = 1:N_DURA
        % Extract SDO and background
        sdoMat = sdoCell{ss,d};
        bgMat = backgroundSDOCell{ss,d};
        boots = bootSdoCell{ss,d};  % (nStates x nStates x N_SHUFF)

        % Peak value
        peakVal = max(sdoMat(:));

        % Significance: check if peak exceeds 95th percentile of bootstraps
        shuffledPeaks = squeeze(max(max(boots,[],1),[],2)); % Max per shuffle
        isSig = peakVal > prctile(shuffledPeaks, 95);

        % Store in structured tree
        frogStruct(f).neurons(n).ppChannel = PP_CH_NO;
        frogStruct(f).neurons(n).muscles(m).xtChannel = XT_CH_NO;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).matrix = sdoMat;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).background = bgMat;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).peakValue = peakVal;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).isSignificant = isSig;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).shift = ss;
        frogStruct(f).neurons(n).muscles(m).sdos(idx).dura = d;

        idx = idx + 1;
    end
end
%{
% __ Plot SDOs
smm.plot(XT_CH_NO,PP_CH_NO); 

smm.plotStirpd(XT_CH_NO, PP_CH_NO); 


% __ Internal Prediction Error by. Matrix Hypotheses (H1-H7); 
predictionError = smm.getPredictionError(xtdc, ppdc, XT_CH_NO, PP_CH_NO); 

plot(predictionError)
%}
%{
% __ Make transition Matrices from the 'sdoMat' class
sdo.makeTransitionMatrices(xtdc, ppdc); 

% __ Predict a probability distribution from the 'sdoMat' class from an
% initial probability distribution; 
pd_px1 = sdo.getPredictionPxt(px0); 

% __ Compare predictions relative to observed post-spike probability
% distributions; 

pd_px1.comparePxt(px1); %compare against post-spike interval

% __ Plot prediction errors between the two 'pxt' classes; 
pd_px1.plotError; 
%}

clear ffile2 fdir1 ffile1 xtData0 ppData0