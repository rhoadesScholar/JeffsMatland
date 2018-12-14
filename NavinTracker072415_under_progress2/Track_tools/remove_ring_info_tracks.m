function Tracks =  remove_ring_info_tracks(Tracks)
% ringless_Tracks =  remove_ring_info_tracks(Tracks)
% removes ring info from the tracks

for(i=1:length(Tracks))
    for(j=1:length(Tracks(i).Reorientations))
        if(~isempty(strfind(Tracks(i).Reorientations(j).class,'ring')))
            Tracks(i).Reorientations(j).class = Tracks(i).Reorientations(j).class(1:end-5);
        end
    end
    Tracks(i).State = AssignLocomotionState(Tracks(i));
end

return;
end
