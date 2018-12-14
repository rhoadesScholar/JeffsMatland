function [ChOPDwellStateDurations ControlDwellStateDurations ChOPDetails ConDetails estTR estE] = DwellsDuringChOP(finalTracks,startStim,stopStim)
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
                    if(stateDurationMaster(j).stateCalls(i,3)>(startStim-60))
                    if(stateDurationMaster(j).stateCalls(i,3)<(startStim+360))
                        if(stateDurationMaster(j).stateCalls(i,4)<13660)
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
                    %if((stateDurationMaster(j).stateCalls(i,3)>1 && stateDurationMaster(j).stateCalls(i,4)<7890 && stateDurationMaster(j).stateCalls(i,3)<990 && stateDurationMaster(j).stateCalls(i,4)>990)||(stateDurationMaster(j).stateCalls(i,3)>990 && stateDurationMaster(j).stateCalls(i,4)<8880 && stateDurationMaster(j).stateCalls(i,3)<1980 && stateDurationMaster(j).stateCalls(i,4)>1980))%0 or 1
                    if((stateDurationMaster(j).stateCalls(i,3)>275 && stateDurationMaster(j).stateCalls(i,3)<660 && stateDurationMaster(j).stateCalls(i,4)<6760)||(stateDurationMaster(j).stateCalls(i,3)>660 && stateDurationMaster(j).stateCalls(i,3)<1045 && stateDurationMaster(j).stateCalls(i,4)<7145)||(stateDurationMaster(j).stateCalls(i,3)>7915 && stateDurationMaster(j).stateCalls(i,3)<8300 && stateDurationMaster(j).stateCalls(i,4)<14400))%0 or 1
                        %if((stateDurationMaster(j).stateCalls(i,4)<6840))
                            beginState = stateDurationMaster(j).stateCalls(i,3);
                            stopState = stateDurationMaster(j).stateCalls(i,4);
                            if(stateDurationMaster(j).stateCalls(i,3)<660)
                                simulStart = 990;
                                simulStopStim = 660;
                            %else
                            elseif(stateDurationMaster(j).stateCalls(i,3)<1050) % comment away if using on 2 windows
                                simulStart = 1980;
                                simulStopStim = 1045;
                            else % comment away if using on 2 windows
                                simulStopStim = 8300; % comment away if using on 2 windows
                            end
                            if(i==1)
                                TimeBefore=NaN;
                                simulStopStim = NaN;
                            else
                            TimeBefore = simulStart-beginState;
                            end
                            TimeAfter = stopState-simulStart;
                       
                    ControlDwellStateDurations = [ControlDwellStateDurations stateDurationMaster(j).stateCalls(i,2)];
                    %ConDetails(ConDetailIndex,1:2) = [TimeBefore TimeAfter];
                    ConDetails(ConDetailIndex,1:2) = [TimeBefore simulStopStim];
                    ConDetails(ConDetailIndex,3:4) = [beginState stopState];
                    
                    ConDetailIndex = ConDetailIndex+1;
                        %end
                 
                    end
                end
                
            end
            
        end
    end
   
end

        