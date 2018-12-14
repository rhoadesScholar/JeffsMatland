%%%%%%%%%%%% Function to identify animals that were in the stimulus range @
%%%%%%%%%%%% the time that ChOP light was illuminated.  Input is a
%%%%%%%%%%%% finalTracks file and output is: (1) a ChOPfinalTracks file (2)
%%%%%%%%%%%% visual display of all appropriate tracks, including state
%%%%%%%%%%%% calls and shading where ChOP was active


function ChOPfinalTracks = identifyChOPTracks_Copper(finalTracks,stimulusfile,plotthis,C128SFlag,stimtoIncl)

    %coordsOfInterest = getROIforCHOP(ROImovie);
    stimulus = load(stimulusfile);
    TracksInStim = [];
    TrackInclusionIndex = 1;
    
    for(i=stimtoIncl)
    if((C128SFlag==1) && (stimulus(i,3)==1))
    
    else
            
            
        
    startpoint = stimulus(i,1);
    stoppoint = stimulus(i,2);
    startpointFrame = startpoint*finalTracks(1).FrameRate;
    stoppointFrame = stoppoint*finalTracks(1).FrameRate;
    if (C128SFlag==1)
        startpoint2 = stimulus(i-1,1);
        stoppoint2 = stimulus(i-1,2);
        startpointFrame2 = startpoint*finalTracks(1).FrameRate;
        stoppointFrame2 = stoppoint*finalTracks(1).FrameRate; 
    end
    for(j=1:length(finalTracks))
        
        startIndex = find(finalTracks(j).Frames==startpointFrame);
        stopIndex = find(finalTracks(j).Frames==stoppointFrame);
        check = length(startIndex) + length(stopIndex);
        if(check==2)
           %TrackPath = floor(finalTracks(j).Path(startIndex:stopIndex,:));
           %index = 1;
           %FramesInROI = [];
%            for(k=1:length(TrackPath(:,1)))
%                xrow = coordsOfInterest(:,1);
%                yrow = coordsOfInterest(:,2);
%                xrowTrackPath = TrackPath(k,1);
%                yrowTrackPath = TrackPath(k,2);
%                xindex = find(xrow==xrowTrackPath);
%                correctrows = [];
%                 if(length(xindex)>0)
%                correctrows = find(yrow(xindex)==yrowTrackPath);
%                 end
%                 if(length(correctrows)>0)
%                     FramesInROI(index) = k;
%                     index= index+1;
%                 end
%            end
           %if(length(FramesInROI)>15)
               %if(C128SFlag==1)
                   %%Check if animal was in blue light
%                     startIndex2 = find(finalTracks(j).Frames==startpointFrame2);
%                     stopIndex2 = find(finalTracks(j).Frames==stoppointFrame2);
%                     check2 = length(startIndex) + length(stopIndex);
%                     if(check2==2)
%                        TrackPath2 = floor(finalTracks(j).Path(startIndex2:stopIndex2,:));
%                        index2 = 1;
%                        FramesInROI_2 = [];
%                        for(v=1:length(TrackPath2(:,1)))
%                            xrow2 = coordsOfInterest(:,1);
%                            yrow2 = coordsOfInterest(:,2);
%                            xrowTrackPath2 = TrackPath2(v,1);
%                            yrowTrackPath2 = TrackPath2(v,2);
%                            xindex2 = find(xrow2==xrowTrackPath2);
%                            correctrows2 = [];
%                             if(length(xindex2)>0)
%                            correctrows2 = find(yrow2(xindex2)==yrowTrackPath2);
%                             end
%                             if(length(correctrows2)>0)
%                                 FramesInROI_2(index) = v;
%                                 index2= index2+1;
%                             end
%                        end
%                     end
                   
                   
                   
               %if(length(FramesInROI_2)>15)
                   
                   TracksInStim(TrackInclusionIndex,1:2) = [i, j];
                   TrackInclusionIndex = TrackInclusionIndex +1;
               %end
%                else
%                    TracksInStim(TrackInclusionIndex,1:2) = [i, j];
%                    TrackInclusionIndex = TrackInclusionIndex +1;
%                end
           %end
        end
    end
    end
    end
    

    %%%%%%%%%%  Add field to ChOPfinalTracks that says which timeframe it
    %%%%%%%%%%  was in right place, then work on visualization of data
               
for (i=1:length(TracksInStim(:,1)))
    currentStim = TracksInStim(i,1);
    FirstFrame = finalTracks(TracksInStim(i,2)).Frames(1);
    if(C128SFlag==1)
        
        if((((stimulus((currentStim-1),1)*3)-FirstFrame+1))<1)
        else
        finalTracks(TracksInStim(i,2)).stimulus_vector(((stimulus((currentStim-1),1)*3)-FirstFrame+1):((stimulus((currentStim-1),2)*3)-FirstFrame)) = 1;
        finalTracks(TracksInStim(i,2)).stimulus_vector(((stimulus(currentStim,1)*3)-FirstFrame+1):((stimulus(currentStim,2)*3)-FirstFrame)) = 2; 
        end
    else
    finalTracks(TracksInStim(i,2)).stimulus_vector(((stimulus(currentStim,1)*3)-FirstFrame+1):((stimulus(currentStim,2)*3)-FirstFrame)) = 1;    
    end
        
end

ChOPTrackIndices = unique(TracksInStim(:,2));

ChOPfinalTracks = finalTracks(ChOPTrackIndices);

if(plotthis==1)
showMultiTrackChOPHMMStateCalls(finalTracks,ChOPTrackIndices,30,TracksInStim,stimulus,C128SFlag)
end
end



         