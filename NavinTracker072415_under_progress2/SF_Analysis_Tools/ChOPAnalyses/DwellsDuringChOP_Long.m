function [ChOPDwellStateDurations ControlDwellStateDurations ChOPDetails ConDetails estTR estE] = DwellsDuringChOP_Long(finalTracks,startStim,stopStim)
    ChopDetailIndex = 1;
    ConDetailIndex = 1;
    ChOPDetails = [];
    ConDetails = [];
    [expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30);
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
               
                checkforoverlap = intersect(DwellFrames,ChOPFrames);
                
                if(length(checkforoverlap>12))
                    if(stateDurationMaster(j).stateCalls(i,3)<6210)
                    if(stateDurationMaster(j).stateCalls(i,3)>3600)
                        if(stateDurationMaster(j).stateCalls(i,4)<10800)
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(i==1)
                                TimeBefore = NaN;
                            else
                                TimeBefore = startStim-beginState;
                            end
                            TimeAfter = stopState-startStim;
                    ChOPDwellStateDurations = [ChOPDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    ChOPDetails(ChopDetailIndex,1:2) = [TimeBefore TimeAfter];
                    ChOPDetails(ChopDetailIndex,3:4) = [beginState stopState];
                    ChopDetailIndex = ChopDetailIndex +1;
                        end
                    end
                    end
                    
                else
                    %if(finalTracks(j).Frames(1)>stopStim)
                    if((stateDurationMaster(j).stateCalls(i,3)>1 && stateDurationMaster(j).stateCalls(i,4)<7200 && stateDurationMaster(j).stateCalls(i,3)<2610 && stateDurationMaster(j).stateCalls(i,4)>3600))%0 or 1
                    
                        %if((stateDurationMaster(j).stateCalls(i,4)<6840))
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            simulStart = 3600;
                          
                            
                            if(i==1)
                                TimeBefore=NaN;
                            else
                            TimeBefore = simulStart-beginState;
                            end
                            TimeAfter = stopState-simulStart;
                    ControlDwellStateDurations = [ControlDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    ConDetails(ConDetailIndex,1:2) = [TimeBefore TimeAfter];
                    ConDetails(ConDetailIndex,3:4) = [beginState stopState];
                    ConDetailIndex = ConDetailIndex+1;
                        %end
                 
                    end
                end
                
            end
        end
    end
   
end

        