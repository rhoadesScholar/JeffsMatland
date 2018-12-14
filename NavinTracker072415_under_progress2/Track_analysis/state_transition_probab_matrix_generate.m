function [state_transition_probab_matrix, std_matrix, err_matrix, t_vector] = state_transition_probab_matrix_generate(Tracks, binsize, starttime, endtime)

state_transition_probab_matrix=[]; err_matrix = []; std_matrix = []; t_vector = [];

time_vector = nanmean(track_field_to_matrix(Tracks, 'Time'));
state_matrix = track_field_to_matrix(Tracks, 'State');

if(nargin<2)
    binsize = 1;
end
if(nargin<4)
    starttime = time_vector(1);
    endtime = time_vector(end);
end

% replace state_matrix state values w/ more convenient values
% Fwd = 1
% Pause = 2     1.1
% Upsilon = 3
% Rev = 4   sRev(5), lRev(4)
% Omega = 5     7

reduced_state_matrix = matrix_replace(state_matrix,'>',10,NaN); % ring, missing, etc
reduced_state_matrix = matrix_replace(reduced_state_matrix,'==',num_state_convert('pause'),2);
reduced_state_matrix = floor(reduced_state_matrix); % composite states set to the actual state
reduced_state_matrix = matrix_replace(reduced_state_matrix,'==',num_state_convert('sRev'),4);
reduced_state_matrix = matrix_replace(reduced_state_matrix,'==',num_state_convert('omega'),5);

i=1;
t=starttime;
while(t<=endtime)
    t_vector = [t_vector (t + binsize/2)  ];
    [state_transition_probab_matrix(i,:,:), std_matrix(i,:,:), err_matrix(i,:,:)] = state_transition_probab_matrix_calc(reduced_state_matrix, time_vector, t, t+binsize);
    t=t+binsize;
    i=i+1;
end

return;
end

function [state_transition_probab_matrix, std_matrix, err_matrix] = state_transition_probab_matrix_calc(reduced_state_matrix, time_vector, starttime, endtime)

[val, start_idx] = find_closest_value_in_array(starttime, time_vector);
[val, end_idx] = find_closest_value_in_array(endtime, time_vector);
end_idx = end_idx-1;

state_transition_probab_matrix = zeros(5,5);
std_matrix = state_transition_probab_matrix;
err_matrix = state_transition_probab_matrix;
num_worms_per_state_changing_state = zeros(1,5);
num_worms_per_state = zeros(1,5);
for(i=1:size(reduced_state_matrix,1))
    for(j=start_idx:end_idx)
        if(~isnan(reduced_state_matrix(i,j)) && ~isnan(reduced_state_matrix(i,j+1)))
            if(~((reduced_state_matrix(i,j)==3 && reduced_state_matrix(i,j+1)==5) || (reduced_state_matrix(i,j)==5 && reduced_state_matrix(i,j+1)==3)))
                if(reduced_state_matrix(i,j) ~= reduced_state_matrix(i,j+1))
                    state_transition_probab_matrix(reduced_state_matrix(i,j), reduced_state_matrix(i,j+1)) =  state_transition_probab_matrix(reduced_state_matrix(i,j), reduced_state_matrix(i,j+1))+1;
                    num_worms_per_state_changing_state(reduced_state_matrix(i,j)) = num_worms_per_state_changing_state(reduced_state_matrix(i,j))+1;
                else
                    state_transition_probab_matrix(reduced_state_matrix(i,j), reduced_state_matrix(i,j+1)) =  state_transition_probab_matrix(reduced_state_matrix(i,j), reduced_state_matrix(i,j+1))-1;
                end
                num_worms_per_state(reduced_state_matrix(i,j)) = num_worms_per_state(reduced_state_matrix(i,j))+1;
            end
        end
    end
end

% # transitions/worm starting in state i
for(i=1:5)
    
    idx = find([1:5]~=i);
    state_transition_probab_matrix(i,idx) = state_transition_probab_matrix(i,idx)./num_worms_per_state_changing_state(i);
    std_matrix(i,idx) = sqrt(state_transition_probab_matrix(i,idx).*(1-state_transition_probab_matrix(i,idx)));
    err_matrix(i,idx) = std_matrix(i,idx)./sqrt(num_worms_per_state_changing_state(i));
    
    
    state_transition_probab_matrix(i,i) = abs(state_transition_probab_matrix(i,i))./num_worms_per_state(i);
    std_matrix(i,i) = sqrt(state_transition_probab_matrix(i,i).*(1-state_transition_probab_matrix(i,i)));
    err_matrix(i,i) = std_matrix(i,i)./sqrt(num_worms_per_state(i));
    
end

return;
end
