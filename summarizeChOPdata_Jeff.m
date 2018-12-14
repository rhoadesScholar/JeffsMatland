% Takes a folder, finds linkedTracks files within the embedded folders, 
% finds the animals that were within the ROI 
% at appropriate times and gives back data in matrix form, where each line
% is a single time that an animal was hit with the LED:

% column 1: track number (i.e. anim #);
% column 2: stimulus numb (e.g. 5th of out of 6 stim)
% column 3: NaN
% column 4: NaN
% columns 5-1624: speed starting at t = -2min

% Editted by J Rhoades Nov 2017


function [allResults, allTracks] = summarizeChOPdata_Jeff(folder,stimulusfile,stimtoIncl, buffer, span, strains)%buffer in seconds, span in minutes    
    %%%%Pool together linkedTracks files in target folder

    PathofFolder = sprintf('%s',folder);
    dirList = dir(PathofFolder);
    dirList = {dirList([dirList(:).isdir]).name};
    dirList = dirList(ismember(dirList, strains));
    
    allTracks = struct();
    for t = 1:length(dirList)
        strain = deblank(dirList{t}); 
        allTracks.(strain) = [];
        PathName = sprintf('%s/%s/',PathofFolder,strain);
        fileList = ls(PathName);
        numFiles = length(fileList(:,1));

        for j = 3:numFiles
            fileName = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext] = fileparts(fileName);
            [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);

            if(strcmp(ext2,'.linkedTracks')==1)                
                fileToOpen = sprintf('%s%s',PathName,fileName);
                display(fileToOpen)
                load(fileToOpen);
                allTracks.(strain) = [allTracks.(strain) linkedTracks];
            end
        end        
    end
    %allTracks = removeRingReversals(allTracks);

    %Which Stimuli are we including?
    stimulus = load(stimulusfile);

    if(stimtoIncl==0)
        stimtoIncl = 1:length(stimulus(:,1));
    end

    %%%%%%find relevant tracks and annotate stimulusvector field

    allChOPfinalTracks = identifyChOPTracks_Jeff(allTracks,stimulusfile,stimtoIncl, buffer);   

    %%%%Gather relevant data vectors from ChOPfinalTracks
%     lengthofStimFrames = ((stimulus(stimtoIncl(1),2)-stimulus(stimtoIncl(1),1)) * 3);

    strains = fields(allChOPfinalTracks);
    for strn= 1:length(strains)
        index1 = 1;
        ChOPfinalTracks = allChOPfinalTracks.(strains{strn});
        for t=1:length(ChOPfinalTracks)
            theseStims = unique(ChOPfinalTracks(t).stimulus_vector);
            theseStims = theseStims(theseStims > 0);
            for s=theseStims
                %%Go back in time buffer frames, and then forward in time until
                %%just before next stim
                startpoint = stimulus(s,1) - buffer;
                startFrame = startpoint*ChOPfinalTracks(t).FrameRate;
                spanFrames = span*60*ChOPfinalTracks(t).FrameRate;
                
                startIndex = find(ChOPfinalTracks(t).Frames ==startFrame);
                stopIndex = startIndex + spanFrames -1;%find(ChOPfinalTracks(t).Frames==stopFrame);
                if stopIndex > length(ChOPfinalTracks(t).Frames)
                    stopIndex = length(ChOPfinalTracks(t).Frames);
                end

                if(startIndex>0) && (stopIndex <= length(ChOPfinalTracks(t).Frames))
                    %Then we have the data, so put it into AllChOPHits
                    allChOPHits(index1,1) = t;
                    allChOPHits(index1,2) = s;

                    %Find Speed and AngSpeed, put into AllChOPHits Matrix
                    Speed = ChOPfinalTracks(t).Speed(startIndex:stopIndex);
                    %AngSpeed = abs(ChOPfinalTracks(i).AngSpeed(StartIndex:StopIndex));  
                    allChOPHits(index1,3:4) = NaN;
                    allChOPHits(index1,5:4+length(Speed)) = Speed(1:end);

                    index1 = index1+1;
                end
            end
        end
        allResults.(strains{strn}) = allChOPHits;
        clear allChOPHits
    end

 %   subplot(3,1,1)
  %  plot(nanmean(AllChOPHits(:,5:814)))    
  %  subplot(3,1,2)
  %  plot(nanmean(AllChOPHits(:,815:1624)))
 %   subplot(3,1,3)
%    plot(nanmean(AllChOPHits(:,1625:1679)))
    
end



            

    

    