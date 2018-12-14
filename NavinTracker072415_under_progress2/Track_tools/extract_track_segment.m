function outTrack = extract_track_segment(inputTrack, firstframe_idx, lastframe_idx, units)
% outTrack = extract_track_segment(inputTrack, firstframe_idx, lastframe_idx, [units])
% outTrack = track segment between firstframe_idx, lastframe_idx frame indicies
% units is optional
% units = 'time' or 'sec', outTrack = track segment between firstframe_idx, lastframe_idx seconds
% units = 'frame', outTrack = track segment between firstframe_idx, lastframe_idx frames

if(nargin<3)
    disp('outTrack = extract_track_segment(inputTrack, firstframe_idx, lastframe_idx, [units])')
    disp('outTrack = track segment between firstframe_idx, lastframe_idx frame indicies')
    disp('units is optional')
    disp('units = ''time'' or ''sec'', outTrack = track segment between firstframe_idx, lastframe_idx seconds')
    disp('units = ''frame'', outTrack = track segment between firstframe_idx, lastframe_idx frames')
    return
end

if(nargin<4)
    units = 'index';
end
units = lower(units);

global Prefs;

outTrack = [];
if(length(inputTrack)>1)
   for(i=1:length(inputTrack))
       outTrack = [outTrack extract_track_segment(inputTrack(i), firstframe_idx, lastframe_idx, units)];
   end
   return;
end

    % extract track between given times
    if(~isempty(strfind(units,'time')) || ~isempty(strfind(units,'sec')))
        if(firstframe_idx <= inputTrack.Time(1))
            firstframe_idx = inputTrack.Time(1);
        end
        if(lastframe_idx >= inputTrack.Time(end))
            lastframe_idx = inputTrack.Time(end);
        end
        [firstframe_idx, lastframe_idx] = starttime_endtime_to_startframe_index_endframe_index(inputTrack, firstframe_idx, lastframe_idx);
    end

    % extract track between given frames
    if(~isempty(strfind(units,'frame')))
        if(firstframe_idx <= inputTrack.Frames(1))
            firstframe_idx = inputTrack.Frames(1);
        end
        if(lastframe_idx >= inputTrack.Frames(end))
            lastframe_idx = inputTrack.Frames(end);
        end
        [firstframe_idx, lastframe_idx] = startframe_endframe_to_startframe_index_endframe_index(inputTrack, firstframe_idx, lastframe_idx);
    end



% if this is already extracted
if(firstframe_idx == 1 && lastframe_idx == length(inputTrack.Frames))
    outTrack = inputTrack;
    return;
end

if(firstframe_idx < 1 || lastframe_idx > length(inputTrack.Frames))
    outTrack = [];
    return;
end

if(firstframe_idx > lastframe_idx)
    outTrack = [];
    return;
end

special_fields = {'NumFrames', 'Wormlength', 'Image', 'Reorientations', 'numActiveFrames', ...
                    'Name', 'body_contour','original_track_indicies'};
                
trackfields =  fieldnames(inputTrack);
for(p=1:length(special_fields))
    f=1;
    while(f<=length(trackfields))
        if(strcmp( char(trackfields{f}),char(special_fields{p}))==1)
            trackfields(f) = [];
            break;
        else
            f=f+1;
        end
    end
end

outTrack.NumFrames = lastframe_idx-firstframe_idx+1;
% if(outTrack.NumFrames<=1)
%     outTrack = [];
%     return;
% end

if(isfield(inputTrack,'Name'))
    outTrack.Name = inputTrack.Name;
end

for(f=1:length(trackfields))
    outTrack = extract_field(outTrack, inputTrack, firstframe_idx, lastframe_idx, trackfields{f});
end
clear('trackfields');


% some special cases


if(isfield(inputTrack,'original_track_indicies'))
    outTrack.original_track_indicies = inputTrack.original_track_indicies;
end

if(isfield(inputTrack,'Wormlength'))
    if(isfield(outTrack,'PixelSize'))
        outTrack.Wormlength = nanmedian(outTrack.MajorAxes)*outTrack.PixelSize;
    else
        outTrack.Wormlength = nanmedian(outTrack.MajorAxes)*Prefs.DefaultPixelSize;
    end
end

if(isfield(inputTrack,'Image'))
    outTrack = extract_field(outTrack, inputTrack, firstframe_idx, lastframe_idx, 'bound_box_corner');
    outTrack.Image = [];
    for(i=1:outTrack.NumFrames)
        outTrack.Image{i} = inputTrack.Image{firstframe_idx+i-1};
    end
end


if(isfield(inputTrack,'Reorientations')==1)
    outTrack.Reorientations = [];
    for(k=1:length(inputTrack.Reorientations))
        if(inputTrack.Reorientations(k).start >= firstframe_idx && inputTrack.Reorientations(k).end <= lastframe_idx)
            outTrack.Reorientations = [outTrack.Reorientations inputTrack.Reorientations(k)];
        end
    end
    
    reori_frame_fields = {'start','startRev','startTurn','end'};
    for(i=1:length(outTrack.Reorientations))
        for(j=1:length(reori_frame_fields))
            if(~isnan(outTrack.Reorientations(i).(reori_frame_fields{j})))
                outTrack.Reorientations(i).(reori_frame_fields{j}) = find(outTrack.Frames == inputTrack.Frames(outTrack.Reorientations(i).(reori_frame_fields{j})));
            end
        end
    end
end

if(isfield(inputTrack,'body_contour')==1)
    outTrack.body_contour = inputTrack.body_contour(firstframe_idx:lastframe_idx);
end

if(isfield(inputTrack,'numActiveFrames')==1)
    outTrack.numActiveFrames = num_active_frames(outTrack);
end

return;

end


