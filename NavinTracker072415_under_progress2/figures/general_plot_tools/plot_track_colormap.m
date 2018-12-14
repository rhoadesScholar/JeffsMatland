function val = plot_track_colormap(state)

val = [1 1 1];

state = floor(state);

if(strcmp(num_state_convert(state),'ring')==1)
    state=8;
else
    if(state <= num_state_convert('fwd_state'))
        state=1;
    end
end

cmap = [0.7 0.7 0.7; ...  % gray fwd      1
        0.7 0.7 0.7; ...  % gray reori      2
        1 0 1; ...  % magenta upsilon   3
        0 0 1; ...  % blue lRev      4
        0 1 1; ...  % cyan sRev      5
        0.7 0.7 0.7; ...  % gray ssRev    6
        1 0 0; ...  % red omega      7
        0 1 0];     % green ring     8
    
    
if(~isnan(state))    
    val = cmap(state,:);    
end

return;
end
