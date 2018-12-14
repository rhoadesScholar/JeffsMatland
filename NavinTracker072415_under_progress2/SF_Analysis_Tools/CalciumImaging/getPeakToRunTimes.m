function [peakToRunTable peakToRunTable_Control] = getPeakToRunTimes(folder)

PathofFolder = sprintf('%s',folder);
fileList = ls(PathofFolder);
numFiles = length(fileList(:,1));


PeakToRun_Ind = 1;
SimulPeakToRun_Ind = 1;
    %%%Set up for loop for each animal
    
 for(j=3:1:numFiles)
     string2 = deblank(fileList(j,:));
     fileToOpen = sprintf('%s/%s',PathofFolder,string2);
        
    [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,1);
    
    [AllHighCaRegions AllHighCaRegions_Speed AllHighCaRegions_FRuns checkPeakOverlap_Reg checkPeakOverlap_noSp AllDiffBins CalciumPeakProps EveryCalcium AllPeakStarts] = FindAllCaRegions_byFrame(folder,j,.55)
    
    
    
    PeaktoRunTimes = [];
    
    %%%%FwdRunTable
    allFwdRunFrames = find(cellData(:,22)==2);
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

    sizeOfTable = size(FwdRunTable);
    NumOfRuns = sizeOfTable(1);

    %%%%%%

  
    
    for(i=1:length(AllPeakStarts))
        StartOfPeak = AllPeakStarts(i);
        RunBeginnings = FwdRunTable(:,1);
        CheckHere = RunBeginnings-StartOfPeak;
        negInd = find(CheckHere<0);
        CheckHere(negInd) = [];
        if(length(CheckHere>0))
        FramesBeforeNextRun = min(CheckHere);
        StartOfNextRun = FramesBeforeNextRun+StartOfPeak;
        FramesBeforeNextRun_time = cellData(StartOfNextRun,1)-cellData(StartOfPeak,1);
        
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>150);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
        
        
        
        
        continuityforRun = sum(checkVector(StartOfPeak:StartOfNextRun));
        
            if(continuityforRun==0)
                PeaktoRunTimes = [PeaktoRunTimes FramesBeforeNextRun_time];
            end
        end
    end
    

    if(length(PeaktoRunTimes)>0)

    
    SimulIndex = 1;
    
    SimulPeaktoRunTimes = [];
   attempts =0;
    while(SimulIndex<100) 
        StartOfPeak = ceil(rand(1)*18000);
        RunBeginnings = FwdRunTable(:,1);
        CheckHere = RunBeginnings-StartOfPeak;
        negInd = find(CheckHere<0);
        CheckHere(negInd) = [];
        if(length(CheckHere>0))
        FramesBeforeNextRun = min(CheckHere);
        StartOfNextRun = FramesBeforeNextRun+StartOfPeak;
        FramesBeforeNextRun_time = cellData(StartOfNextRun,1)-cellData(StartOfPeak,1);
        
        checkContinuity = [];
        numRows = length(cellData(:,1));
        checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
        MoreThanIndices = find(checkContinuity>150);
        checkVector = [];
        checkVector(1:length(cellData(:,1))) = 0;
        checkVector(MoreThanIndices)=1;
        
        
        continuityforRun = sum(checkVector(StartOfPeak:StartOfNextRun));
        
            if(continuityforRun==0)
                FramesduringBreak = StartOfPeak:StartOfNextRun;
                PeakFrames = AllPeakStarts;
                PeaksDuringBreak = [];
                PeaksDuringBreak = intersect(FramesduringBreak,PeakFrames);
     
                %if(length(PeaksDuringBreak)==0) 
          
                SimulPeaktoRunTimes = [SimulPeaktoRunTimes FramesBeforeNextRun_time];
                SimulIndex = SimulIndex+1;
                %end
            end
        end
        attempts = attempts+1;
        if(attempts==3000)
            SimulPeaktoRunTimes = NaN;
            SimulIndex=100;
            
        end
    end
    end
    
    if(length(PeaktoRunTimes)>0)
    peakToRunTable(PeakToRun_Ind,1:length(PeaktoRunTimes)) = PeaktoRunTimes;
    PeakToRun_Ind = PeakToRun_Ind+1;
    
    peakToRunTable_Control(SimulPeakToRun_Ind,1:length(SimulPeaktoRunTimes)) = SimulPeaktoRunTimes;
    SimulPeakToRun_Ind = SimulPeakToRun_Ind+1;
    
    end
    
    
    end
        

    end
 
end