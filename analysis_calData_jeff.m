function [speeds, cals, speedPmat, calPmat] = analysis_calData_jeff(calMats, strains, timeWindow)
%RETURNS INTRA-ANIMAL AVERAGES FOR SPECIFIED WINDOW
%ALSO RETURNS MATRIX OF 2-SAMPLE T-TEST P-VALUES, WHERE Pmat(X, Y) IS THE
%VALUE OF THE COMPARISON OF STRAIN(X) TO STRAIN(Y), AS SEEN IN THE STRAIN
%ORDER OF SPEEDS AND CALS
    
    % figure(1)
    if ~exist('strains', 'var')
        strains = fields(calMats);
    end
    
    if ~exist('timeWindow', 'var')
        timeWindow = 140:490; %35 sec beginning at t=0
    end
    
    speeds = struct();
    cals = struct();
    finalStrains = strains;
    
    for s = 1:length(strains)
        fedInd = calMats.(strains{s}).refed; %FIELD
        foodEnc = find(fedInd==1,1);
        if foodEnc <= 1
            finalStrains = finalStrains(~strcmp(finalStrains, strains{s}));
            continue
        end
        calData = BufferNaNEdges(calMats.(strains{s}).fluors); %FIELD
        speedData = BufferNaNEdges(calMats.(strains{s}).speeds); %FIELD
        
        startInd = foodEnc-140;
        stopInd = foodEnc+2400;
        numDataPoints = stopInd-startInd+1;

        anIndex = 1;
        allCalData = [];
        allSpeedData = [];

        %plot each trace
        for i = 1:length(calData(:,1))
            %subplot(4,1,1)
            %hold on;; plot(-160:2400,caData(i,startInd:stopInd),'r');
            allCalData(anIndex,1:numDataPoints) = calData(i,startInd:stopInd);
            %ylim([-1 6])
            %subplot(4,1,2)
            %hold on; plot(-160:2400,speedData(i,startInd:stopInd),'r');
            allSpeedData(anIndex,1:numDataPoints) = speedData(i,startInd:stopInd);
            %ylim([0 300])
            anIndex = anIndex+1;
        end

        for i = 1:length(calData(:,1))
            speeds.(strains{s})(i) = nanmean(allSpeedData(i,timeWindow));
            cals.(strains{s})(i) = nanmean(allCalData(i,timeWindow));
        end
    end
    
    strains = finalStrains;
    speedPmat = NaN(length(strains));
    calPmat = NaN(length(strains));
    for s1 = 1:length(strains)
        for s2 = 1:length(strains)
            [~, speedPmat(s1, s2)] = ttest2(speeds.(strains{s1}), speeds.(strains{s2}));
            [~, calPmat(s1, s2)] = ttest2(cals.(strains{s1}), cals.(strains{s2}));
        end
    end
    
    return
end