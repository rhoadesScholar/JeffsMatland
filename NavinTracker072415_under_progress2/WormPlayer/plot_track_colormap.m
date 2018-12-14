function val = plot_track_colormap(state, curv)

val = [1 1 1];

state = floor(state);

if(strcmp(num_state_convert(state),'ring')==1)
    state=8;
else
    if(state <= num_state_convert('fwd_state'))
        state=1;
    end
end

if ( state > 8 )
    state = 1;
end

% ben's colormap
cmap = [179 179 179; ...  % gray fwd      1
        179 179 179; ...  % gray reori      2
        255 0 255; ...  % magenta turn   3
        0 0 255; ...  % blue lRev      4
        0 255 255; ...  % cyan sRev      5
        179 179 179; ...  % gray ssRev    6
        255 0 0; ...  % red omega      7
        0 255 0];     % green ring     8

% navin's colormap    
%     cmap = [0.7 0.7 0.7; ...  % gray fwd      1
%         0.7 0.7 0.7; ...  % gray reori      2
%         1 0 1; ...  % magenta turn   3
%         0 0 1; ...  % blue lRev      4
%         0 1 1; ...  % cyan sRev      5
%         0.7 0.7 0.7; ...  % gray ssRev    6
%         1 0 0; ...  % red omega      7
%         0 1 0];     % green ring     8
    
    
if(~isnan(state))    
    val = cmap(state,:);    
end

if(state==1)
    val = floor(255*(curvature_colormap(curv)));
end

return;
end