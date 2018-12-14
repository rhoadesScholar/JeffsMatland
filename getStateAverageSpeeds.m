function [dwellSpeeds, dwellAngSpeeds, roamSpeeds, roamAngSpeeds] = getStateAverageSpeeds(finalTracks)
%[N2expNewSeq N2expStates N2estTR N2estE] = getHMMStates(allFinalTracks.N2,30)
%[CX16814expNewSeq CX16814expStates CX16814estTR CX16814estE] = getHMMStatesSpecifyTRandE_2(allFinalTracks.CX16814,30,N2estTR,N2estE)    
%for (i=1:length(allFinalTracks.CX16814)) allFinalTracks.CX16814(i).HMMstates=CX16814expStates(i).states; end

    d = 1;
    r = 1;
    for (i=1:length(finalTracks))
        for (j=1:length(finalTracks(i).HMMstates))
            if (finalTracks(i).HMMstates(j)==1)
                dwellSpeeds(d)= finalTracks(i).Speed(j);
                dwellAngSpeeds(d)= finalTracks(i).AngSpeed(j);
                d=d+1;
            end
            if (finalTracks(i).HMMstates(j)==2)
                roamSpeeds(r)= finalTracks(i).Speed(j);
                roamAngSpeeds(r)= finalTracks(i).AngSpeed(j);
                r=r+1;
            end
        end
    end
    
    
%     dwellSpeeds = struct('dwellSpeeds', dwellSpeeds, 'avgDwellSpeed',
%                 nanmean(dwellSpeeds), stdDwellSpeedsnanstd(dwellSpeeds)]; %avg, stdev
%     dwellAvgAngSpeed = [nanmean(abs(dwellAngSpeeds)) nanstd(abs(dwellAngSpeeds))]; %avg, stdev
%     roamAvgSpeed = [nanmean(roamSpeeds) nanstd(roamSpeeds)]; %avg, stdev
%     roamAvgAngSpeed = [nanmean(abs(roamAngSpeeds)) nanstd(abs(roamAngSpeeds))]; %avg, stdev