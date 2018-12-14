% refits just the rate constants, given gammas in fitting_struct.data
function fitting_struct = fit_five_state_on_off_rate_constants(fitting_struct)

m0 = fitting_struct.k;

for(i=1:length(m0))
    if(fitting_struct.usage_vector(i) == 0)   % if a variable is initialized to zero, keep it zero
        m0(i) = 0;
    end
end


mfe = 10000*length(m0); 
fminsearchoptions = optimset('MaxFunEvals',mfe,'MaxIter',mfe,'TolFun',1e-4,'Display','off');

m = fminsearch(@(m) score_five_state_on_off_rates(m,fitting_struct), m0, fminsearchoptions);


for(i=1:length(m))
    if(fitting_struct.usage_vector == 0)   % if a variable is initialized to zero, keep it zero
        m(i) = 0;
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




fitting_struct.k = m;

m = fitting_struct.k;
for(d=1:length(fitting_struct.data))
    m = [m  fitting_struct.data(d).gamma];
end
for(i=1:length(fitting_struct.usage_vector))
    if(fitting_struct.usage_vector(i)==0)
        m(i)=0;
    end
end
fitting_struct = m_to_fitting_struct(m, fitting_struct);
fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);
fitting_struct.score = score_five_state_on_off_model(m, fitting_struct);

return;
end

function score = score_five_state_on_off_rates(m, fitting_struct)
% score for fitting just the rate constants

for(i=1:length(m))
    if(fitting_struct.usage_vector(i) == 0)   % if a variable is initialized to zero, keep it zero
        m(i) = 0;
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


m_local = m;
for(d=1:length(fitting_struct.data))
    m_local = [m_local fitting_struct.data(d).gamma];
end

score = score_five_state_on_off_model(m_local, fitting_struct);

return;
end
