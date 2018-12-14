function maxSpeed = getMaxSpeed(finalTracks, bin)

strains = fields(finalTracks);
maxi = zeros(1,length(strains));

for s = 1:length(strains)
    binnedSpeed = cell2mat(arrayfun (@(tracks) nanbinSpeed(tracks, bin), finalTracks.(strains{s}),...
        'UniformOutput', false));
    maxi(s) = max(arrayfun (@(x) max(x.Speed), binnedSpeed));
end

maxSpeed = max(maxi)

end