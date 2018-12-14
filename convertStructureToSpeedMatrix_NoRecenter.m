% function to give a tracks structure, and get an aligned data matrix where
% t=0 is always at same position

function SpeedMatrix = convertStructureToSpeedMatrix_NoRecenter(dataStruc)

    numAn = length(dataStruc);
    SpeedMatrix(1:numAn,1:100000) = NaN;

    for i=1:numAn
        b = dataStruc(i).refeedIndex;
        a = 1;
        c = length(dataStruc(i).Speed);
        framesBeforeEnc = b-a;
        d = 50001-framesBeforeEnc; %50001 is center point
        f = d+c-1;
        SpeedMatrix(i,d:f) = dataStruc(i).Speed;
    end
    
    return
end


