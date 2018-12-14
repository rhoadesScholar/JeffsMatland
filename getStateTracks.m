function stateTracks = getStateTracks(allTracks, hmmBin, stateTypes, indieStates)

if (nargin < 4)
    indieStates = false;
end
if (nargin < 3)
    stateTypes = {'dwelling' 'roaming'};
end

% stateIndex = ones(length(stateTypes),1);
[~, states.N2, hmmTR, hmmE] = getHMMStates(allTracks.N2,hmmBin);
strains = fields(allTracks);

for s=1:length(strains)%each strain
    
    if indieStates
        [~, states.(strains{s}), ~, ~] = getHMMStates(allTracks.(strains{s}),hmmBin);
    else
    [~, states.(strains{s}), ~, ~] = getHMMStatesSpecifyTRandE_2(allTracks.(strains{s}),hmmBin,hmmTR,hmmE);
    end
    %intervals.(strains{s}) = getStateAuto(allTracks.(strains{s}), hmmBin);
    
    for t=1:length(states.(strains{s}))%each track
        lastState = -1;
%         stateIndex(1:end) = 1;
        newFrame = 1;
        track = allTracks.(strains{s})(t);
        for i=1:hmmBin:(length(states.(strains{s})(t).states)-1)%each interval
            state = states.(strains{s})(t).states(i);
            if ~isnan(state)
                if lastState == -1
                    lastState = state;
                end
                if state ~= lastState
                    feels = fields(track);
                    for f = 1:length(feels)
                        [m, n] = size(track.(feels{f}));
                        if m == length(track.Frames)
                            stateTrack.(feels{f}) = track.(feels{f})(newFrame:(i-1),:);
                        elseif n == length(track.Frames)
                            stateTrack.(feels{f}) = track.(feels{f})(:,newFrame:(i-1));
                        else
                            stateTrack.(feels{f}) = track.(feels{f});
                        end
                    end
                    try
                        stateTracks.(stateTypes{lastState}).(strains{s}) = [stateTracks.(stateTypes{lastState}).(strains{s}) stateTrack];
                    catch
                        stateTracks.(stateTypes{lastState}).(strains{s}) = stateTrack;
                    end
                    newFrame = i;
                    lastState = state;
                end
                                
            end
        end
    end
end

end