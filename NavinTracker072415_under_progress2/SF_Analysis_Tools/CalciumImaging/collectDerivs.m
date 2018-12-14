function [AllCalcium AllSmoothCalciumData AllSpeed AllSmoothSpeedData AllCalciumDerivErrorData] = collectDerivs(folder,SpeedAve,HalfDerivStep,DerivSmooth)    
PathofFolder = sprintf('%s',folder);
 %%%%%%%%%%%%%%%%%%%
fileList = ls(PathofFolder);
numFiles = length(fileList(:,1));
AllCalcium = struct('Calcium',[]);
AllSpeed = struct('Speed',[]);
AllSmoothCalciumData = struct('Calcium',[]);
AllSmoothSpeedData = struct('Speed',[]);
AllCalciumDerivErrorData = struct('Error',[]);
for(j=3:1:numFiles)
     string2 = deblank(fileList(j,:));
     fileToOpen = sprintf('%s/%s',PathofFolder,string2);
        
     [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,0);
   
[AllCalcium(j-2).Calcium AllSmoothCalciumData(j-2).Calcium AllSpeed(j-2).Speed AllSmoothSpeedData(j-2).Speed AllCalciumDerivErrorData(j-2).Error] = GetSpeedCalciumDerivs(cellData,SpeedAve,HalfDerivStep,DerivSmooth);
end