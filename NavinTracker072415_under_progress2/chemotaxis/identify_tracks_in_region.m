function [outTracks, region_polygon] = identify_tracks_in_region(Tracks, region_polygon)

outTracks = [];

if(nargin < 2)
    region_polygon = [];
end

movie_name = Tracks(1).Name;

if(~file_existence(movie_name))
    % in current directory?
    [movie_name, movpath] = filename_from_partialpath(movie_name);
    if(~file_existence(movie_name))
        
        [candidate_path, upperpath] = filename_from_partialpath(movpath(1:end-1));
        
        movie_name = sprintf('%s%s%s',candidate_path,filesep,movie_name);
        if(file_existence(movie_name))
            % disp(sprintf('Found %s in local directory %s',movie_name, candidate_path))
        else
            movie_name = uigetfile('*.avi', 'Choose a movie file');
        end
    end
end

if(isempty(region_polygon))
    background = calculate_background(movie_name);
    
    questdlg(sprintf('%s','Select polygon verticies around region of interest'), ...
        'Select ROI', 'OK', 'OK');
    
    answer(1) = 'N';
    while answer(1) == 'N'
        [X, Y] = roi_perimeter(background);
        imshow(background);
        hold on;
        plot(X, Y,'r');
        answer = questdlg('Is the region properly defined?', 'Is the region properly defined?', 'Yes', 'No', 'Yes');
    end
    region_polygon = [X Y];
end

close all;
pause(1);

outTracks = extract_track_in_region(Tracks, region_polygon);



return;
end

