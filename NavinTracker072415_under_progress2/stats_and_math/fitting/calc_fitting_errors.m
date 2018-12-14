function fitting_struct = calc_fitting_errors(fitting_struct)

global Prefs;

% % fitting errors 
% [jac,r] = jacob(fitting_struct.un_norm_y, fitting_struct, fitting_struct.un_norm_m);
% [m_error,delta_y] = uncertainties(r, jac, fitting_struct.t_v, fitting_struct.un_norm_y_fit);
% fitting_struct.f.m_error = m_error; % standard error of fitted parameters
% fitting_struct.un_norm_simulated_fit_matrix = [];
% fitting_struct.simulated_fit_matrix = [];
% 
% fitting_struct.f.m_std = fitting_struct.f.m_error;
% fitting_struct.un_norm_m_std = fitting_struct.f.m_std;
% 
% 
% fitting_struct.m_avg = fitting_struct.m;
% fitting_struct.k_avg = fitting_struct.k;
% fitting_struct.k_std = m_error(1:4);
% 
% fitting_struct.un_norm_m_avg = fitting_struct.k;
% i=5;
% for(d=1:length(fitting_struct.data))
%     fitting_struct.data(d).un_norm_avg_y_fit = fitting_struct.data(d).y_fit;
%     fitting_struct.un_norm_m_avg = [fitting_struct.un_norm_m_avg fitting_struct.data(d).un_norm_gamma];
%     gamma = fitting_struct.un_norm_m_avg(i:i+4);
%     
%     fitting_struct.data(d).un_norm_gamma_avg = gamma;
%     fitting_struct.data(d).un_norm_gamma_std = fitting_struct.un_norm_m_std(i:i+4);
%     i=i+5;
% end
% fitting_struct = confidence_intervals(fitting_struct);
% return


num_random_fits = Prefs.num_random_fits;
max_error_calc_time = Prefs.max_error_calc_time;

fitting_struct.un_norm_simulated_fit_matrix = [];
fitting_struct.simulated_fit_matrix = [];
i=1;
tic;

while(i<=num_random_fits)
    simulated_fitting_struct = generate_simulated_fitting_struct(fitting_struct);
    
    %     figure, plot_fitting_struct(simulated_fitting_struct);
    %     pause
    
    m0 = simulated_fitting_struct.m0;
    simulated_fitting_struct = fit_fitting_struct(m0, simulated_fitting_struct);
    
    fitting_struct.un_norm_simulated_fit_matrix = [fitting_struct.un_norm_simulated_fit_matrix; simulated_fitting_struct.un_norm_m simulated_fitting_struct.score];
    fitting_struct.simulated_fit_matrix = [fitting_struct.simulated_fit_matrix; simulated_fitting_struct.m simulated_fitting_struct.score];
    
    clear('simulated_fitting_struct');
    
    if(mod(i,10)==0)
        disp(['Completed ',num2str(i),' random fits ',timeString()])
    end
    
    i=i+1;
    
    et = toc;
    if(i>10)
        if(et > max_error_calc_time)
            break;
        end
    end
end

% remove weird outliers
% mean should ~ median for gaussian

fitting_struct.f.m_std = nanstd(fitting_struct.un_norm_simulated_fit_matrix);
fitting_struct.f.m_std = fitting_struct.f.m_std(1:end-1);
fitting_struct.un_norm_m_std = fitting_struct.f.m_std;

fitting_struct.un_norm_m_avg = nanmedian(fitting_struct.un_norm_simulated_fit_matrix);
fitting_struct.un_norm_m_avg= fitting_struct.un_norm_m_avg(1:end-1);

fitting_struct.m_avg = nanmean(fitting_struct.simulated_fit_matrix);
fitting_struct.m_avg = fitting_struct.m_avg(1:end-1);

fitting_struct.k_avg = fitting_struct.un_norm_m_avg(1:4);
fitting_struct.k_std = fitting_struct.un_norm_m_std(1:4);

k = fitting_struct.un_norm_m_avg(1:4);
i=5;
for(d=1:length(fitting_struct.data))
    gamma = fitting_struct.un_norm_m_avg(i:i+4);
    
    fitting_struct.data(d).un_norm_gamma_avg = gamma;
    fitting_struct.data(d).un_norm_gamma_std = fitting_struct.un_norm_m_std(i:i+4);
    
    if(fitting_struct.data(d).inst_freq_code == 1) % instantaneaous
        t = fitting_struct.t;
    else
        t = fitting_struct.t_freq;
    end
    
    fitting_struct.data(d).un_norm_avg_y_fit =  five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off,k,gamma);
    
    i=i+5;
end

% % calculate confidence interval for the parameters
fitting_struct = confidence_intervals(fitting_struct);

return;
end

function simulated_fitting_struct = generate_simulated_fitting_struct(fitting_struct)
% simulated data normalized mean +/- std_dev,
% gamma0 = gamma presumably fitted)

simulated_fitting_struct = fitting_struct;

simulated_fitting_struct.y = [];
simulated_fitting_struct.un_norm_y = [];
for(d=1:length(fitting_struct.data))
    
    simulated_fitting_struct.data(d).y = defined_randn(simulated_fitting_struct.data(d).y, simulated_fitting_struct.data(d).y_std);
    
    
    simulated_fitting_struct.data(d).un_norm_y = simulated_fitting_struct.data(d).range*simulated_fitting_struct.data(d).y + simulated_fitting_struct.data(d).minval;
    
    neg_idx = find(simulated_fitting_struct.data(d).un_norm_y<0);
    
    simulated_fitting_struct.data(d).y(neg_idx) = (1e-4 -  fitting_struct.data(d).minval)/fitting_struct.data(d).range;
    simulated_fitting_struct.data(d).un_norm_y(neg_idx) = 1e-4;
    
    
    simulated_fitting_struct.data(d).gamma0 = simulated_fitting_struct.data(d).gamma;
    
    simulated_fitting_struct.y = [simulated_fitting_struct.y simulated_fitting_struct.data(d).y];
    simulated_fitting_struct.un_norm_y = [simulated_fitting_struct.un_norm_y simulated_fitting_struct.data(d).un_norm_y];
end

simulated_fitting_struct.m0 = fitting_struct.m;
simulated_fitting_struct.un_norm_m0 = fitting_struct.un_norm_m;

simulated_fitting_struct = m_to_fitting_struct(simulated_fitting_struct.m0, simulated_fitting_struct);

return;
end




function [delta_p,delta_y] = uncertainties(r,jac,x,ybest)
%
% delta_p = uncertainties(parameters,r,jac)
%
% Compute the uncertainties DELTA_P on PARAMETERS from the residuals R and the
% jacobian JAC given by the function JACOB
r = r(:);
[m,n] = size(jac);
x = x(:);
ybest=ybest(:);

%calculate covariance
[Q R] = qr(jac,0);              % orthogonal-triangular decomposition of jac
Rinv = R\eye(size(R));          % compute R^-1
diag_info = sum((Rinv.*Rinv)')';
v = m-n;                        % number of degrees of liberty
rmse = sqrt(sum(r.*r)/v);
E = jac*Rinv;

% calculate confidence interval for the parameters
p_student_95=[8.34,-0.46,2.88,1.94];
t_student_95=polyval(p_student_95,1/v);

% delta_p = sqrt(diag_info) .* rmse*t_student_95;
delta_p = sqrt(diag_info).* rmse; % standard error of the parameters

delta_p=delta_p';

% Calculate confidence interval
delta_y = sqrt(1 + sum(E.*E,2));
delta_y = delta_y .* rmse * t_student_95;
delta_y=delta_y(:);

delta_y = delta_y';
return;
end 

function [jac,r] = jacob(y, fitting_struct, parameters)
%
% [jac,r] = jacob(x,y,fhandle,parameters)
%
% Compute the jacobian JAC = dY/dPARAMATERS of FHANDLE at the points X
% Compute the residuals R = Y - FHANDLE(PARAMETERS, X)
m = parameters;

fitting_struct = m_to_fitting_struct(m, fitting_struct);
fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);
yfit = fitting_struct.un_norm_y_fit;

n = length(y);
p = length(parameters);
jac = zeros(n,p);
r = y(:) - yfit(:);
delta_p = 1e-6;
zp = zeros(size(parameters));
zerosp = zeros(p,1);
for k = 1:p
    delta = zp;
    if (parameters(k) == 0)
        nb = sqrt(norm(parameters));
        delta(k) = delta_p * (nb + (nb==0));
    else
        delta(k) = delta_p*parameters(k);
    end
    m = parameters+delta;
    
    fitting_struct = m_to_fitting_struct(m, fitting_struct);
    fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct);
    yplus = fitting_struct.un_norm_y_fit;
    
    dy = yplus(:) - yfit(:);
    jac(:,k) = dy/delta(k);
end
return;
end 
