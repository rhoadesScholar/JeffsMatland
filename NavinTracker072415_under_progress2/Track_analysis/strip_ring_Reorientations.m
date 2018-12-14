function Reorientations = strip_ring_Reorientations(Reorientations)
% Reorientations = strip_ring_Reorientations(Reorientations)
% strips ring info from Reorientations elements

for(i=1:length(Reorientations))
    if(~isempty(strfind(Reorientations(i).class,'ring')))
        Reorientations(i).class = Reorientations(i).class(1:end-5);
    end
end

return;
end
