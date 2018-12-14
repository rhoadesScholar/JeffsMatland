function [AllCalciumDerivData AllSmoothCalciumData AllSpeedDerivData AllSmoothSpeedData AllCalciumDerivErrorData] = GetSpeedCalciumDerivs(cellData,SmootheningSize,StepSize,DerivSmootheningSize)

    
    EndsofStretches = find(cellData(:,17)>0)';
    EndsofStretches = [EndsofStretches length(cellData(:,2))];
    Begins = EndsofStretches+1;
    Begins = Begins(1:(length(Begins)-1));
    BeginningsofStretches = [1 Begins];
    StartStopData(1:length(EndsofStretches),1) = BeginningsofStretches;
    StartStopData(1:length(EndsofStretches),2) = EndsofStretches;
    
    AllSmoothCalciumData = [];
    AllSmoothSpeedData = [];
    AllCalciumDerivData = [];
    AllCalciumDerivErrorData =[];
    AllSpeedDerivData = [];
    
 for(i=1:length(StartStopData(:,1)))
        DiffHereCalcium = [];
        DiffHereSpeed =[];
        StartFrame = StartStopData(i,1);
        StopFrame = StartStopData(i,2);
        CalciumData = cellData(StartFrame:StopFrame,23);
        SpeedData = cellData(StartFrame:StopFrame,19);
        
        
    %%%%%%%%Smoothen by local averaging of Speed and Ang Speed
    HalfSmoothingSize = SmootheningSize/2;        

    %%%%%%%%%Smoothen Data
    DataLen = length(CalciumData);
    SmoothCalciumData = [];
    SmoothSpeedData = [];
    SmoothCalciumData(1:DataLen) = NaN;
    SmoothSpeedData(1:DataLen) = NaN;
    for(k=(1+HalfSmoothingSize):(DataLen-HalfSmoothingSize))
           SmoothCalciumData(k) = nanmean(CalciumData((k-HalfSmoothingSize):1:(k+HalfSmoothingSize)));
           SmoothSpeedData(k) = nanmean(SpeedData((k-HalfSmoothingSize):1:(k+HalfSmoothingSize)));
    end

    
    AllSmoothCalciumData = [AllSmoothCalciumData SmoothCalciumData];
    AllSmoothSpeedData = [AllSmoothSpeedData SmoothSpeedData];

        if(length(CalciumData)>(StepSize*2))
        DiffHereCalcium = [];
        DiffHereSpeed = [];
        for(j=(1+StepSize):(length(SmoothCalciumData)-StepSize));
            DiffHereCalcium(j-StepSize) = SmoothCalciumData(j+StepSize)-SmoothCalciumData(j-StepSize);
            DiffHereSpeed(j-StepSize) = SmoothSpeedData(j+StepSize)-SmoothSpeedData(j-StepSize);
        end
        Beginning(1:StepSize) = NaN;
        Ending(1:StepSize) = NaN;
        DiffHereCalcium = [Beginning DiffHereCalcium Ending];
        

        DiffHereSpeed = [Beginning DiffHereSpeed Ending];
        
        
        
         %%%Smoothen Deriv Data
        %DerivSmootheningSize = 20;
        NewDiffHereCalcium = [];
        NewDiffHereCalcium(1:DataLen) = NaN;
        NewDiffHereCalcium_std = [];
        NewDiffHereCalcium_std(1:DataLen) = NaN;
        NewDiffHereSpeed = [];
        NewDiffHereSpeed(1:DataLen) = NaN;
     for(l=((DerivSmootheningSize/2)+1):(DataLen-(DerivSmootheningSize/2)))
         NewDiffHereCalcium(l) = nanmean(DiffHereCalcium((l-(DerivSmootheningSize/2)):(l+(DerivSmootheningSize/2))));
         NewDiffHereCalcium_std(l) = nanstd(DiffHereCalcium((l-(DerivSmootheningSize/2)):(l+(DerivSmootheningSize/2))));
         NewDiffHereSpeed(l) = nanmean(DiffHereSpeed((l-(DerivSmootheningSize/2)):(l+(DerivSmootheningSize/2))));
     end     
   
        
        %DataForStretchFinder = zeros(length(cellData(:,1)));
       % DataForStretchFinder(StartFrame:StopFrame) = DiffHere;
        AllCalciumDerivData = [AllCalciumDerivData NewDiffHereCalcium];
        AllCalciumDerivErrorData = [AllCalciumDerivErrorData NewDiffHereCalcium_std];
        AllSpeedDerivData = [AllSpeedDerivData NewDiffHereSpeed];
        %[AllStretchFrames_Temp StretchTable_Temp FinalStretches_Temp FinalStretchTable_Temp] = findPositiveStretches(DataForStretchFinder,cellData)
        %StretchTable = [StretchTable; StretchTable_Temp];
        %FinalStretchTable = [FinalStretchTable; FinalStretchTable_Temp];
        %AllStretchFrames = [AllStretchFrames AllStretchFrames_Temp];
        %FinalStretches = [FinalStretches FinalStretches_Temp];
        
        else
            DiffHereCalcium = [];
            DiffHereCalcium(1:length(CalciumData)) = NaN;
            DiffHereCalciumError = [];
            DiffHereCalciumError(1:length(CalciumData)) = NaN;
            DiffHereSpeed = [];
            DiffHereSpeed(1:length(CalciumData)) = NaN;
            AllCalciumDerivData = [AllCalciumDerivData DiffHereCalcium];
            AllCalciumDerivErrorData = [AllCalciumDerivErrorData DiffHereCalciumError];
            AllSpeedDerivData = [AllSpeedDerivData DiffHereSpeed];
        end
        
        
 end

 
    
end