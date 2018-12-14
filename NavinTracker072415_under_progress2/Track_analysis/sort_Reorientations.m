function Reorientations = sort_Reorientations(Reorientations)

start_reori=[];
for(w=1:length(Reorientations))
    start_reori = [start_reori, Reorientations(w).start];
end
[~, idx] = sort(start_reori);
Reorientations = Reorientations(idx);
clear('idx'); clear('start_reori');

return;
end
