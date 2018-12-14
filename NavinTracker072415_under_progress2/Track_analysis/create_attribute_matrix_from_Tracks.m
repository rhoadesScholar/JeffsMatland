function attribute_matrix = create_attribute_matrix_from_Tracks(Tracks, attribute, starttime, endtime)

if(isfield(Tracks(1), attribute))
    if(length(Tracks(1).(attribute))==1)
        attribute_matrix = [];
        for(i=1:length(Tracks))
            attribute_matrix = [attribute_matrix Tracks(i).(attribute)];
        end
        return;
    end
end

epsilon=1e-4;

num_frames = max_struct_array(Tracks,'Frames');
num_tracks = length(Tracks);

if(nargin > 2)
    first = min_struct_array(Tracks,'Time');
    last = max_struct_array(Tracks,'Time');
    
    timevector = first:1/Tracks(1).FrameRate:last;

    if(are_these_equal(starttime, first) && are_these_equal(endtime, last))
        del_idx=[];
    else
        del_idx = find(timevector < (starttime-epsilon) | timevector > (endtime+epsilon));
    end
end



if(strcmp(attribute,'revlength')  || strcmp(attribute,'revLen'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_reversal_length_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end

if(strcmpi(attribute,'revSpeed'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_revSpeed_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end


if(strcmpi(attribute,'ecc_omegaupsilon'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_ecc_omegaupsilon_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end


if(strcmpi(attribute,'revlength_bodybends'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_reversal_length_bodybends_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end

if(strcmpi(attribute,'delta_dir_rev'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_delta_dir_rev_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end

if(strcmpi(attribute,'delta_dir_omegaupsilon'))
    attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;
    
    for(i=1:num_tracks)
        attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = create_delta_dir_omegaupsilon_vector(Tracks(i));
    end
    
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    
    return;
end


attribute_matrix = zeros(num_tracks, num_frames, 'single') + NaN;

if(~isfield(Tracks,attribute))
    % error('%s is not an attribute of Tracks',attribute);
    if(nargin > 2)
        attribute_matrix(:,del_idx) = [];
    end
    return;
end

for(i=1:num_tracks)
    attribute_matrix(i,(Tracks(i).Frames(1):Tracks(i).Frames(end))) = Tracks(i).(attribute);
end

if(nargin > 2)
    attribute_matrix(:,del_idx) = [];
end

return;
end
