function frame = DrawTrack(frame, Path, Track)

for point = 1:length(Path)
    if ( isnan(Path(point,1)) == 0 )
        X = round(Path(point,1));
        Y = round(Path(point,2));
    end
    
    if(~isnan(Track.Size(point)))
        PointColor =  plot_track_colormap(Track.State(point), Track.Curvature(point));
        frame(Y,X,:) = PointColor;
    end
    
end
return;