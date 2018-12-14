function  WormRingDistances = calc_WormRingDistances(Frame, Ring, WormCoordinates)

global Prefs;

num_worms = length(WormCoordinates(:,1));

if(isempty(Ring.ComparisonArrayX)) % the ring must exist to measure distances, so just assign a large distance
    WormRingDistances = zeros(1, num_worms);
    WormRingDistances = WormRingDistances + 1e6;
    return;
end

WormRingDistances(1:num_worms) = NaN;

if (mod(Frame,Prefs.FrameRate) == 1) % measure the distances for the first frame of each second ... will interpolate elsewhere
    for(i = 1:num_worms)
        
        XCentroid = WormCoordinates(i,1) * Ring.ComparisonArrayX;
        YCentroid = WormCoordinates(i,2) * Ring.ComparisonArrayY;
        
        RingDX = Ring.RingX - XCentroid;
        RingDY = Ring.RingY - YCentroid;
        
        D = RingDX.^2 + RingDY.^2;
        D1 = min(D);
        
        WormRingDistances(i) = sqrt(D1);
    end
    
    clear('XCentroid');
    clear('YCentroid');
    clear('RingDX');
    clear('RingDY');
    clear('D');
    clear('D1');
end

return;
end
