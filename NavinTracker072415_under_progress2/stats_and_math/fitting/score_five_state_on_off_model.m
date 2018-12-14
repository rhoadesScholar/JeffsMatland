function score = score_five_state_on_off_model(m, fitting_struct)

persistent best_score;
persistent num_func_calls;

score=0;

if(nargin==0)
    best_score = [];
    num_func_calls = [];
    return;
end

if(isempty(best_score))
    best_score=1e10;
    num_func_calls = 0;
end
num_func_calls = num_func_calls+1;


% if a variable is initialized to zero, keep it zero 
for(i=1:length(m))
    if(fitting_struct.usage_vector(i) == 0)
        m(i) = 0;
    end
end


constraint = 0;

% rate constants should be positive
for(i=1:4)
    if(m(i)<0)
        constraint = constraint + (10+m(i))^2;
    end
end

max_k = log(2)/(0.3333/2);
min_k = 0; % 1e-4;
for(i=1:4)
    if(fitting_struct.usage_vector(i) == 0)
        m(i)=0;
    else
        if(m(i)<0)
            m(i) = abs(m(i));
        end
        if(m(i) > max_k)
            m(i) =  max_k;
        end
        if(m(i)<min_k)
            m(i)=min_k;
        end
    end
end

fitting_struct = m_to_fitting_struct(m, fitting_struct);
                
fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);

% standard least-squares
score = nansum(((fitting_struct.y - fitting_struct.y_fit)).^2) + 1000*(constraint + sum(isnan(fitting_struct.y_fit))^2);

% % mean least-squares .... minimize the average least squares error for all
% % the fields under consideration
% score = 0;
% for(dd=1:length(fitting_struct.data))
%     score = score + nansum(((fitting_struct.data(dd).y - fitting_struct.data(dd).y_fit)).^2);
% end
% score = score/length(fitting_struct.data);
% score = score + 1000*(constraint + sum(isnan(fitting_struct.y_fit))^2);


if(score < best_score)
    best_score = score;
end

% if(mod(num_func_calls,50000)==0)
%     disp( [ num2str([num_func_calls best_score]),' ',timeString() ] );
% end

return;
end

