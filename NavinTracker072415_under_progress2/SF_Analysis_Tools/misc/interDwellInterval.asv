function [interDwellIntervals interRoamIntervals AvgDwellSpeed AvgDwellAngSpeed AvgRoamSpeed AvgRoamAngSpeed allDataRafterD allDataDafterR AvgDwellSpeedError orderRandD] = interDwellInterval(finalTracks)
[expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30);
%[expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(finalTracks,30,estTR,estE)
[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurations_HMM(expNewSeq,0.333)
interDwellIntervals = [];
interRoamIntervals = [];

allSpeedData_Dw = [];
allAngSpeedData_Dw = [];
allSpeedData_Ro = [];
allAngSpeedData_Ro =[];

index8 = 1;
index9 = 1;

for (i=1:length(finalTracks))
   allDwellbins = find(expNewSeq(i).states==1);
   firstDwellbin = min(allDwellbins);
   roamingflag=0;
   roamdur = 0;
   dwelldur = 0;
   columnindex = 1;
   for (b=(firstDwellbin+1):length(expNewSeq(i).states))
       if(roamingflag==1)
           if(expNewSeq(i).states(b)==1)
               interDwellIntervals = [interDwellIntervals roamdur];
               OrderRandD(i,columnindex) = roamdur;
               columnindex = columnindex+1;
               dwelldur=1;
               roamdur = 0;
               roamingflag = 0;
           else
               roamdur= roamdur+1;
               
           end
       else
           if(expNewSeq(i).states(b)==1)
               dwelldur = dwelldur+1;
           else
               interRoamIntervals = [interRoamIntervals dwelldur];
               OrderRandD(i,columnindex) = dwelldur;
               columnindex = columnindex+1;
               dwelldur = 0;
               roamdur=1;
               roamingflag =1;
           end
       end
   end
   
   %%%%%%Find avg speed and ang speed during r/d
   allDwellBins = [];
   allRoamBins =[];
   allDwellBins = find(expNewSeq(i).states==1);
   allRoamBins = find(expNewSeq(i).states==2);
   allSpeedData_Dw = [allSpeedData_Dw nanmean(finalTracks(i).Speed(allDwellBins))];
   allAngSpeedData_Dw = [allAngSpeedData_Dw nanmean(abs(finalTracks(i).AngSpeed(allDwellBins)))];
   allSpeedData_Ro = [allSpeedData_Ro nanmean(finalTracks(i).Speed(allRoamBins))];
   allAngSpeedData_Ro = [allAngSpeedData_Ro nanmean(abs(finalTracks(i).AngSpeed(allRoamBins)))];
   display(i)
   %%%%%Get Structure of R/D Bins
   d = size(stateDurationMaster(i).stateCalls)
   if(d(1)>2)
   numbertodo = length(stateDurationMaster(i).stateCalls(:,1))-1;
   for (m=1:numbertodo)
       display(i)
       display(m)
       display(numbertodo)
       display(stateDurationMaster(i).stateCalls)
       if (stateDurationMaster(i).stateCalls(m,1)==1)
           %%%Then it is a dwell
           allDataRafterD(index8,1) = stateDurationMaster(i).stateCalls(m,2);
           allDataRafterD(index8,2) = stateDurationMaster(i).stateCalls(m+1,2);
           index8 = index8+1;
       else
           %%%%Then it is a roam
           allDataDafterR(index9,1) = stateDurationMaster(i).stateCalls(m,2);
           allDataDafterR(index9,2) = stateDurationMaster(i).stateCalls(m+1,2);
           index9 = index9+1;
       end
   end
   end
   
   
end
AvgDwellSpeed = nanmean(allSpeedData_Dw);
AvgDwellSpeedError = std(allSpeedData_Dw);
AvgDwellAngSpeed = nanmean(abs(allAngSpeedData_Dw));
AvgRoamSpeed = nanmean(allSpeedData_Ro);
AvgRoamAngSpeed = nanmean(abs(allAngSpeedData_Ro));
end
