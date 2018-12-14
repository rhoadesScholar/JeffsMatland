function Tracks = ring_distance_mm_to_custom_metric(inputTracks)

for(i=1:length(inputTracks))
    t1 = inputTracks(i);
    
    t1.Reorientations = strip_ring_Reorientations(t1.Reorientations);
    t1 = edit_Reorientations(t1);
    t1.mvt_init = mvt_init_vector(t1);
    
    t1.custom_metric = t1.RingDistance*t1.PixelSize;
    Tracks(i) = t1;
    
    clear('t1');
end

return;
end
