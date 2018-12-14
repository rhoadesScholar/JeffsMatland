function Track = delete_frame_from_Track(Track, frame_index)

trackfields = fieldnames(Track);

f=1;
while(f<=length(trackfields))
    if(length(Track.(trackfields{f}))<=1 || ischar(Track.(trackfields{f})) )
        trackfields(f)=[];
    else
        f=f+1;
    end
end



special_fields = {'NumFrames', 'Wormlength', 'numActiveFrames', 'Reorientations'};


for(p=1:length(special_fields))
    f=1;
    while(f<=length(trackfields))
        if(strcmp(char(trackfields{f}), char(special_fields{p}))==1 )
            trackfields(f)=[];
            break;
        else
            f=f+1;
        end
    end
end

for(i=1:length(trackfields))
    if(size(Track.(trackfields{i}),1) == Track.NumFrames)
        Track.(trackfields{i})(frame_index,:) = [];
    else
        if(size(Track.(trackfields{i}),2) == Track.NumFrames)
            Track.(trackfields{i})(:,frame_index) = [];
        end
    end
end

if(isfield(Track,'NumFrames')==1)
    Track.NumFrames = length(Track.Frames);
end

if(isfield(Track,'Wormlength')==1)
    Track.Wormlength = nanmedian(Track.MajorAxes)*Track.PixelSize;
end

if(isfield(Track,'numActiveFrames')==1)
    Track.numActiveFrames = num_active_frames(Track);
end

return;
end
