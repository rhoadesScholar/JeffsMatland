function [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(finalTracks,binSize,trans,emis)
%function [estTR estE] = getHMMStates(finalTracks,binSize, trans,emis)
    statemap = getStateAuto(finalTracks,binSize);

        statesHMM = [];
    
    TracksToIgnoreForModel = [];
    
    for (i=1:length(finalTracks)) % clean up first couple entries
        display(i)
        newseq(i).states = statemap(i).state(2:(length(statemap(i).state)));
        if(~isnan(statemap(i).state(2)))
        else
            display('changing')
            display(newseq(i).states(1:10))
            indexhere = isnan(newseq(i).states);
            replace = find(indexhere==1);
            if(max(replace)==length(newseq(i).states)) % all entries are NaN
                TracksToIgnoreForModel = [TracksToIgnoreForModel i];
            else
            changeto = newseq(i).states(max(replace)+1);
            newseq(i).states(replace) = changeto;
            display(newseq(i).states(1:10))
            end
        end
    end
    newseq_model = newseq;
    newseq_model(TracksToIgnoreForModel) = [];
    seqs = struct2cell(newseq_model);
    
    %%% FOR TWO STATE MODEL
    %trans = [0.995, 0.005; 0.07, 0.93];
    %emis = [0.96, 0.04; 0.07, 0.93];
    
    %%%  FOR ONE STATE MODEL
    %trans = 1;
    %emis = [0.8, 0.2];
   
    
    %%% FOR THREE STATE MODEL
    %trans = [0.98 0.01 0.01; 0.33 0.33 0.33; 0.03 0.03 0.96];
    %emis = [0.96, 0.04; 0.5 0.5; 0.07, 0.93];
    
    
    estTR = trans;
    estE = emis;
    
    
    %%%%Apply Viterbi algorithm
    for (i= 1:length(finalTracks))
        numNans =sum(isnan(newseq(i).states))
        lengthSeq = length(newseq(i).states)
        if(numNans==lengthSeq) %all NaN - viterbi won't work
            statesHMM(i).states(1:lengthSeq) = NaN;
        else
        statesHMM(i).states = hmmviterbi(newseq(i).states,estTR,estE);
        end
    end
      
    %%%Create expStates structure - most probably state path by HMM
    %%%Re-normalize to track length, given binSize
    for(i= 1:length(finalTracks))
        speedData = finalTracks(i).Speed;
        numbBins = (length(speedData))/binSize;
        numbBins = floor(numbBins);
        expStates(i).states(1:(binSize)) = statesHMM(i).states(1);
        for (j = 2:numbBins)
        startPl = (j * binSize) - (binSize-1);
        stopPl  = (j * binSize);
        expStates(i).states(startPl:stopPl) = statesHMM(i).states(j-1);
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
   
    %%%Create expNewSeq structure - just the binary data from 2D scatter
    for(i= 1:length(finalTracks))
        speedData = finalTracks(i).Speed;
        numbBins = (length(speedData))/binSize;
        numbBins = floor(numbBins);
        expNewSeq(i).states(1:(binSize)) = newseq(i).states(1);
        for (j = 2:numbBins)
        startPl = (j * binSize) - (binSize-1);
        stopPl  = (j * binSize);
        expNewSeq(i).states(startPl:stopPl) = newseq(i).states(j-1);
        end
    end
end
