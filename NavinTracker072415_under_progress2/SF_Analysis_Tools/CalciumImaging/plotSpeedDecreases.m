function [AllSpeedData AllCalciumData] = plotSpeedDecreases(folder,averageSize,derivStep,derivSmooth)


[AllCalcium AllSpeed AllCalciumDerivErrorData] = collectDerivs(folder,averageSize,derivStep,derivSmooth); %400,20,100

AllMins = struct('mins',[]);
LowSpeedCutoff = -.95; %-1.1
minDeriv = -5;
SurroundTime_before = 600; % in frames
SurroundTime_after = 1200;


for(i=1:length(AllCalcium))
    lowSpInd = find(AllSpeed(i).Speed<LowSpeedCutoff);
    ends = find(diff(lowSpInd)>1);
    if(length(ends)>0)
    begins = [1 ends+1];
    ends = [ends length(lowSpInd)];
    AllMins(i).mins = [];
    for(j=1:length(begins))
        stretchHere = lowSpInd(begins(j):ends(j));
        [minHere,minInd] = min(AllSpeed(i).Speed(stretchHere));
        AllMins(i).mins = [AllMins(i).mins (minInd+stretchHere(1)-1)];
    end
    else
        AllMins(i).mins = [];
    end
end
    

PathofFolder = sprintf('%s',folder);
 %%%%%%%%%%%%%%%%%%%
fileList = ls(PathofFolder);
numFiles = length(fileList(:,1));

IndexHere = 1;
AllSpeedData = [];
AllCalciumData = [];


for(i=1:length(AllMins))
    
     string2 = deblank(fileList(i+2,:));
     fileToOpen = sprintf('%s/%s',PathofFolder,string2);
     [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,1);
    alreadyDone = [];
    for(j=1:length(AllMins(i).mins))

        minHere = AllMins(i).mins(j);
        
        start = minHere-150;
        stop = minHere+150;
        
        if(start>0 && (stop<length(cellData(:,1))))
            
        %%%%Check for continuity - move start or stop if it's a problem  
        
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>100);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
        
        
        Disrupt_startRegion = find(checkVector(start:minHere)>0)';    
        Disrupt_stopRegion = find(checkVector(minHere:stop)>0)';    
        
        changedStart = 0;
        adjustStart = 1;
        if(length(Disrupt_startRegion>0))

            HighestDisrupt = max(Disrupt_startRegion);
            changedStart = HighestDisrupt;
            start = start+HighestDisrupt;
            adjustStart = HighestDisrupt+1;
        end
        adjuststop = 301;
        if(length(Disrupt_stopRegion>0))

            LowestDisrupt = min(Disrupt_stopRegion);
            DiffHere = 150-LowestDisrupt;
            stop = stop- DiffHere;
            adjuststop= adjuststop - DiffHere;
        end
        
        SpeedHere = cellData(start:stop,19);

        
        %%%%%%%%%Get Deriv of Speed
        StepSize = 20;
        DiffHereSpeed = [];
        for(k=(1+StepSize):(length(SpeedHere)-StepSize));
            DiffHereSpeed(k-StepSize) = SpeedHere(k+StepSize)-SpeedHere(k-StepSize);
        end
        Beginning(1:StepSize) = NaN;
        Ending(1:StepSize) = NaN;
        DiffHereSpeed = [Beginning DiffHereSpeed Ending];
        
        %%%%%%%Smoothen
       DerivSmootheningSize = 30;
       NewDiffHereSpeed = [];
       for(l=((DerivSmootheningSize/2)+1):(length(SpeedHere)-(DerivSmootheningSize/2)))
          NewDiffHereSpeed(l) = nanmean(DiffHereSpeed((l-(DerivSmootheningSize/2)):(l+(DerivSmootheningSize/2))));
       end     
       datalen = length(SpeedHere);
       NewDiffHereSpeed(1:(DerivSmootheningSize/2)) = NaN;
       NewDiffHereSpeed((datalen-(DerivSmootheningSize/2)):datalen) = NaN;

       
       [RegionMin,IndexMin] = min(SpeedHere);

       NegSlopes = find(NewDiffHereSpeed<minDeriv);
       NegSlopes2 = NegSlopes-IndexMin;
       posIndex = find(NegSlopes2>0);
       NegSlopes2(posIndex) = [];
       if(length(NegSlopes2)>0)
       LastNegSlope = max(NegSlopes2) + IndexMin;
       
       %%%%Find when LastNegSlope starts to become Neg
       
       PosSlopes = find(NewDiffHereSpeed>-3);
       PosSlopes2 = PosSlopes-LastNegSlope;
       posIndex = find(PosSlopes2>0);
       PosSlopes2(posIndex) = [];
       LastNegSlope_Beg = max(PosSlopes2) + LastNegSlope;
       
       
       
       %%%%Re-center 301 = 0
       
       NewIndex = LastNegSlope_Beg - 151 + changedStart; % Relative to original min
       NewIndex = NewIndex + minHere;
       NewStart = 0;
       NewStop = 1000000;
       if(~isempty(NewIndex))
       NewStart = NewIndex-SurroundTime_before;
       NewStop = NewIndex+SurroundTime_after;
       end
      
       if(NewStart>0 && (NewStop<length(cellData(:,1))))
           check1 = find(alreadyDone==NewStart);
           check2 = size(check1);
            if(check2(2)==0)
            %%%%Check for continuity - move start or stop if it's a problem  
            
            
            Disrupt_startRegion2 = find(checkVector(NewStart:(NewStart+SurroundTime_before-1))>0)';    
            Disrupt_stopRegion2 = find(checkVector((NewStart+SurroundTime_before):NewStop)>0)';    
        
            AdjustBeg = 1;
            ActualStart = NewStart;
            if(length(Disrupt_startRegion2>0))

                HighestDisrupt = max(Disrupt_startRegion2);
  
                ActualStart = NewStart+HighestDisrupt;
                %SpeedData_Before(1:(HighestDisrupt)) = NaN;
                %CalciumData_Before(1:(HighestDisrupt)) = NaN;
                AdjustBeg = HighestDisrupt+1;
            end
            
            AdjustEnd = ((SurroundTime_before+SurroundTime_after)+1);
            ActualStop = NewStop;
            if(length(Disrupt_stopRegion2>0))

                LowestDisrupt = min(Disrupt_stopRegion2);

                DiffHere = SurroundTime_after-LowestDisrupt;
                ActualStop = NewStop - DiffHere-1;
                %SpeedData_After((((2*SurroundTime)+1)-DiffHere-SurroundTime):((2*SurroundTime)+1-SurroundTime)) = NaN;
                %CalciumData_After((((2*SurroundTime)+1)-DiffHere-SurroundTime):((2*SurroundTime)+1-SurroundTime)) = NaN;
                AdjustEnd = AdjustEnd-DiffHere-1;
            end

           FramesofInterest_BeginRegion = cellData(ActualStart:(NewIndex-1),1);
           EndofBeginRegion_Frames = FramesofInterest_BeginRegion(end);
           DiffBegin = EndofBeginRegion_Frames - 1000;
           FramesofInterest_AfterRegion = cellData(NewIndex:ActualStop,1);
           StartofAfterRegion_Frames = FramesofInterest_AfterRegion(1);
           DiffEnd = StartofAfterRegion_Frames-1001;
           
           FramesofInterest_BeginRegion_ReCal = FramesofInterest_BeginRegion - DiffBegin;
           FramesofInterest_AfterRegion_ReCal = FramesofInterest_AfterRegion - DiffEnd;
           
           SpeedData(1:3000) = NaN;
           CalciumData(1:3000) = NaN;
           
           SpeedData(FramesofInterest_BeginRegion_ReCal) = cellData(ActualStart:(NewIndex-1),19);
           SpeedData(FramesofInterest_AfterRegion_ReCal) = cellData(NewIndex:ActualStop,19);

           CalciumData(FramesofInterest_BeginRegion_ReCal) = cellData(ActualStart:(NewIndex-1),23);
           CalciumData(FramesofInterest_AfterRegion_ReCal) = cellData(NewIndex:ActualStop,23);
           
        AllSpeedData(IndexHere,1:3000) = SpeedData;
        AllCalciumData(IndexHere,1:3000) = CalciumData;

        IndexHere = IndexHere+1;

            end
       end
       end
    end
    
    
    end
end


      
% for(i=1:2000)
%     AvgSpeed(i) = nanmean(AllSpeedData(:,i));
%     AvgCalcium(i) = nanmean(AllCalciumData(:,i));
% end
% figure(1); imagesc(AllSpeedData);
% figure(2); plotyy(-999:1000,AvgSpeed,-999:1000,AvgCalcium)
plotCalciumSpeedRelationship(AllCalciumData,AllSpeedData,400,2200,1000,970,1000);      
        
        
end


