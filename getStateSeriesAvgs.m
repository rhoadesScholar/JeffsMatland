function stateAvgs = getStateSeriesAvgs(stateTracks, field, stateTypes)

if (nargin < 3)
    stateTypes = {'dwelling' 'roaming'};
end

for sT = 1:length(stateTypes)
    stateAvgs.(stateTypes{sT}) = getSeriesAvgs(stateTracks.(stateTypes{sT}), field);
end

end