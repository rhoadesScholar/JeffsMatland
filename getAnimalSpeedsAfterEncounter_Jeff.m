function [Data_EachAnim_Avg, Data, pMat, varargout] = getAnimalSpeedsAfterEncounter_Jeff(Data, lags, strains, timeWindow, framespan)%Data should be refeeds, timeWindow in frames
%RETURNS INTRA-ANIMAL AVERAGES FOR SPECIFIED WINDOW
%ALSO RETURNS MATRIX OF 2-SAMPLE T-TEST P-VALUES, WHERE Pmat(X, Y) IS THE
%VALUE OF THE COMPARISON OF STRAIN(X) TO STRAIN(Y), AS SEEN IN THE STRAIN
%ORDER OF SPEEDS

    if ~exist('strains', 'var')
        strains = fields(Data);
    end
    if ~exist('timeWindow', 'var')
            timeWindow = 60:300; %from t_encounter+20sec until t_encounter+100sec @frameRate = 3
    end
    nYes = exist('framespan', 'var');
    
    IndOfInterest = timeWindow + lags{1};
    for s = 1:length(strains)
        Data.(strains{s}) = convertStruct2Mat_noRecenter(Data.(strains{s}), lags);
        DataMatrix.(strains{s}) = NaN(length(Data.(strains{s})(:,1)), length(IndOfInterest));
        for i=1:length(Data.(strains{s})(:,1))
            speedHere = Data.(strains{s})(i,IndOfInterest);
            DataMatrix.(strains{s})(i,1:length(IndOfInterest)) = speedHere;
        end

        Data_EachAnim_Avg.(strains{s}) = nanmean(DataMatrix.(strains{s}),2); %convert to speed vector

%         plot(nanmean(Data.(strains{s})))
        hold on;
    end
    
    pMat = NaN(length(strains));
    for s1 = 1:length(strains)
        for s2 = 1:length(strains)
            [~, pMat(s1, s2)] = ttest2(Data_EachAnim_Avg.(strains{s1}), Data_EachAnim_Avg.(strains{s2}));
        end
    end
    
    if nYes
        varargout{1} = getN(Data, framespan, lags);
    end
    
    return
end

function speedMatrix = convertStruct2Mat_noRecenter(dataStruc, lags)

    numAn = length(dataStruc);
    speedMatrix = NaN(numAn,lags{1} + lags{2} + 1);

    for i = 1:numAn
        speedMatrix(i,:) = dataStruc(i).Speed;
    end
    
    return
end

function n = getN(Data, framespan, lags)

    strains = fields(Data);
    for s = 1:length(strains)
        n.(strains{s}) = min(sum(~isnan(Data.(strains{s})(:,[lags{1}+framespan(1):lags{1}+framespan(2)])), 1)) ;
    end
    
    return
end