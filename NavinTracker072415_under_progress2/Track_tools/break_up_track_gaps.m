function tracks = break_up_track_gaps(inputTracks)
% tracks = break_up_track_gaps(inputTracks)
% breaks up linked tracks to get rid of gaps; output is an array of
% contigious tracks

tracks = [];
for(i=1:length(inputTracks))
    nan_v = isnan(inputTracks(i).Speed);
    j=1;
    while(j<length(nan_v))
        startFrame_index = j;
        while(nan_v(j)==0)
            j=j+1;
            if(j>=length(nan_v))
                break;
            end
        end
        endFrame_index = j-1;
        tracks = [tracks extract_track_segment(inputTracks(i), startFrame_index, endFrame_index)];
        while(nan_v(j)==1)
            j=j+1;
            if(j>=length(nan_v))
                break;
            end
        end
    end
end

return;
end
