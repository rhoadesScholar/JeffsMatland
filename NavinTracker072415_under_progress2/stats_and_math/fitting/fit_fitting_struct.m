function fitting_struct = fit_fitting_struct(m0, fitting_struct)

fitting_struct = m_to_fitting_struct(m0, fitting_struct);
fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);
fitting_struct.score = score_five_state_on_off_model(m0, fitting_struct);

% figure, plot_fitting_struct(fitting_struct);
% disp([num2str(fitting_struct.score), ' ', timeString()])
% pause

% global fit the rate constants 
fitting_struct = fit_five_state_on_off_rate_constants(fitting_struct);

% fit the gammas 
for(d=1:length(fitting_struct.data))
    fitting_struct = fit_five_state_on_off_gamma(fitting_struct, d);
end


m = fitting_struct.m;
local_m0 = m;


% loop until convergence
score = fitting_struct.score;
stopflag=0;
prev_score=score;
num_iterations=1;

stopflag=0;

while(stopflag==0)
    
%     if(mod(num_iterations,5)==0)
%         disp([num2str(num_iterations),' ',num2str(score), ' ', timeString()])
%     end
    
    % global fit the rate constants
    fitting_struct = fit_five_state_on_off_rate_constants(fitting_struct);
    fitting_struct.k0 = fitting_struct.k;
    
    % re-fit the gammas keeping the globally fit rate constants fixed
    for(d=1:length(fitting_struct.data))
        fitting_struct = fit_five_state_on_off_gamma(fitting_struct, d);
    end
    
    for(d=1:length(fitting_struct.data))
        fitting_struct.data(d).gamma0 = fitting_struct.data(d).gamma;
        fitting_struct.data(d).un_norm_gamma0 = fitting_struct.data(d).un_norm_gamma;
    end
    
    m = fitting_struct.m;
    local_m0 = m;
    
    score = fitting_struct.score;
    num_iterations = num_iterations+1;
    
    if(abs(score-prev_score)<1e-4)
        stopflag=1;
    end
    prev_score = score;
    
end

fitting_struct.k0 = fitting_struct.k0_original;
for(d=1:length(fitting_struct.data))
    fitting_struct.data(d).gamma0 = fitting_struct.data(d).gamma0_original;
    fitting_struct.data(d).un_norm_gamma0 = fitting_struct.data(d).un_norm_gamma0_original;
end

% disp([num2str(num_iterations),' ',num2str(score), ' ', timeString()])

fitting_struct.f.m = fitting_struct.un_norm_m;
fitting_struct.f.m0 = fitting_struct.un_norm_m0;
fitting_struct.f.r2 = corr2(fitting_struct.y, fitting_struct.y_fit)^2;
fitting_struct.f.chi2 = fitting_struct.score;
fitting_struct.f.yfit = fitting_struct.un_norm_y_fit;
fitting_struct.f.y = fitting_struct.un_norm_y;
fitting_struct.real_df = fitting_struct.usage_vector.*fitting_struct.df;

fitting_struct.f.df = length(fitting_struct.un_norm_y) - length(find(fitting_struct.usage_vector==1)) -  1; % degrees of freedom


aic=[];
fitting_struct.f.param = {'k1','k2','k3','k4'};
i=5;
for(d=1:length(fitting_struct.data))
    for(q=1:5)
        if(fitting_struct.usage_vector(i) == 1)
            dummystring = sprintf('%s_gamma_%d',fitting_struct.data(d).fieldname,q);
        else
            dummystring = sprintf('%s_gamma_%d_ignore',fitting_struct.data(d).fieldname,q);
        end
        fitting_struct.f.param = [fitting_struct.f.param dummystring];
        i=i+1;
    end
    
    fitting_struct.data(d).aic = akaike_score(fitting_struct.data(d).y, fitting_struct.data(d).y_fit, ...
        (length(find(fitting_struct.data(d).usage_vector==1)) + length(find(fitting_struct.data(d).k_usage_vector(1:4)==1))) );
    
    aic = [aic fitting_struct.data(d).aic ];
end

fitting_struct.f.aic = nansum(aic); % (nanmean(aic) + nanmedian(aic))/2; % akaike_score(fitting_struct.f.df, fitting_struct.f.chi2, length(find(fitting_struct.usage_vector==1)));

return;
end

function fitting_struct = fit_rates_and_gammas_fitting_struct(m0, fitting_struct)

mfe = 1000;
fminsearchoptions = optimset('MaxIter',mfe,'TolFun',1e-4,'Display','off');

m = fminsearch(@(m) score_five_state_on_off_model(m,fitting_struct), m0, fminsearchoptions);
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

