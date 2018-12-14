function outTrack = extract_field(outTrack, inputTrack, firstframe_idx, lastframe_idx, field)

if(isfield(inputTrack,field)==1)
    if(isnumeric(inputTrack.(field))==1) 
        
        outTrack.(field) = [];
        
        [i,j] = size(inputTrack.(field)); 
        
        if(i==1 || j==1)
            if(i==j) % numbers global for the track
                outTrack.(field) =  inputTrack.(field);
            else % one-dimensional array
                outTrack.(field) =  inputTrack.(field)(firstframe_idx:lastframe_idx);
            end
        else
            if(i==0 || j==0) % empty but existing field
                outTrack.(field) =  inputTrack.(field);
            else % two-dimensional matrix
                outTrack.(field) =  inputTrack.(field)(firstframe_idx:lastframe_idx,:);
            end
        end
    end
end

return;
end
