function minimalState = make_minimalState_string(Track)

State = floor(Track.State);

minimalState = zeros(1,length(State));
minimalState = minimalState + 1;

for(i=1:length(State))
    if(strcmp(num_state_convert(State(i)),'lRev')==1 || ...
            strcmp(num_state_convert(State(i)),'sRev')==1)
        minimalState(i) = 'R';
    else
        if(strcmp(num_state_convert(State(i)),'omega')==1)
            minimalState(i) = 'O';
        else
            if(strcmp(num_state_convert(State(i)),'turn')==1)
                minimalState(i) = 'T'; 
            else
                minimalState(i) = 1;
            end
        end
    end
end

return;
end
