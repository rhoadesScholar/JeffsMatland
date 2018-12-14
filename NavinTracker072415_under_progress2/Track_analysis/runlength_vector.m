function  runlength  = runlength_vector(Tracks)

global Prefs;

runlength = [];

k=1;

for(i=1:length(Tracks))
    
    j=1; len = length(Tracks(i).AngSpeed);
    while(j<len)
        
        % walk past NaN marking missing frames
        while(isnan(Tracks(i).AngSpeed(j)))
            j=j+1;
            if(j==len)
                break;
            end
        end
        
        a=0;
        angspeed=[];
        while(~isnan(Tracks(i).AngSpeed(j)))
            
            a=a+1;
            angspeed(a) = Tracks(i).AngSpeed(j);
            
            j=j+1;
            if(j==len)
                break;
            end
        end
        
        reori = zeros(1,length(angspeed));
        idx = find(abs(angspeed) > Prefs.AngSpeedThreshold);
        reori(idx) = 1;
        reori(1) = 1;
        iv = inter_event_intervals(reori);
        
        runlength = [runlength iv];
        
        clear('reori');
        clear('angspeed');
    end
    
end

runlength = runlength./Tracks(1).FrameRate;

return;

end

function  interval_vector = inter_event_intervals(event_vector)
% interval_vector = inter_event_intervals(event_vector)
% event_vector has 1 for an event initiation, NaN for missing frames or
% timepoints
% returns interval_vector which contains number of array elements (ie:
% frames) between successive 1's

interval_vector = diff(find(event_vector==1));

return;

end 

