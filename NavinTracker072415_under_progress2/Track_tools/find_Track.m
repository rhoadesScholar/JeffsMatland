function [track_idx_frame_idx, outTracks] = find_Track(Tracks,field,relationship1, linker, relationship2)
% [track_idx_frame_idx, outTracks] = find_Track(Tracks,field,relationship1, linker, relationship2)
% returns the track and frame indicies for which Track.field are relationship
% For example, find_Track(Track,'Speed','>=0.14') returns the track and
% Track.Speed indicies where Speed >= 0.14
% if outTracks requested, will return track segments > 1sec duration that
% fulfill the required relationships

if(nargin<1)
    disp('[track_idx_frame_idx, outTracks] = find_Track(Tracks,field,relationship1, linker, relationship2)')
    disp('find_Track(Track,''Speed'',''>=0.14'') returns the track and Track.Speed indicies where Speed >= 0.14')
    disp('if outTracks requested, will return track segments > 1sec duration that fulfill the required relationships')
    return
end

track_idx_frame_idx = [];
outTracks = [];

realfield = field;
if(~isempty(strfind(field,'(')))
    realfield = field(1:strfind(field,'(')-1);
end
if(~isfield(Tracks,realfield))
    disp([sprintf('%s is not a field in Track for find_Track',realfield)]);
    return;
end

q=0;
for(i=1:length(Tracks))
    
    if(nargin == 3)
        if(~isempty(strfind(relationship1,'==')))
            converted_eq = convert_eq_to_subtraction(field,relationship1);
            st = sprintf('find(%s)',converted_eq);
        else
            if(isempty(strfind(relationship1,'isnan')))
                st = sprintf('find(Tracks(i).%s %s)',field, relationship1);
            else
                st = sprintf('find(isnan(Tracks(i).%s))',field);
            end
        end
    else
        if(~isempty(strfind(relationship1,'==')) || ~isempty(strfind(relationship2,'==')))
            if(~isempty(strfind(relationship1,'==')))
                part1 = convert_eq_to_subtraction(field,relationship1);
            else
                part1 = sprintf('Tracks(i).%s %s',field, relationship1);
            end
            
            if(~isempty(strfind(relationship2,'==')))
                part2 = convert_eq_to_subtraction(field,relationship2);
            else
                part2 = sprintf('Tracks(i).%s %s',field, relationship2);
            end
            
            st = sprintf('find(%s %s %s)',part1, linker, part2);
        else
            st = sprintf('find(Tracks(i).%s %s %s Tracks(i).%s %s)',field, relationship1, linker, field, relationship2);
        end
    end
    
    f = eval(st);
    
    if(~isempty(f))
        q=q+1;
        track_idx_frame_idx(q).track_idx = i;
        track_idx_frame_idx(q).frame_idx = f;
    end
end

% outTracks requested
if(nargout > 1)
    for(i=1:length(track_idx_frame_idx))
        inputTrack = Tracks(track_idx_frame_idx(i).track_idx);
        idx = track_idx_frame_idx(i).frame_idx;
        
        j=1;
        while(j<length(idx))
            k = find_end_of_contigious_stretch(idx, j);
            
            % if j or k are during a reorientation event, move them so
            % the entire event is captured
            for(q=1:length(inputTrack.Reorientations))
                if(idx(j) >  inputTrack.Reorientations(q).start && idx(j) < inputTrack.Reorientations(q).end)
                    idx(j) = inputTrack.Reorientations(q).start;
                end
                if(idx(k) >  inputTrack.Reorientations(q).start && idx(k) < inputTrack.Reorientations(q).end)
                    idx(k) = inputTrack.Reorientations(q).end;
                end
            end
            
            % this segment must be at least 1 sec long
            if(k-j+1 > inputTrack.FrameRate)
                outTracks = [outTracks extract_track_segment(inputTrack, idx(j), idx(k))];
            end
            
            j = k+1;
        end
        
    end
end


return;
end

function converted_eq = convert_eq_to_subtraction(field,relationship)

epsilon=1e-4;
    
q=1;
while(relationship(q)=='=')
    q=q+1;
end

converted_eq = sprintf('abs(Tracks(i).%s - %s)<=%f',field, relationship(q:end),epsilon);

return;
end
