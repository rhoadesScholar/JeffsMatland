function rawTracks = ring_distance_interpolate(rawTracks)

for(TN=1:length(rawTracks))
    
    idx = ~isnan(rawTracks(TN).RingDistance);
    
    if(sum(idx)>=2)
        
        y = rawTracks(TN).RingDistance(idx);
        x = rawTracks(TN).Frames(idx);
        
        rawTracks(TN).RingDistance = interp1(x,y,rawTracks(TN).Frames);
        
        % interpl returns NaN for elements before and after the first and last
        % values .. so set these to the nearest value
        
        i=1;
        if(isnan(rawTracks(TN).RingDistance(i)))
            while(isnan(rawTracks(TN).RingDistance(i)))
                i=i+1;
            end
            j=i-1;
            rawTracks(TN).RingDistance(1:j) = rawTracks(TN).RingDistance(i);
        end
        
        i=length(rawTracks(TN).RingDistance);
        if(isnan(rawTracks(TN).RingDistance(i)))
            
            while(isnan(rawTracks(TN).RingDistance(i)))
                i=i-1;
            end
            j=i+1;
            rawTracks(TN).RingDistance(j:end) = rawTracks(TN).RingDistance(i);
            
        end
    end
end

return;

end
