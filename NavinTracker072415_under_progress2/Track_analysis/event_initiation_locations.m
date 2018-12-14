function [x,y] = event_initiation_locations(Tracks, eventtype)

x=[]; y=[];

for(i=1:length(Tracks))
   for(j=1:length(Tracks(i).Reorientations)) 
        if(~isempty(regexpi(Tracks(i).Reorientations(j).class,eventtype)))
            idx = Tracks(i).Reorientations(j).start;
            x = [x Tracks(i).SmoothX(idx)];
            y = [y Tracks(i).SmoothY(idx)];
        end
   end
end

return;
end
