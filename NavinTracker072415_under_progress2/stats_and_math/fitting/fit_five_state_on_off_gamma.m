% refits just the gammas for data d
function fitting_struct = fit_five_state_on_off_gamma(fitting_struct, d)

m0 = fitting_struct.data(d).gamma;

% if a variable is initialized to zero, keep it zero 
for(i=1:length(fitting_struct.data(d).usage_vector))
    if(fitting_struct.data(d).usage_vector(i) == 0)
        m0(i) = 0;
    end
end

mfe = 10000*length(m0); 
fminsearchoptions = optimset('MaxFunEvals',mfe,'MaxIter',mfe,'TolFun',1e-4,'Display','off');

m = fminsearch(@(m) score_five_state_on_off_gamma(m,fitting_struct,d), m0, fminsearchoptions);

for(i=1:length(m))
    if(fitting_struct.data(d).usage_vector(i) == 1)
        fitting_struct.data(d).un_norm_gamma(i) = fitting_struct.data(d).range*m(i) + fitting_struct.data(d).minval;
        if(fitting_struct.data(d).un_norm_gamma(i)<0)
            m(i) = (1e-4 -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
            fitting_struct.data(d).un_norm_gamma(i) = 1e-4;
        end
    else
        fitting_struct.data(d).un_norm_gamma(i) = 0;
        m(i) = 0;
    end
end
fitting_struct.data(d).gamma = m;


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

% subplot(1,2,1); plot(t,fitting_struct.data(d).un_norm_y,'.b'); hold on; plot(t,fitting_struct.data(d).un_norm_y_fit,'r'); hold off;
% subplot(1,2,2); plot(t,fitting_struct.data(d).y,'.b'); hold on; plot(t,fitting_struct.data(d).y_fit,'r'); hold off;
% disp([fitting_struct.data(d).fieldname, ' ', num2str(m)])
% pause
% close all

return;
end

function score = score_five_state_on_off_gamma(m, fitting_struct, d)


for(i=1:length(m))
    if(fitting_struct.data(d).usage_vector(i) == 0)   % if a variable is initialized to zero, keep it zero
        m(i) = 0;
    else % check for negative un_normalized gammas
        un_norm_gamma = fitting_struct.data(d).range*m(i) + fitting_struct.data(d).minval;
        if(un_norm_gamma < 0)
            m(i) = (1e-4 -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
        end
    end
end

if(fitting_struct.data(d).inst_freq_code == 1)
    t = fitting_struct.t;
else
    t = fitting_struct.t_freq;
end

y_fit =  five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, fitting_struct.k, m);

large_gamma_penalty = 0;
for(i=1:length(un_norm_gamma))
    if(un_norm_gamma(i) >  fitting_struct.data(d).maxval)
        large_gamma_penalty = large_gamma_penalty + 10000*(un_norm_gamma(i) -  fitting_struct.data(d).maxval)^2;
    end
    if(un_norm_gamma(i) <  fitting_struct.data(d).minval)
        large_gamma_penalty = large_gamma_penalty + 10000*(un_norm_gamma(i) -  fitting_struct.data(d).maxval)^2;
    end
end

score = nansum(((fitting_struct.data(d).y - y_fit)).^2) + 10000*(sum(isnan(y_fit))^2 ) + large_gamma_penalty;

return;
end
