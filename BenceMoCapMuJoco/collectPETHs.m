function pethStruct = collectPETHs(buStruct)

% collect PETHs at 1 ms resolution from all units

addpath('./HelperFunctions/');

% params
bin = 1e-3; % sec
preTap = 1;
postTap = 2.5;

binTimes = -preTap:bin:postTap;
histedges = [binTimes-bin/2, binTimes(end)+bin/2];

eventInd = [5,6];
MSDNrate = 1e7;
samprate = 3e4;

%% get list of units and their session numbers

try
    temp = [buStruct(~cellfun(@isempty, {buStruct.units})).units];
catch
    temp = fixFields(buStruct(~cellfun(@isempty, {buStruct.units})), 'units');
end

[~, u_idx] = unique([temp.unitnum]);

pethStruct = struct('ratName', buStruct(1).ratName, ...
                    'bin', bin, ...
                    'binTimes', binTimes, ...
                    'unitNum', {temp(u_idx).unitnum}, ...
                    'unitName', {temp(u_idx).unitname}, ...
                    'unitType', {temp(u_idx).unitType}, ...
                    'avgwv', {temp(u_idx).avgwv});


%%  Get PETHs

for u = 1 : length(pethStruct)
    
    if u/50 == fix(u/50); disp(u); end
    
    % get sessions in which this unit is present
    usess = find(cellfun(@(x) ~isempty(x) && ismember(pethStruct(u).unitNum, [x.unitnum]), {buStruct.units}));
    
    % build common PETH for all sessions
    taps = [];
    nps = [];
    sessID = [];
    trialID = [];
    spikes = [];
    modes = [];
    for us = usess
        tap1Times = buStruct(us).tapTimes.tap1Times(:, eventInd(1))*MSDNrate/samprate + str2double(buStruct(us).EPhysFile);
        tap2Times = buStruct(us).tapTimes.tap2Times(:, eventInd(1))*MSDNrate/samprate + str2double(buStruct(us).EPhysFile);
        npTimes = NaN(size(tap1Times));
        npTrials = ~cellfun(@isempty, buStruct(us).nosePokeTimes);
        npTimes(npTrials) = cellfun(@(np,tap1) (np(1, eventInd(1)) - tap1)/samprate, ...
            buStruct(us).nosePokeTimes(npTrials), num2cell(buStruct(us).tapTimes.tap1Times(npTrials, eventInd(1))));
        
        taps = cat(1, taps, cat(2, tap1Times, tap2Times));
        nps = cat(1, nps, npTimes);
        sessID = cat(1, sessID, zeros(size(tap1Times))+us);
        trialID = cat(1, trialID, (1:length(tap1Times))');
        modes = cat(1, modes, buStruct(us).modes);
        
        spikes = cat(1, spikes, double(buStruct(us).units([buStruct(us).units.unitnum] == pethStruct(u).unitNum).spikes)*MSDNrate/samprate + str2double(buStruct(us).EPhysFile));
    end
    
    pethStruct(u).IPIs = diff(taps,1,2)/MSDNrate;
    pethStruct(u).nps = nps;
    pethStruct(u).sessID = sessID;
    pethStruct(u).trialID = trialID;
    pethStruct(u).exptID = [buStruct(sessID).exptID]'; 
    pethStruct(u).defID = [buStruct(sessID).defID]';
    pethStruct(u).target = [buStruct(sessID).target]'/1e3;
    pethStruct(u).lower = [buStruct(sessID).lower]'/1e3;
    pethStruct(u).upper = [buStruct(sessID).upper]'/1e3;
    pethStruct(u).rewards = vertcat(buStruct(usess).rewards);
    pethStruct(u).modes = modes;
    
    [~, peth] = arrangeSpikeTimes(spikes, taps(:,1), histedges, MSDNrate);
    
    pethStruct(u).peth = sparse(peth);
    
end



