function [cellData FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(FileName,NSMflag,StretchLength,PositiveDataCutoff,FluorChangeCutoff)

if(nargin<5)
    StretchLength = 55;
    PositiveDataCutoff = .04;
    FluorChangeCutoff = 1.4;
end


cellData = [];
cellData = csvread(FileName);

FrameRate = 10; %fps


numRows = length(cellData(:,1));

checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);


%%%%%%%%Use Saul Correction

Saul_Corr=0;
if(Saul_Corr==1)
    
    %%%%Load calibration matrix
    ps=load('devignettecal.mat');
    calibrationmatrix=ps.p;
    cell_out = [];
    temp_out = []
    for(i=1:numRows)
        y_coor = round(cellData(i,2));
        x_coor = round(cellData(i,3));
        %display(cellData(i,:))
        if(y_coor<1)
            cellData(i,12) = NaN;
        else
        cell_fluor = cellData(i,11);
        cell_out = (double(cell_fluor)-calibrationmatrix(2,x_coor,y_coor))/calibrationmatrix(1,x_coor,y_coor);
        backgr_fluor = cellData(i,6);
        backgr_out = (double(backgr_fluor)-calibrationmatrix(2,x_coor,y_coor))/calibrationmatrix(1,x_coor,y_coor);
        cellData(i,12) = cell_out - (16*backgr_out);
        end
    end
end
        
        


%%%%Find duplicate rows
LessThanIndices = find(checkContinuity<1);
allDeletedRows = [];
for(i=1:length(LessThanIndices))
    Value = checkContinuity(LessThanIndices(i));
    rowsToDelete = (LessThanIndices(i)+Value):LessThanIndices(i);
    allDeletedRows = [allDeletedRows rowsToDelete];
end

%%%%Delete tracking mistakes

cellData(allDeletedRows,:) = [];

%%%%Column 17: all values are 0, except rows that define the end of a
%%%%consecutive stretch (value 1, in that case)
checkContinuity = [];
numRows = length(cellData(:,1));
checkContinuity = cellData(2:numRows,1) - cellData(1:(numRows-1),1);
MoreThanIndices = find(checkContinuity>1);
cellData(:,17) = 0;
cellData(MoreThanIndices,17) = 1;



%%%%%%%%%% SPEED AND ANGULAR SPEED
cellData(:,18) = NaN;


%%%%%Calculate Speed and Angular Speed
SpeedStepSize = 10

Xdif = CalcDif(cellData(:,2), SpeedStepSize) * FrameRate;
Ydif = -CalcDif(cellData(:,3), SpeedStepSize) * FrameRate;

% direction 0 = Up/North
ZeroYdifIndexes = find(Ydif == 0);
Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")



NegYdifIndexes = find(Ydif < 0);
Direction(NegYdifIndexes) = -Direction(NegYdifIndexes);
PosYdifIndexes = find(Ydif>0);
Index1 = find(Xdif(PosYdifIndexes) < 0);
Index2 = find(Xdif(PosYdifIndexes) > 0);
Direction(PosYdifIndexes(Index1)) = -(Direction(PosYdifIndexes(Index1)) + 180);
Direction(PosYdifIndexes(Index2)) = -(Direction(PosYdifIndexes(Index2)) - 180);
Speed = sqrt(Xdif.^2 + Ydif.^2);

AngSpeed = CalcAngleDif(Direction, FrameRate)*FrameRate;

cellData(:,18) = Speed;
cellData(:,20) = AngSpeed;



%%%%%%%%%%Remove Data at edges when cell gets lost
for(i=6:(numRows-5))
    if(sum(cellData((i-5):1:(i+5),17))~=0)
        cellData(i,18) = NaN;
        cellData(i,20) = NaN;
        %cellData(i,18) = sqrt(((cellData(i+10,2)-cellData(i-10,2))^2)+((cellData(i+10,3)-cellData(i-10,3))^2));
    end
end



%%%%%%%%Smoothen by local averaging of Speed and Ang Speed
SmootheningSize = 20;
HalfSmoothingSize = SmootheningSize/2;

%%%%%%%%%Column 19 = smoothened speed
cellData(:,19) = NaN;
for(i=(1+HalfSmoothingSize):(numRows-HalfSmoothingSize))
    testNans = isnan(cellData((i-HalfSmoothingSize):1:(i+HalfSmoothingSize),18));
    if((sum(testNans))==0)
        cellData(i,19) = nanmean(cellData((i-HalfSmoothingSize):1:(i+HalfSmoothingSize),18));
    end
end


%%%%%%%%Column 21 = smoothened ang speed
cellData(:,21) = NaN;
for(i=(1+HalfSmoothingSize):(numRows-HalfSmoothingSize))
    testNans = isnan(cellData((i-HalfSmoothingSize):1:(i+HalfSmoothingSize),20));
    if((sum(testNans))==0)
        cellData(i,21) = nanmean(abs(cellData((i-HalfSmoothingSize):1:(i+HalfSmoothingSize),20)));
    end
end

%%%%%%%%%%%%%%Look for forward runs
%%%%Average worm length at 5xobjective/demagIN is 200 pixels

%%%%%%%%%%Find stretches where the cell moves at least 200 pixels without
%%%%%%%%%%AngSpeed>100

Wormlength = 200; %pixels
MaxHypSpeed = 60; %pixels/sec
MinStretchDuration = Wormlength/MaxHypSpeed*FrameRate; % in frames
%%%%%%%Find stretches of Low AngSpeed
ForwardRunInd = [];
ForwardRunStarts = [];

currentRun = 0;
JustOne = 0;
%for(i=5300:5600)
for (i=2:numRows)
            if (abs(cellData(i,20)) < 120)
                currentRun = currentRun + 1;
                JustOne = 0;
                
               
            else 
                if(JustOne==0)
                    JustOne=1;
                    currentRun = currentRun + 1;
             
                else
                LastRun = currentRun;
                JustOne=0;
                currentRun  = 0;
                
                if (LastRun >= MinStretchDuration)
                        EndIndex = i;
                        StartIndex = i-LastRun;
                        XStart = cellData(StartIndex,2);
                        YStart = cellData(StartIndex,3);
                        XEnd = cellData(EndIndex,2);
                        YEnd = cellData(EndIndex,3);
                        DistTravDuringStretch = sqrt(((XEnd-XStart)^2)+((YEnd-YStart)^2));
                    
                        if(DistTravDuringStretch >= Wormlength)
                            %%%%Then this is a forward run; log frames
                            ForwardRunInd = [ForwardRunInd [StartIndex:1:EndIndex]];
                            ForwardRunStarts = [ForwardRunStarts StartIndex];
                        end
                end
                end
            end
end

ForwardRunLog = [];
ForwardRunLog(1:numRows) = 1;
if(length(ForwardRunInd>1))
ForwardRunLog(ForwardRunInd) = 2;
end

cellData(:,22) = ForwardRunLog;



%%%%%Remove outlier data

cutoff = nanmean(cellData(:,12))-(2*nanstd(cellData(:,12)));
LowDataIndex = find(cellData(:,12)<cutoff);
cellData(LowDataIndex,12) = NaN;

%%%%%Remove isolated data points

EndsofStretches = find(cellData(:,17)>0);
BeginningsofStretches = EndsofStretches+1;
AllDatatoNaN = [EndsofStretches BeginningsofStretches];
cellData(AllDatatoNaN,12) = NaN;


%%%%%%%Convert fluorescence to a 0-1 scale = Column 23


newCellData = cellData(:,12) - min(cellData(:,12));
newCellData = newCellData./max(newCellData);
cellData(:,23) = newCellData;
% 
% newCellData = cellData(:,12) / min(cellData(:,12));
% cellData(:,23) = newCellData;

%cellData(:,25) = ConvertCalciumVectorToSNR(cellData(:,23));


%%%%%%%Try background subtraction by division = Column 26

%cellData(:,26) = cellData(:,11)./cellData(:,6);


% %%%%%%Convert backgr subtr by division to 0-1 scale = Column 27
% newCellDataDiv = cellData(:,26) - min(cellData(:,26));
% newCellDataDiv = newCellDataDiv./max(newCellDataDiv);
% cellData(:,27) = newCellDataDiv;




subplot(4,1,1);
plotyy(cellData(:,1)/600,(cellData(:,19).*(0.2/41)),cellData(:,1)/600,cellData(:,23));  %%%%%Adjust for 600frames/minute and 0.2mm=41pixels at 5xmag w/ 0.63x demag

subplot(4,1,2);
plot(cellData(:,1)/600,cellData(:,22));
axis([0 30 -1 3]);
% 
% subplot(7,1,3)
% 
if(NSMflag==1)
 [AllDerivData AllSmoothData] = GetCalciumPeaks(cellData);
 [PositiveStretches FinalPositiveStretches StretchTable FinalStretchTable] = findPositiveStretches(AllDerivData,cellData,StretchLength,PositiveDataCutoff,FluorChangeCutoff);

 %%%%%%%%Convert FinalStretchTable to cellData(;,24) = 1 if not during a
 %%%%%%%%peak, and =2 if during a peak
if(NSMflag==1)
    if(size(FinalStretchTable,1)>0)
    PeakVector = getPeakVector(cellData,FinalStretchTable);

    cellData(:,24) = PeakVector;
    else
        PeakVector = [];
        cellData(:,24) = 1;
    end
    
    
end
 
 
 
 
% 
% plot(cellData(:,1),AllSmoothData);
% 
% 
% 
% subplot(7,1,4)
% plot(cellData(:,1),AllDerivData);
% 
% 
% 
% subplot(7,1,5)
% plot(cellData(:,1),PositiveStretches);
% axis([0 18000 -1 3]);
% 
 subplot(4,1,3)
 plot(cellData(:,1)/600,FinalPositiveStretches);
 axis([0 30 -1 3]);
 
%   subplot(4,1,4)
%  plot(cellData(:,1)/600,cellData(:,24));
%  axis([0 30 -1 3]);
else
    FinalStretchTable = [];
    AllSmoothData =[];
end
% 

end


