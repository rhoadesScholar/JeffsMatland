%%%%%%%%%%%%%%find roaming periods less than 350s, greater than 350s
function [LongvShortInfo AllLongStates AllShortStates] = analyseLongvShort_forDw(finalTracks)
[expNewSeq expStates estTR estE] = getHMMStates(finalTracks,30)
[stateDurationMaster dwellStateDurations roamStateDurations] = getStateDurationsInclEnds_HMM(expStates,.333);

for (i=1:length(finalTracks))
    index1=1;
    index2=1;
    longStateInd = [];
    shortStateInd = [];
    currentStateLog = [];
    longDwellingStates = [];
    shortDwellingStates = [];
    currentStateLog = stateDurationMaster(i).stateCalls;
    firstState = currentStateLog(1,1);
    longStateInd = find(currentStateLog(:,2)>320);
    shortStateInd = find(currentStateLog(:,2)<=320);
    if (firstState==2)
        
        for(j=1:length(longStateInd))
            if (mod(longStateInd(j),2) == 0)
                if(longStateInd(j)>1)
                longDwellingStates(index1) = longStateInd(j);
                index1 = index1+1;
                end
            end
        end
        for(j=1:length(shortStateInd))
            if (mod(shortStateInd(j),2) == 0)
                if(shortStateInd(j)>1)
                shortDwellingStates(index2) = shortStateInd(j);
                index2 = index2+1;
                end
            end
        end
    else
        for(j=1:length(longStateInd))
            if (mod(longStateInd(j),2) == 0)
            else
                if(longStateInd(j)>1)
                longDwellingStates(index1) = longStateInd(j);
                index1 = index1+1;
                end
            end
        end
        for(j=1:length(shortStateInd))
            if (mod(shortStateInd(j),2) == 0)
            else
                if(shortStateInd(j)>1)
                shortDwellingStates(index2) = shortStateInd(j);
                index2 = index2+1;
                end
            end
        end
    end

    
 %%%%%%%%These give the relevant indices for each set of states
 LongvShortTab(i).shortDwellingStates = shortDwellingStates; 
 LongvShortTab(i).longDwellingStates = longDwellingStates;
end

 
 %%%%%%%Get approx State start and end for a given index
 
 
 
 index3 = 1;
 index4 = 1;
 for (i=1:length(LongvShortTab))
     
     for(j=1:length(LongvShortTab(i).longDwellingStates))
         stateInd = [];
         allStatesThusFar = [];
         GuessRegionStart = [];
         GuessRegionStop = [];
         stateInd = LongvShortTab(i).longDwellingStates(j);
         allStatesThusFar = stateDurationMaster(i).stateCalls(1:(stateInd-1),2);
         approxStart = floor((sum(allStatesThusFar) * 3)-10);
         approxStop = ceil(approxStart + (stateDurationMaster(i).stateCalls(stateInd,2) * 3) + 30);
         if(approxStop<(length(expStates(i).states)))
         GuessRegionStart = expStates(i).states(approxStart:approxStart+30);
         GuessRegionStop = expStates(i).states(approxStop-30:approxStop);
         numFramesBeforeStart = length(find(GuessRegionStart==2));
         numFramesAfterStop = length(find(GuessRegionStop==2));
         ActualStart = approxStart + numFramesBeforeStart;
         ActualStop = approxStop - numFramesAfterStop;
         AllLongStates(index4,1) = i;
         AllLongStates(index4,2) = ActualStart;
         AllLongStates(index4,3) = ActualStop;
         index4 = index4+1;
         end
     end
     for(j=1:length(LongvShortTab(i).shortDwellingStates))
         stateInd = [];
         allStatesThusFar = [];
         GuessRegionStart = [];
         GuessRegionStop = [];
         stateInd = LongvShortTab(i).shortDwellingStates(j);
         allStatesThusFar = stateDurationMaster(i).stateCalls(1:(stateInd-1),2);
         approxStart = floor((sum(allStatesThusFar) * 3)-10);
         approxStop = ceil(approxStart + (stateDurationMaster(i).stateCalls(stateInd,2) * 3) + 30);
         if(approxStop<(length(expStates(i).states)))
         GuessRegionStart = expStates(i).states(approxStart:approxStart+30);
         GuessRegionStop = expStates(i).states(approxStop-30:approxStop);
         numFramesBeforeStart = length(find(GuessRegionStart==2));
         numFramesAfterStop = length(find(GuessRegionStop==2));
         ActualStart = approxStart + numFramesBeforeStart;
         ActualStop = approxStop - numFramesAfterStop;
         AllShortStates(index3,1) = i;
         AllShortStates(index3,2) = ActualStart;
         AllShortStates(index3,3) = ActualStop;
         index3 = index3+1;
         end
     end
 end

 %%%%%%%%%For each of these categories, (1) compare % bins in 2 (vs. 1) (2)
 %%%%%%%%%compare the raw Speed, AngSpeed Numbs
 index5=1;
 index6=1;
 index7=1;
 index8=1;
 index9=1;
 index10=1;
 index11=1;
 index12=1;
 index13=1;
 index14=1;
 
 LongvShortInfo = struct('avgSpeedShort',[],'avgSpeedLong',[],'avgAngSpeedShort',[],'avgAngSpeedLong',[],'avgTimeInRoamStateShort',[],'avgTimeInRoamStateLong',[],'avgDwSpeedShort',[],'avgDwSpeedLong',[],'avgDwAngSpeedShort',[],'avgDwAngSpeedLong',[],'avgRoSpeedShort',[],'avgRoSpeedLong',[],'avgRoAngSpeedShort',[],'avgRoAngSpeedLong',[]);
rawSpeedDataShortAll = [];
rawAngSpDataShortAll = [];
rawDwSpeedDataShortAll = [];
rawDwAngSpeedDataShortAll = [];
rawRoSpeedDataShortAll = [];
rawRoAngSpeedDataShortAll = [];

MasterShortSpeedMatrix = [];
MasterShortAngSpeedMatrix = [];
MasterShortlRevSpeedMatrix= [];
MasterShortsRevSpeedMatrix= [];
MasterRoShortSpeedMatrix = [];
MasterRoShortAngSpeedMatrix = [];
MasterRoShortlRevSpeedMatrix= [];
MasterRoShortsRevSpeedMatrix= [];
MasterDwShortSpeedMatrix = [];
MasterDwShortAngSpeedMatrix = [];
MasterDwShortlRevSpeedMatrix= [];
MasterDwShortsRevSpeedMatrix= [];

MasterLongSpeedMatrix = [];
MasterLongAngSpeedMatrix = [];
MasterLonglRevSpeedMatrix= [];
MasterLongsRevSpeedMatrix= [];
MasterRoLongSpeedMatrix = [];
MasterRoLongAngSpeedMatrix = [];
MasterRoLonglRevSpeedMatrix= [];
MasterRoLongsRevSpeedMatrix= [];
MasterDwLongSpeedMatrix = [];
MasterDwLongAngSpeedMatrix = [];
MasterDwLonglRevSpeedMatrix= [];
MasterDwLongsRevSpeedMatrix= [];


 for(i=1:length(AllShortStates(:,1)))
     trackindex = AllShortStates(i,1);
     startFrame = AllShortStates(i,2);
     stopFrame = AllShortStates(i,3);
     rawStates = expNewSeq(trackindex).states(startFrame:stopFrame);
     totalFrames = length(rawStates);
     dwellFrames = length(find(rawStates==1));
     %%%%Get Fraction time in each states
     ratioTimeinDwellStateforShort(i) = dwellFrames/totalFrames;
     %%%%Get Speed, AngSpeed Data
     rawSpeedDataShortAll = [rawSpeedDataShortAll finalTracks(trackindex).Speed(startFrame:stopFrame)];
     rawAngSpDataShortAll = [rawAngSpDataShortAll abs(finalTracks(trackindex).AngSpeed(startFrame:stopFrame))];
     %%%%Get Speed, AngSpeed of Dwelling bins in these states
     roamIndices = find(rawStates==2);
     
     roamIndices = roamIndices+startFrame-1;
     rawRoSpeedDataShortAll = [rawRoSpeedDataShortAll finalTracks(trackindex).Speed(roamIndices)];
     rawRoAngSpeedDataShortAll = [rawRoAngSpeedDataShortAll abs(finalTracks(trackindex).AngSpeed(roamIndices))];
     index5=index5+1;
     
     %%%% Get Speed,AngSpeed of Roaming bins only 
     dwellIndices = find(rawStates==1);
     dwellIndices = dwellIndices+startFrame-1;
     rawDwSpeedDataShortAll = [rawDwSpeedDataShortAll (finalTracks(trackindex).Speed(dwellIndices))];
     rawDwAngSpeedDataShortAll = [rawDwAngSpeedDataShortAll (abs(finalTracks(trackindex).AngSpeed(dwellIndices)))];
     index7=index7+1;
     %%%%%Get RevInfo (Total, sRev, lRev) for entire states
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,[]);
     LongvShortInfo.ShortRevMatrix(index9,1:4) = [Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     index9 = index9+1;
     MasterShortSpeedMatrix = [MasterShortSpeedMatrix; SpeedMatrix];
     MasterShortAngSpeedMatrix = [MasterShortAngSpeedMatrix; AngSpeedMatrix];
     MasterShortlRevSpeedMatrix = [MasterShortlRevSpeedMatrix; lRevSpeedMatrix];
     MasterShortsRevSpeedMatrix = [MasterShortsRevSpeedMatrix; sRevSpeedMatrix];
     %%%%%%Get RevInfo for Roaming Bins
     dwellIndices = find(rawStates==1);
     
     
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] =CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,dwellIndices);
     LongvShortInfo.ShortRoBinsRevMatrix(index10,1:4) = [Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     index10 = index10+1;
     MasterRoShortSpeedMatrix = [MasterRoShortSpeedMatrix; SpeedMatrix];
     MasterRoShortAngSpeedMatrix = [MasterRoShortAngSpeedMatrix; AngSpeedMatrix];
     MasterRoShortlRevSpeedMatrix = [MasterRoShortlRevSpeedMatrix; lRevSpeedMatrix];
     MasterRoShortsRevSpeedMatrix = [MasterRoShortsRevSpeedMatrix; sRevSpeedMatrix];
     %%%Get RevInfo for Dwelling Bins
     roamIndices = find(rawStates==2);
     
      
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,roamIndices);
     LongvShortInfo.ShortDwBinsRevMatrix(index11,1:4) = [Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     index11 = index11+1;
     MasterDwShortSpeedMatrix = [MasterDwShortSpeedMatrix; SpeedMatrix];
     MasterDwShortAngSpeedMatrix = [MasterDwShortAngSpeedMatrix; AngSpeedMatrix];
     MasterDwShortlRevSpeedMatrix = [MasterDwShortlRevSpeedMatrix; lRevSpeedMatrix];
     MasterDwShortsRevSpeedMatrix = [MasterDwShortsRevSpeedMatrix; sRevSpeedMatrix];
 end
 
 rawSpeedDataLongAll = [];
 rawAngSpDataLongAll = [];
 rawDwSpeedDataLongAll = [];
 rawDwAngSpeedDataLongAll = [];
 rawRoSpeedDataLongAll = [];
 rawRoAngSpeedDataLongAll = [];
 
 for(i=1:length(AllLongStates(:,1)))
     trackindex = AllLongStates(i,1);
     startFrame = AllLongStates(i,2);
     stopFrame = AllLongStates(i,3);
     rawStates2 = expNewSeq(trackindex).states(startFrame:stopFrame);
     totalFrames2 = length(rawStates2);
     dwellFrames2 = length(find(rawStates2==1));
      %%%%Get Fraction time in each states
     ratioTimeinDwellStateforLong(i) = dwellFrames2/totalFrames2;
     %%%%Get Speed, AngSpeed Data
     rawSpeedDataLongAll = [rawSpeedDataLongAll (finalTracks(trackindex).Speed(startFrame:stopFrame))];
     rawAngSpDataLongAll = [rawAngSpDataLongAll (abs(finalTracks(trackindex).AngSpeed(startFrame:stopFrame)))];
     %%%%Get Speed, AngSpeed of Dwelling bins in these states
     dwellIndices = find(rawStates2==1);
     
     dwellIndices = dwellIndices+startFrame-1;
     rawDwSpeedDataLongAll = [rawDwSpeedDataLongAll (finalTracks(trackindex).Speed(dwellIndices))];
     rawDwAngSpeedDataLongAll = [rawDwAngSpeedDataLongAll (abs(finalTracks(trackindex).AngSpeed(dwellIndices)))];
     index6=index6+1;
     
     roamIndices = find(rawStates2==2);
     roamIndices = roamIndices+startFrame-1;
     rawRoSpeedDataLongAll = [rawRoSpeedDataLongAll (finalTracks(trackindex).Speed(roamIndices))];
     rawRoAngSpeedDataLongAll = [rawRoAngSpeedDataLongAll (abs(finalTracks(trackindex).AngSpeed(roamIndices)))];
     index8=index8+1;
     %%%%%Get RevInfo (Total, sRev, lRev) for entire states
     
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,[]);
     LongvShortInfo.LongRevMatrix(index12,1:4) =[Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     index12 = index12+1;
     MasterLongSpeedMatrix = [MasterLongSpeedMatrix; SpeedMatrix];
     MasterLongAngSpeedMatrix = [MasterLongAngSpeedMatrix; AngSpeedMatrix];
     MasterLonglRevSpeedMatrix = [MasterLonglRevSpeedMatrix; lRevSpeedMatrix];
     MasterLongsRevSpeedMatrix = [MasterLongsRevSpeedMatrix; sRevSpeedMatrix];
     %%%%%%Get RevInfo for RoamingBins
     dwellIndices = find(rawStates2==1);
     
     
         
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,dwellIndices);
     LongvShortInfo.LongRoBinsRevMatrix(index13,1:4) =[Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     index13 = index13+1;
     MasterRoLongSpeedMatrix = [MasterRoLongSpeedMatrix; SpeedMatrix];
     MasterRoLongAngSpeedMatrix = [MasterRoLongAngSpeedMatrix; AngSpeedMatrix];
     MasterRoLonglRevSpeedMatrix = [MasterRoLonglRevSpeedMatrix; lRevSpeedMatrix];
     MasterRoLongsRevSpeedMatrix = [MasterRoLongsRevSpeedMatrix; sRevSpeedMatrix];
     
     %%%Get RevInfo for Dwelling Bins
     roamIndices = find(rawStates2==2);
     
     [Num_total_revs Num_sRevs Num_lRevs Duration_of_State SpeedMatrix AngSpeedMatrix lRevSpeedMatrix sRevSpeedMatrix] = CreateRevMatrixforLongvShort_HMM(finalTracks,trackindex,startFrame,stopFrame,roamIndices);
     
     LongvShortInfo.LongDwBinsRevMatrix(index14,1:4) = [Num_total_revs Num_sRevs Num_lRevs Duration_of_State];
     MasterDwLongSpeedMatrix = [MasterDwLongSpeedMatrix; SpeedMatrix];
     MasterDwLongAngSpeedMatrix = [MasterDwLongAngSpeedMatrix; AngSpeedMatrix];
     MasterDwLonglRevSpeedMatrix = [MasterDwLonglRevSpeedMatrix; lRevSpeedMatrix];
     MasterDwLongsRevSpeedMatrix = [MasterDwLongsRevSpeedMatrix; sRevSpeedMatrix];
     %display(TotalRevRate)
     %display(sRevRate)
     %display(lRevRate)
     index14 = index14+1;
 end
 
 for(x=1:9)
    LongvShortInfo.AvgShortSpeedMatrix(x) = nanmean(MasterShortSpeedMatrix(:,x));
    LongvShortInfo.AvgShortAngSpeedMatrix(x) = nanmean(MasterShortAngSpeedMatrix(:,x));
    LongvShortInfo.AvgShortlRevSpeedMatrix(x) = nanmean(MasterShortlRevSpeedMatrix(:,x));
    LongvShortInfo.AvgShortsRevSpeedMatrix(x) = nanmean(MasterShortsRevSpeedMatrix(:,x));
    LongvShortInfo.AvgRoShortSpeedMatrix(x) = nanmean(MasterRoShortSpeedMatrix(:,x));
    LongvShortInfo.AvgRoShortAngSpeedMatrix(x) = nanmean(MasterRoShortAngSpeedMatrix(:,x));
    LongvShortInfo.AvgRoShortlRevSpeedMatrix(x) = nanmean(MasterRoShortlRevSpeedMatrix(:,x));
    LongvShortInfo.AvgRoShortsRevSpeedMatrix(x) = nanmean(MasterRoShortsRevSpeedMatrix(:,x));
    LongvShortInfo.AvgDwShortSpeedMatrix(x) = nanmean(MasterDwShortSpeedMatrix(:,x));
    LongvShortInfo.AvgDwShortAngSpeedMatrix(x) = nanmean(MasterDwShortAngSpeedMatrix(:,x));
    LongvShortInfo.AvgDwShortlRevSpeedMatrix(x) = nanmean(MasterDwShortlRevSpeedMatrix(:,x));
    LongvShortInfo.AvgDwShortsRevSpeedMatrix(x) = nanmean(MasterDwShortsRevSpeedMatrix(:,x));
     
    LongvShortInfo.AvgLongSpeedMatrix(x) = nanmean(MasterLongSpeedMatrix(:,x));
    LongvShortInfo.AvgLongAngSpeedMatrix(x) = nanmean(MasterLongAngSpeedMatrix(:,x));
    LongvShortInfo.AvgLonglRevSpeedMatrix(x) = nanmean(MasterLonglRevSpeedMatrix(:,x));
    LongvShortInfo.AvgLongsRevSpeedMatrix(x) = nanmean(MasterLongsRevSpeedMatrix(:,x));
    LongvShortInfo.AvgRoLongSpeedMatrix(x) = nanmean(MasterRoLongSpeedMatrix(:,x));
    LongvShortInfo.AvgRoLongAngSpeedMatrix(x) = nanmean(MasterRoLongAngSpeedMatrix(:,x));
    LongvShortInfo.AvgRoLonglRevSpeedMatrix(x) = nanmean(MasterRoLonglRevSpeedMatrix(:,x));
    LongvShortInfo.AvgRoLongsRevSpeedMatrix(x) = nanmean(MasterRoLongsRevSpeedMatrix(:,x));
    LongvShortInfo.AvgDwLongSpeedMatrix(x) = nanmean(MasterDwLongSpeedMatrix(:,x));
    LongvShortInfo.AvgDwLongAngSpeedMatrix(x) = nanmean(MasterDwLongAngSpeedMatrix(:,x));
    LongvShortInfo.AvgDwLonglRevSpeedMatrix(x) = nanmean(MasterDwLonglRevSpeedMatrix(:,x));
    LongvShortInfo.AvgDwLongsRevSpeedMatrix(x) = nanmean(MasterDwLongsRevSpeedMatrix(:,x));
 end
    
    

 LongvShortInfo.avgSpeedShort = nanmean(rawSpeedDataShortAll);
 LongvShortInfo.avgSpeedLong = nanmean(rawSpeedDataLongAll);
 LongvShortInfo.avgAngSpeedShort = nanmean(rawAngSpDataShortAll);
 LongvShortInfo.avgAngSpeedLong = nanmean(rawAngSpDataLongAll);
 LongvShortInfo.avgTimeInDwellStateShort = mean(ratioTimeinDwellStateforShort);
 LongvShortInfo.avgTimeInDwellStateLong = mean(ratioTimeinDwellStateforLong);
 LongvShortInfo.avgDwSpeedShort = nanmean(rawDwSpeedDataShortAll);
 LongvShortInfo.avgDwSpeedLong = nanmean(rawDwSpeedDataLongAll);
 LongvShortInfo.avgDwAngSpeedShort = nanmean(rawDwAngSpeedDataShortAll);
 LongvShortInfo.avgDwAngSpeedLong = nanmean(rawDwAngSpeedDataLongAll);
 LongvShortInfo.avgRoSpeedShort = nanmean(rawRoSpeedDataShortAll);
 LongvShortInfo.avgRoSpeedLong = nanmean(rawRoSpeedDataLongAll);
 LongvShortInfo.avgRoAngSpeedShort = nanmean(rawRoAngSpeedDataShortAll);
 LongvShortInfo.avgRoAngSpeedLong = nanmean(rawRoAngSpeedDataLongAll);
 
 
 Num1 = sum(LongvShortInfo.ShortRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.ShortRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.ShortRevMatrix(:,3));
 Duration = sum(LongvShortInfo.ShortRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsShort = Num1/Duration;
 LongvShortInfo.avgsRevsShort = Num2/Duration;
 LongvShortInfo.avglRevsShort = Num3/Duration;
 
 Num1 = sum(LongvShortInfo.ShortDwBinsRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.ShortDwBinsRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.ShortDwBinsRevMatrix(:,3));
 Duration = sum(LongvShortInfo.ShortDwBinsRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsShortDw = Num1/Duration;
 LongvShortInfo.avgsRevsShortDw = Num2/Duration;
 LongvShortInfo.avglRevsShortDw = Num3/Duration;
 
 
 Num1 = sum(LongvShortInfo.ShortRoBinsRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.ShortRoBinsRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.ShortRoBinsRevMatrix(:,3));
 Duration = sum(LongvShortInfo.ShortRoBinsRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsShortRo = Num1/Duration;
 LongvShortInfo.avgsRevsShortRo = Num2/Duration;
 LongvShortInfo.avglRevsShortRo = Num3/Duration;
 
 
 Num1 = sum(LongvShortInfo.LongRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.LongRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.LongRevMatrix(:,3));
 Duration = sum(LongvShortInfo.LongRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsLong = Num1/Duration;
 LongvShortInfo.avgsRevsLong = Num2/Duration;
 LongvShortInfo.avglRevsLong = Num3/Duration;
 
 
 Num1 = sum(LongvShortInfo.LongDwBinsRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.LongDwBinsRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.LongDwBinsRevMatrix(:,3));
 Duration = sum(LongvShortInfo.LongDwBinsRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsLongDw = Num1/Duration;
 LongvShortInfo.avgsRevsLongDw = Num2/Duration;
 LongvShortInfo.avglRevsLongDw = Num3/Duration;
 
 
 Num1 = sum(LongvShortInfo.LongRoBinsRevMatrix(:,1));
 Num2 = sum(LongvShortInfo.LongRoBinsRevMatrix(:,2));
 Num3 = sum(LongvShortInfo.LongRoBinsRevMatrix(:,3));
 Duration = sum(LongvShortInfo.LongRoBinsRevMatrix(:,4));
 LongvShortInfo.avgTotalRevsLongRo = Num1/Duration;
 LongvShortInfo.avgsRevsLongRo = Num2/Duration;
 LongvShortInfo.avglRevsLongRo = Num3/Duration;
 



 
 
end      
        
        