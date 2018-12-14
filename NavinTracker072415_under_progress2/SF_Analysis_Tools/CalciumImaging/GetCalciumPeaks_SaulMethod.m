function [AllSmoothData AllPeaks AllValleys] = GetCalciumPeaks_SaulMethod(cellData)


    
    
    EndsofStretches = find(cellData(:,17)>0)';
    EndsofStretches = [EndsofStretches length(cellData(:,2))];
    Begins = EndsofStretches+1;
    Begins = Begins(1:(length(Begins)-1));
    BeginningsofStretches = [1 Begins];
    display(EndsofStretches)
    StartStopData(1:length(EndsofStretches),1) = BeginningsofStretches;
    StartStopData(1:length(EndsofStretches),2) = EndsofStretches;
    
    AllSmoothData = [];
    AllDerivData = [];
    AllPeaks = [];
    AllValleys = [];
    
 for(i=1:length(StartStopData(:,1)))
        DiffHere = [];
        StartFrame = StartStopData(i,1);
        StopFrame = StartStopData(i,2);
        Data = cellData(StartFrame:StopFrame,23);

        
        
    %%%%%%%%Smoothen by local averaging of Speed and Ang Speed
    SmootheningSize = 10;
    HalfSmoothingSize = SmootheningSize/2;        

    %%%%%%%%%Smoothen Data
    DataLen = length(Data);
    SmoothData = [];
    SmoothData(1:DataLen) = NaN;
    for(i=(1+HalfSmoothingSize):(DataLen-HalfSmoothingSize))
           SmoothData(i) = nanmean(Data((i-HalfSmoothingSize):1:(i+HalfSmoothingSize)));
      
    end
    
    AllSmoothData = [AllSmoothData SmoothData];
    
    [peaks,valleys] = peakfind(SmoothData,.35);
    if(size(peaks,1)>0)
    peaks(:,1) = peaks(:,1)+StartFrame-1;
    end
    if(size(valleys,1)>0)
    valleys(:,1) = valleys(:,1)+StartFrame-1;
    end
    AllPeaks = [AllPeaks; peaks];
    AllValleys = [AllValleys; valleys];
    
    
    
    
    
    
%         StepSize = 26;
%         if(length(Data)>(StepSize*2))
%         
%         for(j=(1+StepSize):(length(SmoothData)-StepSize));
%             DiffHere(j-StepSize) = SmoothData(j+StepSize)-SmoothData(j-StepSize);
%         end
%         Beginning(1:StepSize) = DiffHere(1);
%         Ending(1:StepSize) = DiffHere(end);
%         DiffHere = [Beginning DiffHere Ending];
%         %DataForStretchFinder = zeros(length(cellData(:,1)));
%        % DataForStretchFinder(StartFrame:StopFrame) = DiffHere;
%         AllDerivData = [AllDerivData DiffHere];
%         %[AllStretchFrames_Temp StretchTable_Temp FinalStretches_Temp FinalStretchTable_Temp] = findPositiveStretches(DataForStretchFinder,cellData)
%         %StretchTable = [StretchTable; StretchTable_Temp];
%         %FinalStretchTable = [FinalStretchTable; FinalStretchTable_Temp];
%         %AllStretchFrames = [AllStretchFrames AllStretchFrames_Temp];
%         %FinalStretches = [FinalStretches FinalStretches_Temp];
%         
%         else
%             DiffHere(1:length(Data)) = NaN
%             AllDerivData = [AllDerivData DiffHere];
%         end
 end
    
 
   % PositiveStretches(1:length(Data)) = 1;
   % PositiveStretches(AllStretchFrames) = 2;
    
   % FinalPositiveStretches(1:length(Data)) = 1;
   % FinalPositiveStretches(FinalStretches) = 2;
 
    
end