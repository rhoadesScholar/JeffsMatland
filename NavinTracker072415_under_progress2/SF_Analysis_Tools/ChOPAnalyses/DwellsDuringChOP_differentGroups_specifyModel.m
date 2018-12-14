function [ChOPDetails ConDetails estTR estE] = DwellsDuringChOP_differentGroups_specifyModel(folder,startStim,stopStim,estTR,estE)

    PathofFolder = sprintf('%s',folder);
    
    dirList = ls(PathofFolder);
    
    NumFolders = length(dirList(:,1));
    allTracks = [];
    for(i = 3:NumFolders)
        string1 = deblank(dirList(i,:)); 
        
        PathName = sprintf('%s/%s/',PathofFolder,string1);
        fileList = ls(PathName);
       
        numFiles = length(fileList(:,1));
       
        for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext] = fileparts(string2);
            [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);
           
            if(strcmp(ext2,'.linkedTracks')==1)
                fileIndex = j;
            end
        end
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        allTracks = [allTracks linkedTracks];
    end
    
    finalTracks = [];
    finalTracks = allTracks;
    
    ChopDetailIndex = 1;
    ConDetailIndex = 1;
    ChOPDetails = [];
    ConDetails = [];
    
    [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(finalTracks,30,estTR,estE);
    %[expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30);
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);
    
   
    startStim = startStim*3;
    stopStim = stopStim*3;
    
    ChOPDwellStateDurations = [];
    ControlDwellStateDurations = [];
    
    %%%%%Start with include ends - then toss out first and last rows
    for(j=1:length(stateDurationMaster))
        startTime = finalTracks(j).Frames(1);
        for(i=1:length(stateDurationMaster(j).stateCalls(:,1)))
            %display(stateDurationMaster(j).stateCalls)
            stopTime = startTime + (stateDurationMaster(j).stateCalls(i,2)*3);
            stateDurationMaster(j).stateCalls(i,3) = startTime; % adjust for startFrame, and seconds to Frames
            stateDurationMaster(j).stateCalls(i,4) = stopTime;
            startTime = stopTime;
            
        end
        %display(stateDurationMaster(j).stateCalls)
        %display(finalTracks(j).Frames(end));
        
        for(i=1:((length(stateDurationMaster(j).stateCalls(:,1)))-1))  
            if(stateDurationMaster(j).stateCalls(i,1)==1)
                
                DwellFrames = round(stateDurationMaster(j).stateCalls(i,3):1:stateDurationMaster(j).stateCalls(i,4));
                
                ChOPFrames = startStim:1:stopStim;
                
                StimDuration_Frames = length(ChOPFrames);
                
                checkforoverlap = intersect(DwellFrames,ChOPFrames);
                
                if(length(checkforoverlap>12))
                    if(stateDurationMaster(j).stateCalls(i,3)>(startStim-40))
                    if(stateDurationMaster(j).stateCalls(i,3)<(startStim+StimDuration_Frames))
                        if(stateDurationMaster(j).stateCalls(i,4)<stopStim+5400)
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(i==1)
                                TimeBefore = NaN;
                                stopStimHere = NaN;
                            else
                                TimeBefore = startStim-beginState;
                                stopStimHere = stopStim;
                            end
                           
                            TimeAfter = stopState-startStim;
                    ChOPDwellStateDurations = [ChOPDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    ChOPDetails(ChopDetailIndex,1:2) = [TimeBefore stopStimHere];
                    ChOPDetails(ChopDetailIndex,3:4) = [beginState stopState];
                    ChOPDetails(ChopDetailIndex,5:6) = [stateDurationMaster(j).stateCalls(1,3) stateDurationMaster(j).stateCalls(end,4)];
                    ChopDetailIndex = ChopDetailIndex +1;
                        end
                    end
                    end
                    
                else
                    simulStartStim = 9600;
                    simulStartStim2 = 10000;
                    simulStopStim = 9600+StimDuration_Frames-1;
                    simulStopStim2 = 10000+StimDuration_Frames-1;
                    
                    %if(finalTracks(j).Frames(1)>stopStim)
                    %if((stateDurationMaster(j).stateCalls(i,3)>1 && stateDurationMaster(j).stateCalls(i,4)<7890 && stateDurationMaster(j).stateCalls(i,3)<990 && stateDurationMaster(j).stateCalls(i,4)>990)||(stateDurationMaster(j).stateCalls(i,3)>990 && stateDurationMaster(j).stateCalls(i,4)<8880 && stateDurationMaster(j).stateCalls(i,3)<1980 && stateDurationMaster(j).stateCalls(i,4)>1980))%0 or 1
                    if((stateDurationMaster(j).stateCalls(i,3)>(simulStartStim-40) && stateDurationMaster(j).stateCalls(i,3)<simulStopStim && stateDurationMaster(j).stateCalls(i,4)<(simulStopStim+5400))||(stateDurationMaster(j).stateCalls(i,3)>(simulStartStim2-40) && stateDurationMaster(j).stateCalls(i,3)<simulStopStim2 && stateDurationMaster(j).stateCalls(i,4)<(simulStopStim2+5400)))%0 or 1
                        %if((stateDurationMaster(j).stateCalls(i,4)<6840))
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(stateDurationMaster(j).stateCalls(i,3)<simulStopStim)
                                simulStart = simulStartStim;
                                simulStop = simulStopStim;
                            
                            else
                                simulStart = simulStartStim2;
                                simulStop = simulStopStim2; 
                            end
                            if(i==1)
                                TimeBefore = NaN;
                                simulStop = NaN;
                            else
                            TimeBefore = simulStart-beginState;
                            end
                            TimeAfter = stopState-simulStart;
                       
                    ControlDwellStateDurations = [ControlDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    %ConDetails(ConDetailIndex,1:2) = [TimeBefore TimeAfter];
                    ConDetails(ConDetailIndex,1:2) = [TimeBefore simulStop];
                    ConDetails(ConDetailIndex,3:4) = [beginState stopState];
                    
                    ConDetailIndex = ConDetailIndex+1;
                        %end
                 
                    end
                end
                
            end
            
        end
    end
   
end



