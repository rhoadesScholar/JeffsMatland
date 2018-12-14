
function statemap = getStateAuto_550(trackData,binSize) % binSize in Frames
    binnedSpeed = binSpeed(trackData,binSize);
    binnedAngSpeed = binAngSpeed(trackData,binSize)
    statemap = getState(binnedSpeed,binnedAngSpeed,270)
end
