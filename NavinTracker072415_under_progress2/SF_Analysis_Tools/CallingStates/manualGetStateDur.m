for (i=1:length(allTracks))
    [seq,states] = hmmgenerate(540,estTR,estE)
    FakeTracks(i).Seq = seq;
    FakeTracks(i).States = states;
end

   statesHMM = [];
    for (i=1:length(allTracks))
   
        newseq(i).states = FakeTracks(i).Seq(2:(length(FakeTracks(i).Seq)));
    end
    seqs = struct2cell(newseq)

for (i= 1:length(FakeTracks))
    
        FakeTracks(i).states = hmmviterbi(newseq(i).states,estTR,estE);
end
    
    for(i= 1:length(allTracks))
        speedData = allTracks(i).Speed;
        numbBins = (length(speedData))/binSize;
        numbBins = floor(numbBins);
        NewFakeTracks(i).states(1:binSize) = FakeTracks(i).states(1);
        for (j = 2:numbBins)
        startPl = (j * binSize) - (binSize-1);
        stopPl  = (j * binSize);
        NewFakeTracks(i).states(startPl:stopPl) = FakeTracks(i).states(j-1);
        end
%         numFrames = length(finalTracks(i).Frames);
%         leftOver_Frames = mod(numFrames,binSize);
%         if (leftOver_Frames>0)
%             currentExpStateLength = length(expStates(i).states);
%             newStart = currentExpStateLength+1;
%             newStop = newStart + (leftOver_Frames -4);
%             expStates(i).states(newStart:newStop) = statesHMM(i).states(end);
%         else
%             expStates(i).states = expStates(i).states(1:(numFrames-3));
%         end
        
    end
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations_HMM(NewFakeTracks,.333);
    
    
%     for (i=1:length(allTracks))
%     [seq,states] = hmmgenerate(539,estTR,estE)
%     FakeTracks(i).Seq = seq;
%     FakeTracks(i).States = states;
% end

for (i= 1:length(FakeTracks))
    
        FakeTracks(i).states = hmmviterbi(allTracks(i).Seq,estTR,estE);
end
    
    for(i= 1:length(allTracks))
        speedData = allTracks(i).Speed;
        numbBins = (length(speedData))/binSize;
        numbBins = floor(numbBins);
        NewFakeTracks(i).states(1:binSize) = FakeTracks(i).states(1);
        for (j = 2:numbBins)
        startPl = (j * binSize) - (binSize-1);
        stopPl  = (j * binSize);
        NewFakeTracks(i).states(startPl:stopPl) = FakeTracks(i).states(j-1);
        end
%         numFrames = length(finalTracks(i).Frames);
%         leftOver_Frames = mod(numFrames,binSize);
%         if (leftOver_Frames>0)
%             currentExpStateLength = length(expStates(i).states);
%             newStart = currentExpStateLength+1;
%             newStop = newStart + (leftOver_Frames -4);
%             expStates(i).states(newStart:newStop) = statesHMM(i).states(end);
%         else
%             expStates(i).states = expStates(i).states(1:(numFrames-3));
%         end
        
    end