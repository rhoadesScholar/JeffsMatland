function displayPositionCaIm(folder,columnofInterest)

calcium_struc(1:end) = [];

for(i=1:16)
    calcium_struc(i).Data = [];
end

PathofFolder = sprintf('%s',folder);
fileList = ls(PathofFolder);
numFiles = length(fileList(:,1));
for(j=3:1:numFiles)
     string2 = deblank(fileList(j,:));
     fileToOpen = sprintf('%s/%s',PathofFolder,string2);
        
    [cellData  FinalStretchTable ForwardRunStarts AllSmoothData] = ProcessCalciumImaging(fileToOpen,1);


    numRows = length(cellData(:,23));
    
    for(i=1:numRows)
        Calc_here = cellData(i,columnofInterest);
        X_here = ceil(cellData(i,2)/128);
        Y_here = ceil(cellData(i,3)/128);
        if(X_here>0)
        position_struc = ((X_here-1)*4)+Y_here;
        calcium_struc(position_struc).Data = [calcium_struc(position_struc).Data Calc_here];
        end
    end

end
%%%%%%%Make it into a matrix
calcium_matrix =[];
for(i=1:16)
    
    Xpos = ceil(i/4);
    if(rem(i,4)==0)
        Ypos = 4;
    else
        Ypos = rem(i,4);
    end
    if(length(calcium_struc(i).Data)>3)
    calcium_matrix(Xpos,Ypos) = nanmean(calcium_struc(i).Data);
    else
        calcium_matrix(Xpos,Ypos) = NaN;
    end
end

imagesc(calcium_matrix)

end
