function [ChOPDetails ConDetails estTR estE] = RoamsDuringChOP(folder,stimFile)
    
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





    stimulus = load(stimFile);
   
    ChopDetailIndex = 1;
    ConDetailIndex = 1;
    ChOPDetails = [];
    ConDetails = [];
    [expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30);
    [stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);
    
   
    ChOPRoamStateDurations = [];
    ControlRoamStateDurations = [];
    
    
    startStim = stimulus([1,3,5,7,9,11],1);
    startStim = startStim*3;
    
    stopStim = stimulus([1,3,5,7,9,11],2);
    stopStim = stopStim*3;
    
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
            
            if(stateDurationMaster(j).stateCalls(i,1)==2)
                
                %RoamFrames = round(stateDurationMaster(j).stateCalls(i,3):1:stateDurationMaster(j).stateCalls(i,4));
                
                %ChOPFrames = startStim:1:stopStim;
               
                %checkforoverlap = intersect(RoamFrames,ChOPFrames);
                
                %if(length(checkforoverlap>12))
                    if((stateDurationMaster(j).stateCalls(i,3)>(startStim(1)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(1) && stateDurationMaster(j).stateCalls(i,4)<(startStim(1)+1400))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(2)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(2) && stateDurationMaster(j).stateCalls(i,4)<(startStim(2)+1400))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(3)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(3) && stateDurationMaster(j).stateCalls(i,4)<(startStim(3)+1400))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(4)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(4) && stateDurationMaster(j).stateCalls(i,4)<(startStim(4)+1400))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(5)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(5) && stateDurationMaster(j).stateCalls(i,4)<(startStim(5)+1400))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(6)-40) && stateDurationMaster(j).stateCalls(i,3)<stopStim(6) && stateDurationMaster(j).stateCalls(i,4)<(startStim(6)+1400)))
                    %if(stateDurationMaster(j).stateCalls(i,3)<stopStim)
                        %if(stateDurationMaster(j).stateCalls(i,4)<14100)
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(i==1)
                                stopStimHere = NaN;
                            elseif(beginState<3300)
                                stopStimHere = 2880;
                            elseif(beginState<6000)
                                stopStimHere = 5940;
                            elseif(beginState<10000)
                                stopStimHere = 9000;
                            elseif(beginState<13000)
                                stopStimHere = 12060;
                            elseif(beginState<16000)
                                stopStimHere = 15120;
                            elseif(beginState<19000)
                                stopStimHere = 18180;
                            end
                            TimeAfter = stopState-startStim;
                    ChOPRoamStateDurations = [ChOPRoamStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    ChOPDetails(ChopDetailIndex,1:2) = [1 stopStimHere];
                    ChOPDetails(ChopDetailIndex,3:4) = [beginState stopState];
                    ChopDetailIndex = ChopDetailIndex+1;
                    
                        %end
                    %end
                    end
                    
                %else
                    %if(finalTracks(j).Frames(1)>stopStim)
                    %if((stateDurationMaster(j).stateCalls(i,3)>1 && stateDurationMaster(j).stateCalls(i,4)<7890 && stateDurationMaster(j).stateCalls(i,3)<990 && stateDurationMaster(j).stateCalls(i,4)>990)||(stateDurationMaster(j).stateCalls(i,3)>990 && stateDurationMaster(j).stateCalls(i,4)<8880 && stateDurationMaster(j).stateCalls(i,3)<1980 && stateDurationMaster(j).stateCalls(i,4)>1980))%0 or 1
                    if((stateDurationMaster(j).stateCalls(i,3)>(startStim(1)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(1)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(1)+2480))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(2)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(2)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(2)+2480))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(3)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(3)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(3)+2480))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(4)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(4)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(4)+2480))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(5)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(5)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(5)+2480))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(6)+1040) && stateDurationMaster(j).stateCalls(i,3)<(startStim(6)+1260) && stateDurationMaster(j).stateCalls(i,4)<(startStim(6)+2480))||...
                                      (stateDurationMaster(j).stateCalls(i,3)>(startStim(1)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(1)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(1)+2700))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(2)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(2)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(2)+2700))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(3)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(3)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(3)+2700))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(4)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(4)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(4)+2700))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(5)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(5)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(5)+2700))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(6)+1260) && stateDurationMaster(j).stateCalls(i,3)<(startStim(6)+1480) && stateDurationMaster(j).stateCalls(i,4)<(startStim(6)+2700))||...
                                      (stateDurationMaster(j).stateCalls(i,3)>(startStim(1)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(1)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(1)+2920))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(2)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(2)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(2)+2920))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(3)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(3)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(3)+2920))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(4)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(4)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(4)+2920))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(5)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(5)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(5)+2920))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(6)+1480) && stateDurationMaster(j).stateCalls(i,3)<(startStim(6)+1700) && stateDurationMaster(j).stateCalls(i,4)<(startStim(6)+2920)))%||...
                                      %(stateDurationMaster(j).stateCalls(i,3)>(startStim(1)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(1)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(1)+2260))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(2)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(2)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(2)+2260))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(3)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(3)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(3)+2260))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(4)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(4)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(4)+2260))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(5)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(5)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(5)+2260))||(stateDurationMaster(j).stateCalls(i,3)>(startStim(6)+820) && stateDurationMaster(j).stateCalls(i,3)<(startStim(6)+1040) && stateDurationMaster(j).stateCalls(i,4)<(startStim(6)+2260)))
                        
                        %if((stateDurationMaster(j).stateCalls(i,4)<6840))
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(i==1)
                                stopStimHere = NaN;
                            %elseif(beginState<(startStim(1)+1040))
                           %    stopStimHere = startStim(1)+1040;
                            elseif(beginState<(startStim(1)+1260))
                                stopStimHere = startStim(1)+1260;
                            elseif(beginState<(startStim(1)+1480))
                                stopStimHere = startStim(1)+1480;
                            elseif(beginState<(startStim(1)+1700))
                                stopStimHere = startStim(1)+1700; 
                                
                            %elseif(beginState<(startStim(2)+1040))
                            %    stopStimHere = startStim(2)+1040;
                            elseif(beginState<(startStim(2)+1260))
                                stopStimHere = startStim(2)+1260;
                            elseif(beginState<(startStim(2)+1480))
                                stopStimHere = startStim(2)+1480;
                            elseif(beginState<(startStim(2)+1700))
                                stopStimHere = startStim(2)+1700;
                                
                            %elseif(beginState<(startStim(3)+1040))
                            %   stopStimHere = startStim(3)+1040;
                            elseif(beginState<(startStim(3)+1260))
                                stopStimHere = startStim(3)+1260;
                            elseif(beginState<(startStim(3)+1480))
                                stopStimHere = startStim(3)+1480;
                            elseif(beginState<(startStim(3)+1700))
                                stopStimHere = startStim(3)+1700;    
                                
                            %elseif(beginState<(startStim(4)+1040))
                            %    stopStimHere = startStim(4)+1040;
                            elseif(beginState<(startStim(4)+1260))
                                stopStimHere = startStim(4)+1260;
                            elseif(beginState<(startStim(4)+1480))
                                stopStimHere = startStim(4)+1480;
                            elseif(beginState<(startStim(4)+1700))
                                stopStimHere = startStim(4)+1700;
                                
                            %elseif(beginState<(startStim(5)+1040))
                            %    stopStimHere = startStim(5)+1040;
                            elseif(beginState<(startStim(5)+1260))
                                stopStimHere = startStim(5)+1260;
                            elseif(beginState<(startStim(5)+1480))
                                stopStimHere = startStim(5)+1480;
                            elseif(beginState<(startStim(5)+1700))
                                stopStimHere = startStim(5)+1700;
                                
                                
                            %elseif(beginState<(startStim(6)+1040))
                            %    stopStimHere = startStim(6)+1040;
                            elseif(beginState<(startStim(6)+1260))
                                stopStimHere = startStim(6)+1260;
                            elseif(beginState<(startStim(6)+1480))
                                stopStimHere = startStim(6)+1480;
                            elseif(beginState<(startStim(6)+1700))
                                stopStimHere = startStim(6)+1700;
                                
                            end
                            %TimeAfter = stopState-simulStart;
                    ControlRoamStateDurations = [ControlRoamStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    ConDetails(ConDetailIndex,1:2) = [1 stopStimHere];
                    ConDetails(ConDetailIndex,3:4) = [beginState stopState];
                    ConDetailIndex = ConDetailIndex+1;
                    
                        %end
                 
                    end
                %end
                
            end
        end
       
    end
    
    
   
end

        