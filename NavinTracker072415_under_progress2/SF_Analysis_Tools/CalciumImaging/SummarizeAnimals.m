function [EachAnimalData ControlIRIs PeakIRIs IPIs PeakToRuns SimulPeakToRuns SpeedAcuteData CalciumAcuteData SpeedAcuteData_long CalciumAcuteData_long SpeedAcuteData_Extralong CalciumAcuteData_Extralong FRunCalciumAcuteData FRunSpeedAcuteData FRunPeakStartData TotalPeakFreq FracOfTimeinFRun AverageSpeed FRunRasterAtPeakData TotalMinRecorded] = SummarizeAnimals(folder,NSMflag,StretchLength,PositiveDataCutoff,FluorChangeCutoff)
    PathofFolder = sprintf('%s',folder);
    
    AllMinutes = 0;
    AllNumPeaks = 0;
    
    anIndex = 1;
    
    IndexAcute = 1;
    IndexAcute_long =1;
    IndexAcute_Extralong =1;
    IndexFRunAcute =1;
    FRunSimulIndex = 1;
    FRunIndexAn =1;
    %%%%%%%%%%%%%%%%%%%
    fileList = ls(PathofFolder);

    numFiles = length(fileList(:,1));
    %%%%%%%%%%%%%%%%%%%
    ControlIRIs = NaN(30,30);
    CIRI_Ind = 1;
    PeakIRIs = NaN(30,30);
    PIRI_Ind = 1;
    IPIs = NaN(30,30);
    IPI_Ind = 1;
    PeakToRuns = NaN(30,30);
    PeakToRun_Ind = 1;
    SimulPeakToRuns = NaN(30,100);
    SimulPeakToRun_Ind = 1;
    
    %%%%%%Variable not assigned if no peaks
    SpeedAcuteData_long = [];
    CalciumAcuteData_long =[];
    SpeedAcuteData_Extralong =[];
    CalciumAcuteData_Extralong =[];
    FRunRasterAtPeakData =[];
    
    %%%%%%%Variable not assigned if no FRuns
    FRunCalciumAcuteData = [];
    FRunSpeedAcuteData =[];
    FRunPeakStartData = [];
    FRunRasterAtPeakData = [];
    
    TotalMinRecorded = 0;
    
    for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            fileToOpen = sprintf('%s/%s',PathofFolder,string2);
        
            [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,NSMflag,StretchLength,PositiveDataCutoff,FluorChangeCutoff);
    
            TotalMinRecorded = TotalMinRecorded + ((length(cellData(:,1)))/600);
    
    %%%%%%%%%%% Fraction of time in FRuns
    if(length(cellData(:,2))>2500)
    NumRows = length(cellData(:,22));
    NumFRunRows = length(find(cellData(:,22)==2));
    FracOfTimeinFRun(j-2) = NumFRunRows/NumRows;
    else
        FracOfTimeinFRun(j-2) = NaN;
    end
    
    %%%%%%%%%%% AverageSpeed
    if(length(cellData(:,2))>2500)
    
        AverageSpeed(j-2) = nanmean(cellData(:,19));
    else
        AverageSpeed(j-2) = NaN;
    end
            
            
    
    if(length(cellData(:,2))>2500)
    %%%%%%%%%%%%Correlation coefficient with 10s bins
    
    SpeedFluorTable = CalciumSpeedCorrelation(cellData,10);
    SpeedFluorCorr = corr2(SpeedFluorTable(:,1),SpeedFluorTable(:,2));
    [newtest p] = corrcoef(SpeedFluorTable(:,1),SpeedFluorTable(:,2));
%    EachAnimalData((j-2),1) = string2;
    EachAnimalData((j-2),1) = SpeedFluorCorr;
    
    
    %%%%%%%%%%%Get calcium imaging data surrounding forward run starts
    
    checkForRuns1 = size(ForwardRunStarts);
    if(checkForRuns1(1)>0)
        %%%%Average fluor for all data for this animal
        AveFluorHere = nanmean(cellData(:,23));
        AveFluorForRuns(FRunIndexAn) = AveFluorHere;
        FRunIndexAn = FRunIndexAn+1;
        %%%%Remove consecutive runs (within 1 min of eachother)
        CheckForDuplRuns1 = diff(ForwardRunStarts);
        CheckForDuplRuns2 = find(CheckForDuplRuns1<600)+1;
        ForwardRunStarts_DuplRemoved = ForwardRunStarts;
        ForwardRunStarts_DuplRemoved(CheckForDuplRuns2) = [];
        
        for(m=1:length(ForwardRunStarts_DuplRemoved))
            FRunStart = ForwardRunStarts_DuplRemoved(m);
            BeforeRegion = (FRunStart-2999):FRunStart;
            AfterRegion = (FRunStart+1):(FRunStart+3000);
            %%%%%%%%%Trim Before and After regions if they fall outside the
            %%%%%%%%%data
            if(BeforeRegion(1)<1)
                NegativeRegion = find(BeforeRegion<1);
                BeforeRegion(NegativeRegion) = [];
            end
            
            if(AfterRegion(end)>(length(cellData(:,1))))
                numRows = length(cellData(:,1));
                OutofBoundRegion = find(AfterRegion>numRows);
                AfterRegion(OutofBoundRegion) =[];
            end
            
            checkContinuity = [];
            numRows = length(cellData(:,1));
            checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
            MoreThanIndices = find(checkContinuity>600);
            checkVector = [];
            checkVector(1:length(cellData(:,1))) = 0;
            checkVector(MoreThanIndices)=1;
            
            
            BeforeRegionTest = find(checkVector(BeforeRegion)>0);
            if(length(BeforeRegionTest)>0)
                MostRecentInt = max(BeforeRegionTest);
                BeforeRegion = (FRunStart-(length(BeforeRegion))+MostRecentInt+1):FRunStart;
            end
        
            AfterRegionTest = find(checkVector(AfterRegion)>0);
            if(length(AfterRegionTest)>0)
               FirstInt = min(AfterRegionTest);
               AfterRegionNewEnd = FRunStart+FirstInt;
               AfterRegion = (FRunStart+1):AfterRegionNewEnd;
            end

       if(length(BeforeRegion)>300)
       if(length(AfterRegion)>300)
                
                if(size(FinalStretchTable,1)>0)
                PeakStarts = FinalStretchTable(:,1);
                PeakBeforeInd = find(PeakStarts<=FRunStart);
                PeakAfterInd = find(PeakStarts>FRunStart);
                if(length(PeakBeforeInd)>0)
                PeakStarts_Before = PeakStarts(PeakBeforeInd);
                else
                    PeakStarts_Before = [];
                end
                if(length(PeakAfterInd>0))
                PeakStarts_After = PeakStarts(PeakAfterInd);
                else 
                    PeakStarts_After = [];
                end
                else 
                    PeakStarts_Before = [];
                    PeakStarts_After = [];
                end

                
                FRunSpeedDataB = cellData(BeforeRegion,19);
                FRunCalciumDataB = cellData(BeforeRegion,23);
                FRunSpeedDataA = cellData(AfterRegion,19);
                FRunCalciumDataA = cellData(AfterRegion,23);
                
                
                
                
                FRunSpeedAcuteData(IndexFRunAcute,1:8001) = NaN;
                FRunCalciumAcuteData(IndexFRunAcute,1:8001) = NaN;
                FRunPeakStartData(IndexFRunAcute,1:8001) = NaN;
                

                
                
                %%%%%%%Define Data by Frame# rather than indices, since
                %%%%%%%some frames are missing
                
                BeforeRegionFrames = cellData(BeforeRegion,1);
                EndofBeforeRegion = BeforeRegionFrames(end);
                DiffHereB = EndofBeforeRegion-4000;
                BeforeRegionFrames_ReCal = BeforeRegionFrames-DiffHereB;
                

                
                AfterRegionFrames = cellData(AfterRegion,1);
                BeginofAfterRegion = AfterRegionFrames(1);
                DiffHereA = BeginofAfterRegion-4001;
                AfterRegionFrames_ReCal = AfterRegionFrames-DiffHereA;
                

                

                
             
                FRunSpeedAcuteData(IndexFRunAcute, BeforeRegionFrames_ReCal) = FRunSpeedDataB;
                FRunSpeedAcuteData(IndexFRunAcute, AfterRegionFrames_ReCal) = FRunSpeedDataA;
                FRunCalciumAcuteData(IndexFRunAcute, BeforeRegionFrames_ReCal) = FRunCalciumDataB;
                FRunCalciumAcuteData(IndexFRunAcute, AfterRegionFrames_ReCal) = FRunCalciumDataA;
                
                
                FirstFrameWithData = min(find(~isnan(FRunCalciumAcuteData(IndexFRunAcute,:))==1));
                LastFrameWithData = max(find(~isnan(FRunCalciumAcuteData(IndexFRunAcute,:))==1));
                
                FRunPeakStartData(IndexFRunAcute,FirstFrameWithData:LastFrameWithData) = 0;
                
                if(length(PeakStarts_Before)>0)

                PeakStarts_Before_Frames = cellData(PeakStarts_Before,1);
                PeakStartFrames_Before_ReCal = PeakStarts_Before_Frames-DiffHereB;
                PeaksTooEarly = find(PeakStartFrames_Before_ReCal<1);
                PeakStartFrames_Before_ReCal(PeaksTooEarly) = [];
                FRunPeakStartData(IndexFRunAcute,PeakStartFrames_Before_ReCal) = 1;
                end
                
                if(length(PeakStarts_After)>0)
                PeakStarts_After_Frames = cellData(PeakStarts_After,1);
                PeakStartFrames_After_ReCal = PeakStarts_After_Frames-DiffHereA;
                PeaksTooLate = find(PeakStartFrames_After_ReCal>8001);
                PeakStartFrames_After_ReCal(PeaksTooLate) = [];
                FRunPeakStartData(IndexFRunAcute,PeakStartFrames_After_ReCal) = 1;
                end
                
                IndexFRunAcute=IndexFRunAcute+1;
                
       end
       end
        end
    end
    
    
    
    
    %%%%%%%%%%Simulate FwdRunStarts to get background
    FRunSimulCount = 1;
        if(checkForRuns1(1)>0)
        while(FRunSimulCount~=1) %%%%%%%FIX HERE
            numRows = length(cellData(:,1));
            
            FRunStart = ceil(rand(1)*numRows);
            
            BeforeRegion = (FRunStart-2999):FRunStart;
            AfterRegion = (FRunStart+1):(FRunStart+3000);
            
            if(BeforeRegion(1)<1)
                NegativeRegion = find(BeforeRegion<1);
                BeforeRegion(NegativeRegion) = [];
            end
            
            if(AfterRegion(end)>(length(cellData(:,1))))
                numRows = length(cellData(:,1));
                OutofBoundRegion = find(AfterRegion>numRows);
                AfterRegion(OutofBoundRegion) =[];
            end
            
            checkContinuity = [];
            numRows = length(cellData(:,1));
            checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
            MoreThanIndices = find(checkContinuity>50);
            checkVector(1:length(cellData(:,1))) = 0;
            checkVector(MoreThanIndices)=1;
            
            
            
            BeforeRegionTest = find(checkVector(BeforeRegion)>0);
            if(length(BeforeRegionTest)>0)
                MostRecentInt = max(BeforeRegionTest);
                BeforeRegion = (FRunStart-(length(BeforeRegion))+MostRecentInt):FRunStart;
            end
        
            AfterRegionTest = find(checkVector(AfterRegion)>0);
            if(length(AfterRegionTest)>0)
               FirstInt = min(AfterRegionTest);
               AfterRegionNewEnd = FRunStart+FirstInt;
               AfterRegion = (FRunStart+1):AfterRegionNewEnd;
            end

       if(length(BeforeRegion)>300)
       if(length(AfterRegion)>300)
                
                SimulFRunSpeedDataB = cellData(BeforeRegion,19);
                SimulFRunCalciumDataB = cellData(BeforeRegion,23);
                SimulFRunSpeedDataA = cellData(AfterRegion,19);
                SimulFRunCalciumDataA = cellData(AfterRegion,23);
                SimulFRunSpeedAcuteData(FRunSimulIndex,1:6001) = NaN;
                SimulFRunCalciumAcuteData(FRunSimulIndex,1:6001) = NaN;
                SimulFRunSpeedAcuteData(FRunSimulIndex, (3000-length(SimulFRunSpeedDataB)+1):3000) = SimulFRunSpeedDataB;
                SimulFRunSpeedAcuteData(FRunSimulIndex, 3001:(3001+length(SimulFRunSpeedDataA)-1)) = SimulFRunSpeedDataA;
                SimulFRunCalciumAcuteData(FRunSimulIndex, (3000-length(SimulFRunCalciumDataB)+1):3000) = SimulFRunCalciumDataB;
                SimulFRunCalciumAcuteData(FRunSimulIndex, 3001:(3001+length(SimulFRunCalciumDataA)-1)) = SimulFRunCalciumDataA;
                FRunSimulIndex=FRunSimulIndex+1;
                FRunSimulCount = FRunSimulCount+1;
       end
       end
        end
    end
     
    %%%%%%%%%%%Define peaks and valleys using Saul method
    
    [AllSmoothData AllPeaks AllValleys] = GetCalciumPeaks_SaulMethod(cellData);
    
    
    %%%%%%%%%%%Num of Peaks Div by Num of Frames
    
    if(size(FinalStretchTable,1)>0)
    NumPeaks = length(FinalStretchTable(:,1));
    AllNumPeaks = AllNumPeaks+NumPeaks;
    NumFrames = length(cellData(:,1));
    NumMinutes = NumFrames/600;
    AllMinutes = AllMinutes+NumMinutes;
    EachAnimalData((j-2),7) = NumPeaks/NumMinutes;
    
    end
    
    %%%%%%%%%%%%AverageFluor for each animal
    
    
    %%%%%%%%%%%Get Speed, Ca Data for 60sec on each side of peak start
    if(size(FinalStretchTable,1)>0)
    for(m=1:length(FinalStretchTable(:,1)))
        startPeak = FinalStretchTable(m,1);

        BeforeRegion = (startPeak-300):(startPeak-1);
        checkforBefore = find(BeforeRegion<1);
        BeforeRegion(checkforBefore) = [];
        AfterRegion = startPeak:(startPeak+300);
        checkforAfter = find(AfterRegion>length(cellData(:,1)));
        AfterRegion(checkforAfter) = [];
        
        BeforeRegionTest = find(cellData(BeforeRegion,17)>0);
        if(length(BeforeRegionTest)>0)
            MostRecentInt = max(BeforeRegionTest);
            BeforeRegion = (startPeak-length(BeforeRegion)+MostRecentInt):(startPeak-1);
        end
        
        AfterRegionTest = find(cellData(AfterRegion,17)>0);
        if(length(AfterRegionTest)>0)
            FirstInt = min(AfterRegionTest);
            AfterRegionNewEnd = startPeak+FirstInt;
            AfterRegion = startPeak:AfterRegionNewEnd;
        end
        
        if(length(BeforeRegion)>30)
            if(length(AfterRegion)>30)
                display(BeforeRegion)
                SpeedDataB = cellData(BeforeRegion,19);
                CalciumDataB = cellData(BeforeRegion,23);
                SpeedDataA = cellData(AfterRegion,19);
                CalciumDataA = cellData(AfterRegion,23);
                SpeedAcuteData(IndexAcute,1:601) = NaN;
                CalciumAcuteData(IndexAcute,1:601) = NaN;
                SpeedAcuteData(IndexAcute, (300-length(SpeedDataB)+1):300) = SpeedDataB;
                SpeedAcuteData(IndexAcute, 301:(301+length(SpeedDataA)-1)) = SpeedDataA;
                CalciumAcuteData(IndexAcute, (300-length(SpeedDataB)+1):300) = CalciumDataB;
                CalciumAcuteData(IndexAcute, 301:(301+length(SpeedDataA)-1)) = CalciumDataA;
                IndexAcute=IndexAcute+1;
            end
        end
    end
        
    end
    
    
        %%%%%%%%%%%Get Speed, Ca Data for 60sec before and 3 min after each
        %%%%%%%%%%%peak
    if(size(FinalStretchTable,1)>0)
    for(m=1:length(FinalStretchTable(:,1)))
        startPeak = FinalStretchTable(m,1);

        BeforeRegion = (startPeak-300):(startPeak-1);
        checkforBefore = find(BeforeRegion<1);
        BeforeRegion(checkforBefore) = [];
        AfterRegion = startPeak:(startPeak+1800);
        checkforAfter = find(AfterRegion>length(cellData(:,1)));
        AfterRegion(checkforAfter) = [];
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>250);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
            
            
        BeforeRegionTest = find(checkVector(BeforeRegion)>0);
            if(length(BeforeRegionTest)>0)
                MostRecentInt = max(BeforeRegionTest);
                BeforeRegion = (startPeak-(length(BeforeRegion))+MostRecentInt+1):startPeak;
            end
        
        AfterRegionTest = find(checkVector(AfterRegion)>0);
            if(length(AfterRegionTest)>0)
               FirstInt = min(AfterRegionTest);
               AfterRegionNewEnd = startPeak+FirstInt-1;
               AfterRegion = (startPeak+1):AfterRegionNewEnd;
            end
        %%%%%%%Define Data by Frame# rather than indices, since
                %%%%%%%some frames are missing
                
                BeforeRegionFrames = cellData(BeforeRegion,1);
                EndofBeforeRegion = BeforeRegionFrames(end);
                DiffHere = EndofBeforeRegion-1000;
                BeforeRegionFrames_ReCal = BeforeRegionFrames-DiffHere;

                
                
                AfterRegionFrames = cellData(AfterRegion,1);
                BeginofAfterRegion = AfterRegionFrames(1);
                DiffHere = BeginofAfterRegion-1001;
                AfterRegionFrames_ReCal = AfterRegionFrames-DiffHere;
        

        
        if(length(BeforeRegion)>30)
            if(length(AfterRegion)>30)
                
                AveFluorForLong = nanmean(cellData(:,23));
                AveSpeedForLong = nanmean(cellData(:,19));
                
                
                
                SpeedDataB_long = cellData(BeforeRegion,19);
                CalciumDataB_long = cellData(BeforeRegion,23);
                SpeedDataA_long = cellData(AfterRegion,19);
                CalciumDataA_long = cellData(AfterRegion,23);
                SpeedAcuteData_long(IndexAcute_long,1:4001) = NaN;
                CalciumAcuteData_long(IndexAcute_long,1:4001) = NaN;
                SpeedAcuteData_long(IndexAcute_long, BeforeRegionFrames_ReCal) = SpeedDataB_long;
                SpeedAcuteData_long(IndexAcute_long, AfterRegionFrames_ReCal) = SpeedDataA_long;
                CalciumAcuteData_long(IndexAcute_long, BeforeRegionFrames_ReCal) = CalciumDataB_long;
                CalciumAcuteData_long(IndexAcute_long, AfterRegionFrames_ReCal) = CalciumDataA_long;
                IndexAcute_long=IndexAcute_long+1;
            end
        end
    end
        
    end
    
    
    
    %%%%%%%%%%%Get Speed, Ca Data for 60sec before and 4 min after each
        %%%%%%%%%%%peak
    if(size(FinalStretchTable,1)>0)
    for(m=1:length(FinalStretchTable(:,1)))
        startPeak = FinalStretchTable(m,1);

        BeforeRegion = (startPeak-2400):(startPeak-1);
        checkforBefore = find(BeforeRegion<1);
        BeforeRegion(checkforBefore) = [];
        AfterRegion = startPeak:(startPeak+8000);
        checkforAfter = find(AfterRegion>length(cellData(:,1)));
        AfterRegion(checkforAfter) = [];
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>250);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if(length(ForwardRunStarts)>0)
                RunBeforeInd = find(ForwardRunStarts<=startPeak);
                RunAfterInd = find(ForwardRunStarts>startPeak);
                if(length(RunBeforeInd)>0)
                RunStarts_Before = ForwardRunStarts(RunBeforeInd);
                else
                    RunStarts_Before = [];
                end
                if(length(RunAfterInd>0))
                RunStarts_After = ForwardRunStarts(RunAfterInd);
                else 
                    RunStarts_After = [];
                end
                else 
                    RunStarts_Before = [];
                    RunStarts_After = [];
                end
        
        
        
        
        
        
        BeforeRegionTest = find(checkVector(BeforeRegion)>0);
            if(length(BeforeRegionTest)>0)
                MostRecentInt = max(BeforeRegionTest);
                BeforeRegion = (startPeak-(length(BeforeRegion))+MostRecentInt+1):startPeak;
            end
        
        AfterRegionTest = find(checkVector(AfterRegion)>0);
            if(length(AfterRegionTest)>0)
               FirstInt = min(AfterRegionTest);
               AfterRegionNewEnd = startPeak+FirstInt-1;
               AfterRegion = (startPeak+1):AfterRegionNewEnd;
            end
        %%%%%%%Define Data by Frame# rather than indices, since
                %%%%%%%some frames are missing
                
                BeforeRegionFrames = cellData(BeforeRegion,1);
                EndofBeforeRegion = BeforeRegionFrames(end);
                DiffHereB = EndofBeforeRegion-3000;
                BeforeRegionFrames_ReCal = BeforeRegionFrames-DiffHereB;

                
                
                AfterRegionFrames = cellData(AfterRegion,1);
                BeginofAfterRegion = AfterRegionFrames(1);
                DiffHereA = BeginofAfterRegion-3001;
                AfterRegionFrames_ReCal = AfterRegionFrames-DiffHereA;
        

        if(BeforeRegionFrames_ReCal(1)>0)
        if(length(BeforeRegion)>30)
            if(length(AfterRegion)>30)
                
                
                AveFluorForExtraLong = nanmean(cellData(:,23));
                AveSpeedForExtraLong = nanmean(cellData(:,19));
                
                
                
                SpeedDataB_Extralong = cellData(BeforeRegion,19);
                CalciumDataB_Extralong = cellData(BeforeRegion,23);
                SpeedDataA_Extralong = cellData(AfterRegion,19);
                CalciumDataA_Extralong = cellData(AfterRegion,23);
                SpeedAcuteData_Extralong(IndexAcute_Extralong,1:14001) = NaN;
                CalciumAcuteData_Extralong(IndexAcute_Extralong,1:14001) = NaN;
                
                SpeedAcuteData_Extralong(IndexAcute_Extralong, BeforeRegionFrames_ReCal) = SpeedDataB_Extralong;
                SpeedAcuteData_Extralong(IndexAcute_Extralong, AfterRegionFrames_ReCal) = SpeedDataA_Extralong;
                CalciumAcuteData_Extralong(IndexAcute_Extralong, BeforeRegionFrames_ReCal) = CalciumDataB_Extralong;
                CalciumAcuteData_Extralong(IndexAcute_Extralong, AfterRegionFrames_ReCal) = CalciumDataA_Extralong;
                
            end
        end
        
        FirstFrameWithDataHere = min(find(~isnan(CalciumAcuteData_Extralong(IndexAcute_Extralong,:))==1));
        LastFrameWithDataHere = max(find(~isnan(CalciumAcuteData_Extralong(IndexAcute_Extralong,:))==1));
        
       FRunRasterAtPeakData(IndexAcute_Extralong,FirstFrameWithDataHere:LastFrameWithDataHere) = 0;
                %%%%%%%%Might have to initialize with NaNs
                if(length(RunStarts_Before)>0)

                RunStarts_Before_Frames = cellData(RunStarts_Before,1);
                RunStartFrames_Before_ReCal = RunStarts_Before_Frames-DiffHereB;
                RunsTooEarly = find(RunStartFrames_Before_ReCal<1);
                RunStartFrames_Before_ReCal(RunsTooEarly) = [];
                FRunRasterAtPeakData(IndexAcute_Extralong,RunStartFrames_Before_ReCal) = 1;
                end
                
                if(length(RunStarts_After)>0)
                RunStarts_After_Frames = cellData(RunStarts_After,1);
                RunStartFrames_After_ReCal = RunStarts_After_Frames-DiffHereA;
                RunsTooLate = find(RunStartFrames_After_ReCal>14001);
                RunStartFrames_After_ReCal(RunsTooLate) = [];
                FRunRasterAtPeakData(IndexAcute_Extralong,RunStartFrames_After_ReCal) = 1;
                end 
        
        IndexAcute_Extralong=IndexAcute_Extralong+1;
        end
    end
        
    end
    %%%%%%%%%%%%Average F.I. during (1) slow periods, (2) fwd runs, (3) the rest
    
   SlowTableInd = find(SpeedFluorTable(:,1)<6);
   
   allSlowFrames = [];
   
   for(i=1:length(SlowTableInd))
       startFrame = SpeedFluorTable(SlowTableInd(i),3);
       stopFrame = SpeedFluorTable(SlowTableInd(i),4);
       slowFrames = startFrame:1:stopFrame;
       allSlowFrames = [allSlowFrames slowFrames];
   end
   
   
   allFwdRunFrames = find(cellData(:,22)==2);
   
   %allNonOtherFrames = [allSlowFrames allFwdRunFrames'];
   allNonOtherFrames = [allFwdRunFrames'];
   
   allFrames = 1:1:(length(cellData(:,2)));
   
   allFrames(allNonOtherFrames) = [];
   
   allOtherFrames = allFrames;
   
   EachAnimalData((j-2),2) = nanmean(cellData(allSlowFrames,23));
   EachAnimalData((j-2),3) = nanmean(cellData(allFwdRunFrames,23));
   EachAnimalData((j-2),4) = nanmean(cellData(allOtherFrames,23));
    
    
    %%%%%%%%%%%%Behavior during peaks vs. the rest
    if(NSMflag==1)
     PeakActivityFrames = find(cellData(:,24)==2)';
     RegularActivityFrames = find(cellData(:,24)==1)';
     
     EachAnimalData((j-2),5) = nanmean(cellData(PeakActivityFrames,19));
     EachAnimalData((j-2),6) = nanmean(cellData(RegularActivityFrames,19));
    
    end
    
    %%%%%%%%%%%%Behavior after peaks vs. at random
   if(NSMflag==1) 
    lengthofRuns = length(allFwdRunFrames);
    if(lengthofRuns>0)
    checkContinuity = allFwdRunFrames(2:lengthofRuns) - allFwdRunFrames(1:(lengthofRuns-1));
    endsOfRunsInd = [find(checkContinuity>1)' length(allFwdRunFrames)];
    startsOfRunsInd = [1 endsOfRunsInd+1];
    FwdRunTable = [];
    for(i=1:length(endsOfRunsInd))
        FwdRunTable(i,1) = allFwdRunFrames(startsOfRunsInd(i));
        FwdRunTable(i,2) = allFwdRunFrames(endsOfRunsInd(i));
    end
    ControlInterRunIntervals = [];
    PeakInterRunIntervals = [];
    sizeOfTable = size(FwdRunTable);
    NumOfRuns = sizeOfTable(1);
    
    numRows = length(cellData(:,2));
    InterruptionToRun = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
    MoreThanIndices = find(InterruptionToRun>1);
    cellData(MoreThanIndices,17) = InterruptionToRun(MoreThanIndices);
   
    
    if(NumOfRuns>2)
        for(i=1:(NumOfRuns-1))
            EndLastRun = FwdRunTable(i,2);
            StartNextRun = FwdRunTable((i+1),1);
            continuityforRun = sum(cellData(EndLastRun:StartNextRun,17));
            if(continuityforRun<100)
                peakDuringRun = sum(cellData(EndLastRun:StartNextRun,24));
                lengthOfRun = StartNextRun-EndLastRun+1;
                if(lengthOfRun>100)
                if(peakDuringRun>lengthOfRun)
                    PeakInterRunIntervals = [PeakInterRunIntervals lengthOfRun];
                    
                else
                    ControlInterRunIntervals = [ControlInterRunIntervals lengthOfRun];
                end
                end
            end
        end
    end
    if(size(PeakInterRunIntervals)>0)
    PeakIRIs(PIRI_Ind,1:length(PeakInterRunIntervals)) = PeakInterRunIntervals
    PIRI_Ind = PIRI_Ind+1;
    end
    if(size(ControlInterRunIntervals)>0)
    ControlIRIs(CIRI_Ind,1:length(ControlInterRunIntervals)) = ControlInterRunIntervals
    CIRI_Ind = CIRI_Ind+1;
    end
    end
    %%%%%%%%%%%InterPeak Intervals
    if(length(PeakActivityFrames)>0)
    lengthofRuns = length(PeakActivityFrames-1);
    checkContinuity = PeakActivityFrames(2:lengthofRuns) - PeakActivityFrames(1:(lengthofRuns-1));
    endsOfRunsInd = [find(checkContinuity>1) length(PeakActivityFrames)];
    startsOfRunsInd = [1 endsOfRunsInd+1];
    PeakTable = [];
    for(i=1:length(endsOfRunsInd))
        PeakTable(i,1) = PeakActivityFrames(startsOfRunsInd(i));
        PeakTable(i,2) = PeakActivityFrames(endsOfRunsInd(i));
    end
    
    InterPeakIntervals = [];
    
    sizeOfTable = size(PeakTable);
    NumOfPeaks = sizeOfTable(1);
    
    if(NumOfPeaks>1)
        for(i=1:(NumOfPeaks-1))
            EndLastPeak = PeakTable(i,2);
            StartNextPeak = PeakTable((i+1),1);
            continuityforRun = sum(cellData(EndLastPeak:StartNextPeak,17));
            if(continuityforRun<100)
               
                lengthOfInterPeakInt = StartNextPeak-EndLastPeak+1;
                if(lengthOfInterPeakInt>100)
                InterPeakIntervals = [InterPeakIntervals lengthOfInterPeakInt];
                end
            end
        end
    end
    
    
    %%%%%%%%%%%%Calculate Peak to Run Times, and Controls
    
    PeaktoRunTimes = [];
  


    lengthofRuns = length(allFwdRunFrames);
    if(lengthofRuns>0)
    for(i=1:NumOfPeaks)
        EndOfPeak = PeakTable(i,1);
        RunBeginnings = FwdRunTable(:,1);
        CheckHere = RunBeginnings-EndOfPeak;
        negInd = find(CheckHere<0);
        CheckHere(negInd) = [];
        if(length(CheckHere>0))
        FramesBeforeNextRun = min(CheckHere);
        StartOfNextRun = FramesBeforeNextRun+EndOfPeak;
        
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>150);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
        
        
        
        
        continuityforRun = sum(checkVector(EndOfPeak:StartOfNextRun));
        
            if(continuityforRun==0)
                PeaktoRunTimes = [PeaktoRunTimes FramesBeforeNextRun];
            end
        end
    end
    

    if(size(PeaktoRunTimes)>0)
    Animal{anIndex} = string2;
    anIndex = anIndex+1;
    
    SimulIndex = 1;
    
    SimulPeaktoRunTimes = [];
   attempts =0;
    while(SimulIndex<100) 
        EndOfPeak = ceil(rand(1)*18000);
        RunBeginnings = FwdRunTable(:,1);
        CheckHere = RunBeginnings-EndOfPeak;
        negInd = find(CheckHere<0);
        CheckHere(negInd) = [];
        if(length(CheckHere>0))
        FramesBeforeNextRun = min(CheckHere);
        StartOfNextRun = FramesBeforeNextRun+EndOfPeak;
        
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>150);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
        
        
        continuityforRun = sum(checkVector(EndOfPeak:StartOfNextRun));
        
            if(continuityforRun==0)
                PeakActivityduringBreak = sum(cellData(EndOfPeak:StartOfNextRun,24));
                if(PeakActivityduringBreak==(StartOfNextRun-EndOfPeak+1)); 
                    
                 
                SimulPeaktoRunTimes = [SimulPeaktoRunTimes FramesBeforeNextRun];
                SimulIndex = SimulIndex+1;
                end
            end
        end
        attempts = attempts+1;
        if(attempts==3000)
            SimulIndex=100;
            SimulPeaktoRunTimes = NaN;
        end
    end
    end
    
    if(size(PeaktoRunTimes)>0)
    PeakToRuns(PeakToRun_Ind,1:length(PeaktoRunTimes)) = PeaktoRunTimes;
    PeakToRun_Ind = PeakToRun_Ind+1;
    
    SimulPeakToRuns(SimulPeakToRun_Ind,1:length(SimulPeaktoRunTimes)) = SimulPeaktoRunTimes;
    SimulPeakToRun_Ind = SimulPeakToRun_Ind+1;
    
    end
    
    
    end
        
    if(size(InterPeakIntervals)>0)
    IPIs(IPI_Ind,1:length(InterPeakIntervals)) = InterPeakIntervals;
    IPI_Ind = IPI_Ind+1;
    end
    end
   else
              ControlIRIs  =[];
       PeakIRIs  =[];
       IPIs  =[];
       PeakToRuns  =[];
       SimulPeakToRuns  =[];
       SpeedAcuteData  =[];
       CalciumAcuteData =[];
   end
    
    else
        EachAnimalData((j-2),:) = NaN;
   end
   


    end %%%%%%%This is the end of the for loop that opens each cellData file
    display(AllNumPeaks)
    display(AllMinutes)
    TotalPeakFreq = AllNumPeaks/AllMinutes;
end
    