function Tracks_to_movie(Tracks, startframe, endframe)
% Tracks_to_movie(Tracks, startframe, endframe)

if(nargin<1)
    disp('Tracks_to_movie(Tracks, startframe, endframe)')
    return;
end

if(ischar(Tracks))
    ds = Tracks;
    clear('Tracks');
    Tracks = load_Tracks(ds);
    clear('ds');
end

if(nargin<3)
    startframe = min_struct_array(Tracks,'Frames');
    endframe = max_struct_array(Tracks,'Frames');
end

height = Tracks(1).Height;
width = Tracks(1).Width;

filename = Tracks(1).Name;

if(~file_existence(filename))
    [~,prefix] = fileparts(filename);
    filename = sprintf('%s.avi',prefix);
    if(~file_existence(filename))
       error('cannot find %s or %s in local directory',Tracks(1).Name,  filename);
    end
end

file_info = moviefile_info(filename);
height = file_info.Height;
width = file_info.Width;

[~,prefix] = fileparts(filename);
new_file = sprintf('%s.%d.%d.Tracks.avi',prefix,startframe,endframe);
if(file_existence(new_file))
    rm(new_file);
end

% aviobj = VideoWriter(new_file,'Motion JPEG AVI'); 
aviobj = VideoWriter(new_file);
aviobj.Quality = 100;
open(aviobj);

aviread_to_gray;
for(framenum=startframe:endframe)
    
    fig = figure(1);
    
    Mov = aviread_to_gray(filename,framenum);
    
    imshow(Mov.cdata,'Border','tight');
    hold on;
    
    track_idx_frame_idx = find_Track(Tracks, 'Frames', sprintf('==%d',framenum) );
    
    for(i=1:length(track_idx_frame_idx))
        t = track_idx_frame_idx(i).track_idx;
        f = track_idx_frame_idx(i).frame_idx;
        
        
        % plot bounding box
        if(size(Tracks(t).Image{f},2)*size(Tracks(t).Image{f},1) > 1)
            rectangle('position',[Tracks(t).bound_box_corner(f,1), Tracks(t).bound_box_corner(f,2), ...
                size(Tracks(t).Image{f},2), size(Tracks(t).Image{f},1)],'EdgeColor','g');
        else
            rectangle('position',[Tracks(t).bound_box_corner(f,1), Tracks(t).bound_box_corner(f,2), ...
                Tracks(t).MajorAxes(f), Tracks(t).MajorAxes(f)],'EdgeColor','g');
        end
        hold on;
        
        if(length(Tracks)>1)
            text('Position', [Tracks(t).bound_box_corner(f,1), Tracks(t).bound_box_corner(f,2)],'String',sprintf('%d',t),'color','b');
        end
    end
    
    col = stimulus_colormap(Tracks(t).stimulus_vector(f));
    
    text('Position',[10,10],'String',sprintf('%d  %d', framenum, length(track_idx_frame_idx)),'color',col,...
                    'verticalalign','top');
    
    hold off;
    
    F = getframe(fig);
    writeVideo(aviobj,F);
    
    close(fig);
    pause(0.001);
end
aviread_to_gray;

close(aviobj);

return
end
