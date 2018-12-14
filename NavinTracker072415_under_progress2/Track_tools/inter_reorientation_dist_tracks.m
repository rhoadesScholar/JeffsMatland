function ipd = inter_reorientation_dist_tracks(Tracks, t1, t2)

if(nargin<2)
   t1=0;
   t2=max_struct_array(Tracks,'Time');
end

ipd = [];
for(i=1:length(Tracks))
    
    if(Tracks(i).Time(1) >= t1 && Tracks(i).Time(end) <= t2)
        ipd = [ipd   inter_reorientation_dist(Tracks(i), t1, t2)];
    end
        
end


return;
end 

function ipd = inter_reorientation_dist(Track, t1, t2)

ipd=[];

if(isempty(Track.Reorientations))
    return;
end


if(Track.Time(end)-Track.Time(1)<250)
    return;
end

starttimes=[];
for(i=1:length(Track.Reorientations))
    if(~isnan(Track.Reorientations(i).startRev) && ~isnan(Track.Reorientations(i).startTurn))
        if(floor(Track.State(Track.Reorientations(i).start))~=num_state_convert('ring'))
            starttimes = [starttimes Track.Time(Track.Reorientations(i).start)];
        end
    end
end

ipd = diff(starttimes);

% if(find(ipd==0))
%     starttimes
%     for(i=1:length(Track.Reorientations))
%         Track.Reorientations(i)
%     end
%     pause
% end

return;
end


% ipd = inter_reorientation_dist_tracks(mergedTracks, 0, 15*60);
% [cumdist, t] = cumulative_distribution(ipd);
% semilogy(t,cumdist,'.');
