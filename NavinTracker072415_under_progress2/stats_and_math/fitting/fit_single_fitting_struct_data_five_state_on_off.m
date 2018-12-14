function fitting_struct = fit_single_fitting_struct_data_five_state_on_off(fitting_struct, d)

m0 = [fitting_struct.data(d).k0  fitting_struct.data(d).gamma0];

for(i=1:4)
    if(fitting_struct.data(d).k_usage_vector(i) == 0)
        m0(i)=0;
    end
end
i=5;
for(q=1:length(fitting_struct.data(d).usage_vector))
    if(fitting_struct.data(d).usage_vector(q) == 0)
        m0(i) = 0;
    end
    i=i+1;
end

mfe = 10000*length(m0); 
fminsearchoptions = optimset('MaxFunEvals',mfe,'MaxIter',mfe,'TolFun',1e-4,'Display','off');

m = fminsearch(@(m) score_five_state_on_off_single_data(m,fitting_struct,d), m0, fminsearchoptions);

% set unused variables to zero and put limits
max_k = log(2)/(0.3333/2);
min_k = 0; % 1e-4;
for(i=1:4)
    if(fitting_struct.data(d).k_usage_vector(i) == 0)
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


i=5;
for(q=1:length(fitting_struct.data(d).usage_vector))
    if(fitting_struct.data(d).usage_vector(q) == 0)
        m(i) = 0;
    end
    i=i+1;
end

fitting_struct.data(d).k = m(1:4);

i=5;
for(q=1:length(fitting_struct.data(d).gamma0))
    fitting_struct.data(d).un_norm_gamma(q) = fitting_struct.data(d).range*m(i) + fitting_struct.data(d).minval;
    if(fitting_struct.data(d).un_norm_gamma(q)<0)
        m(i) = (1e-4 -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
        fitting_struct.data(d).un_norm_gamma(q) = 1e-4;
    end
    i=i+1;
end
fitting_struct.data(d).gamma = m(5:end);


if(fitting_struct.data(d).inst_freq_code == 1)
    t = fitting_struct.t;
else
    t = fitting_struct.t_freq;
end
fitting_struct.data(d).y_fit = five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, fitting_struct.data(d).k, fitting_struct.data(d).gamma);
fitting_struct.data(d).un_norm_y_fit =  five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off,fitting_struct.data(d).k, fitting_struct.data(d).un_norm_gamma);

fitting_struct.data(d).aic = akaike_score(fitting_struct.data(d).y, fitting_struct.data(d).y_fit, ...
                            (length(find(fitting_struct.data(d).usage_vector==1)) + length(find(fitting_struct.data(d).k_usage_vector==1))));

% subplot(1,2,1); plot(t,fitting_struct.data(d).un_norm_y,'.b'); hold on; plot(t,fitting_struct.data(d).un_norm_y_fit,'r'); hold off;
% subplot(1,2,2); plot(t,fitting_struct.data(d).y,'.b'); hold on; plot(t,fitting_struct.data(d).y_fit,'r'); hold off;
% disp([fitting_struct.data(d).fieldname, ' ', num2str(m)])
% pause
% close all

return;
end

function score =  score_five_state_on_off_single_data(m, fitting_struct,d)

if(fitting_struct.data(d).inst_freq_code == 1)
    t = fitting_struct.t;
else
    t = fitting_struct.t_freq;
end

% set unused variables to zero and put limits
max_k = log(2)/(0.3333/2);
min_k = 0; % 1e-4;
for(i=1:4)
    if(fitting_struct.data(d).k_usage_vector(i) == 0)
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

i=5;
for(q=1:length(fitting_struct.data(d).usage_vector))
    if(fitting_struct.data(d).usage_vector(q) == 0)
        m(i) = 0;
    else
        un_norm_gamma = fitting_struct.data(d).range*m(i) + fitting_struct.data(d).minval;
        if(un_norm_gamma < 0)
            m(i) = (1e-4 -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
        end
    end
    i=i+1;
end




k = m(1:4);
gamma = m(5:end);

y_fit =  five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, k, gamma);

score = nansum((fitting_struct.data(d).y - y_fit).^2) + 10000*(sum(isnan(y_fit))^2 );

return;
end




