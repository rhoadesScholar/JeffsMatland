function best_model_vector = fit_params_and_model_simult(fitting_struct, stimulus)

num_cycles =10;

staring_flag=0;
if(nargin<2)
    staring_flag=1;
else
    if(isempty(stimulus))
        staring_flag=1;
    end
end

[num_models, k_usage_vector, gamma_usage_vector] = create_usage_vectors(staring_flag);

for(d=1:length(fitting_struct.data))
    working_fitting_struct = fitting_struct;
    
    if(working_fitting_struct.data(d).inst_freq_code==1)
        t = working_fitting_struct.t;
    else
        t = working_fitting_struct.t_freq;
    end
    
    aic = [];
    for(i=1:num_models)
        working_fitting_struct.data(d).k_usage_vector = k_usage_vector(i,:);
        working_fitting_struct.data(d).usage_vector = gamma_usage_vector(i,:);
        working_fitting_struct = fit_single_fitting_struct_data_five_state_on_off(working_fitting_struct, d);
        
        aic = [aic working_fitting_struct.data(d).aic];
                
    end
    
    best_model_index = find(aic == min(aic));
    
    working_fitting_struct.data(d).model_index = best_model_index;
    working_fitting_struct.data(d).k_usage_vector = k_usage_vector(best_model_index,:);
    working_fitting_struct.data(d).usage_vector = gamma_usage_vector(best_model_index,:);
    working_fitting_struct = fit_single_fitting_struct_data_five_state_on_off(working_fitting_struct, d);
    
    
%    disp([sprintf('%s\t%d\t',working_fitting_struct.data(d).fieldname, best_model_index),num2str(working_fitting_struct.data(d).k0), ' ', num2str(working_fitting_struct.data(d).k)])
%     errorline(t, working_fitting_struct.data(d).un_norm_y, working_fitting_struct.data(d).un_norm_y_err, 'ok');
%     hold on;
%     plot(t, working_fitting_struct.data(d).un_norm_y_fit,'r');
%     hold off;
%     pause
        
    fitting_struct.data(d) = working_fitting_struct.data(d);
    
    clear('working_fitting_struct');
end
figure(2), plot_fitting_struct(fitting_struct, stimulus);



model_vector = zeros(1,length(fitting_struct.data));
for(d=1:length(fitting_struct.data))
    model_vector(d) = fitting_struct.data(d).model_index;
end
[aic_best, working_fitting_struct] = score_params_and_model_simult(fitting_struct, model_vector, num_models, k_usage_vector, gamma_usage_vector);
best_model_vector = model_vector;
aic_prev = aic_best;
fitting_struct = working_fitting_struct;

aic_scores =[];
for(d=1:length(fitting_struct.data))
    aic_scores = [aic_scores -fitting_struct.data(d).aic];
end
[s,idx] = sort(aic_scores);
fitting_struct.data = fitting_struct.data(idx);

best_model_vector = [];
for(d=1:length(fitting_struct.data))
    best_model_vector = fitting_struct.data(d).model_index;
end

% disp([0 aic_best -aic_scores(idx)])
figure(3), plot_fitting_struct(fitting_struct, stimulus);
% pause

cycle=0;
stopflag=0;
while(stopflag == 0)
    
    cycle = cycle + 1;
    
    % sort data entries by aic score
    aic_scores =[];
    for(d=1:length(fitting_struct.data))
        aic_scores = [aic_scores -fitting_struct.data(d).aic];
    end
    
    [s,idx] = sort(aic_scores);
    fitting_struct.data = fitting_struct.data(idx);
    
    best_model_vector = [];
    for(d=1:length(fitting_struct.data))
        best_model_vector = [best_model_vector fitting_struct.data(d).model_index ];
    end
    best_model_vector

    
    for(d=1:length(fitting_struct.data))
        for(i=1:num_models)
            
            
            model_vector = best_model_vector;
            model_vector(d) = i;
            
            [aic, working_fitting_struct] = score_params_and_model_simult(fitting_struct, model_vector, num_models, k_usage_vector, gamma_usage_vector, i);

            
            if(aic < aic_best)
                aic_best = aic;
                best_model_vector = model_vector;
                fitting_struct = working_fitting_struct;
            end
            
            disp([cycle d i aic aic_best model_vector])
        end
    end
    
    if(abs(aic_best - aic_prev)<1e-4)
       stopflag=1;
    end
    
    [aic_prev, fitting_struct] = score_params_and_model_simult(fitting_struct, best_model_vector, num_models, k_usage_vector, gamma_usage_vector);
    
    figure(3+cycle), plot_fitting_struct(fitting_struct, stimulus);

end

return;
end

function [aic, out_fitting_struct] = score_params_and_model_simult(fitting_struct, model_vector, num_models, k_usage_vector, gamma_usage_vector, model_idx)

out_fitting_struct = fitting_struct;

if(nargin<6)
    model_idx = 0;
end

if(model_idx==0)
    mod_start =  1;
    mod_end = num_models;
    out_fitting_struct.data = [];
else
    mod_start = model_idx;
    mod_end = model_idx;
    d=1;
    while(d<=length(out_fitting_struct.data))
        if(out_fitting_struct.data(d).model_index == model_idx)
            out_fitting_struct.data(d) = [];
        else
            d=d+1;
        end
    end
end


for(i=mod_start:mod_end)
    
    working_fitting_struct = fitting_struct;
    working_fitting_struct.data = [];
    working_fitting_struct.m0 = [];
    working_fitting_struct.df = [];
    working_fitting_struct.real_df = [];
    
    working_fitting_struct.usage_vector = [];
    working_fitting_struct.usage_vector = k_usage_vector(i,:);
    working_fitting_struct.m0 = working_fitting_struct.k0;
    working_fitting_struct.df = fitting_struct.df(1:4);
    
    working_fitting_struct.t_v = [];
    working_fitting_struct.y = [];
    working_fitting_struct.y_fit = [];
    
    dd=0;
    for(d=1:length(fitting_struct.data))
        if(model_vector(d) == i)
            dd = dd+1;
            working_fitting_struct.data = [working_fitting_struct.data fitting_struct.data(d)];
            working_fitting_struct.data(dd).k_usage_vector = k_usage_vector(i,:);
            working_fitting_struct.data(dd).usage_vector = gamma_usage_vector(i,:);
            working_fitting_struct.data(dd).model_index = i;
            
            working_fitting_struct.usage_vector = [working_fitting_struct.usage_vector working_fitting_struct.data(dd).usage_vector];
            working_fitting_struct.m0 = [working_fitting_struct.m0 working_fitting_struct.data(dd).gamma0];
            
            working_fitting_struct.y = [working_fitting_struct.y working_fitting_struct.data(dd).y];
            working_fitting_struct.y_fit = [working_fitting_struct.y working_fitting_struct.data(dd).y];
            
            if(working_fitting_struct.data(dd).inst_freq_code == 1)
                working_fitting_struct.t_v = [working_fitting_struct.t_v working_fitting_struct.t];
            else
                working_fitting_struct.t_v = [working_fitting_struct.t_v working_fitting_struct.t_freq];
            end
            
            working_fitting_struct.df = [working_fitting_struct.df  working_fitting_struct.data(dd).gamma_df];
        end
    end
    
    m0 = working_fitting_struct.usage_vector.*working_fitting_struct.m0;
    working_fitting_struct = fit_fitting_struct(m0, working_fitting_struct);
    
    figure, plot_fitting_struct(working_fitting_struct, [], num2str(i));
    
    out_fitting_struct.data = [out_fitting_struct.data working_fitting_struct.data];
    
    clear('working_fitting_struct');
end

idx=[];
for(d=1:length(fitting_struct.data))
    dd=1;
    while(strcmp(fitting_struct.data(d).fieldname, out_fitting_struct.data(dd).fieldname)==0)
        dd=dd+1;
        if(dd>d)
            fitting_struct.data(d).fieldname
            out_fitting_struct.data(dd).fieldname
        end
    end
    idx = [idx dd];
end
out_fitting_struct.data = out_fitting_struct.data(idx);

out_fitting_struct.t_v = [];
out_fitting_struct.y = [];
out_fitting_struct.y_fit = [];
aic=0;
for(d=1:length(out_fitting_struct.data))
    
    aic = aic + out_fitting_struct.data(d).aic;
    
    out_fitting_struct.y = [out_fitting_struct.y out_fitting_struct.data(d).y];
    out_fitting_struct.y_fit = [out_fitting_struct.y_fit out_fitting_struct.data(d).y_fit];
    
    if(out_fitting_struct.data(d).inst_freq_code == 1)
        out_fitting_struct.t_v = [out_fitting_struct.t_v out_fitting_struct.t];
    else
        out_fitting_struct.t_v = [out_fitting_struct.t_v out_fitting_struct.t_freq];
    end
    
end

return;
end
