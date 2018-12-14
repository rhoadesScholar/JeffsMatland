function [fit_structs, best_model_idx] = global_fit_BinData(inputBinData, inputstimulus, localpath, prefix, starttime, endtime)

if(nargin<4)
    localpath = '';
    prefix = '';
end

if(~isempty(localpath))
   if(localpath(end)~=filesep)
       localpath = sprintf('%s%s',localpath,filesep);
   end
end

if(nargin<6)
    starttime = min_struct_array(inputBinData,'time');
    endtime = max_struct_array(inputBinData,'time');
end

temp_prefix = sprintf('page.%d',randint(1000));

binwidth = round(mean(diff(inputBinData.freqtime)));

BinData = extract_BinData(inputBinData, starttime, endtime);


% re-bin so the fitting isn't biased by the more numerous instantaneous values
BinData = alternate_binwidth_BinData(BinData, binwidth);


if(~isempty(inputstimulus))
    stimulus = inputstimulus;
else
    stimulus(1) = min(0, min(BinData.time));
    stimulus(2) = 0;
    stimulus(3) = 0;
end   

fitting_struct = initialize_fitting_struct(BinData, stimulus, starttime, endtime);
close all;

 figure(20), plot_fitting_struct(fitting_struct, stimulus, sprintf('%s %s',prefix,'pre global fit') );
% best_model_idx = 1; fit_structs(1) = fitting_struct;
%best_model_vector = fit_params_and_model_simult(fitting_struct, inputstimulus);
%return;



k=0;
% fit to only one transition ... three state only
if(isempty(inputstimulus))
    k=k+1;
    m0 = fitting_struct.m0;
    fitting_struct.usage_vector = ones(1, length(fitting_struct.usage_vector));
    
    fitting_struct.model = 'three-state removal from food';
    fitting_struct.usage_vector(1)=0; m0(1)=0; % k1
    fitting_struct.usage_vector(2)=0; m0(2)=0; % k2
    i=5;
    for(d=1:length(fitting_struct.data))
        fitting_struct.data(d).k_usage_vector = [0 0 1 1];
        fitting_struct.data(d).usage_vector = ones(1,length(fitting_struct.data(d).gamma));
        fitting_struct.data(d).gamma = fitting_struct.data(d).gamma0;
        for(q=1:5)
            if(q==1) % A
                fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
            end
            if(q==2) % B
                fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
            end
            i=i+1;
        end
    end
    fitting_struct = m_to_fitting_struct(m0, fitting_struct);
    fitting_struct = fit_fitting_struct(m0, fitting_struct);
    fit_structs(k) = fitting_struct; % calc_fitting_errors(fitting_struct); 
    figure(k), plot_fitting_struct(fit_structs(k), stimulus, sprintf('%s %s',prefix,fit_structs(k).model) );
    save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;
else    
    
%     % two-state on -> two-state off
%     k=k+1;
%     m0 = fitting_struct.m0;
%     fitting_struct.usage_vector = ones(1, length(fitting_struct.usage_vector));
%     
%     fitting_struct.model = 'two-state-on-two-state-off';
%     fitting_struct.usage_vector(2)=0; m0(2)=0; % k2
%     fitting_struct.usage_vector(4)=0; m0(4)=0; % k4
%     i=5;
%     for(d=1:length(fitting_struct.data))
%         fitting_struct.data(d).k_usage_vector = [1 0 1 0];
%         fitting_struct.data(d).usage_vector = ones(1,length(fitting_struct.data(d).gamma));
%         fitting_struct.data(d).gamma = fitting_struct.data(d).gamma0;
%         for(q=1:5)
%             m0(i) = fitting_struct.data(d).gamma0(q);
%             if(q==2) % B
%                 fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
%             end
%             if(q==4) % D
%                 fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
%             end
%             i=i+1;
%         end
%     end
%     fitting_struct = m_to_fitting_struct(m0, fitting_struct);
%     fitting_struct = fit_fitting_struct(m0, fitting_struct);
%     fit_structs(k) = fitting_struct;
%     figure(k), plot_fitting_struct(fit_structs(k), stimulus, sprintf('%s %s',prefix,fit_structs(k).model) );
%     save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;


%     % two-state on -> three-state off
%     k=k+1;
%     m0 = fitting_struct.m0;
%     fitting_struct.usage_vector = ones(1, length(fitting_struct.usage_vector));
%     
%     fitting_struct.model = 'two-state-on-three-state-off';
%     fitting_struct.usage_vector(2)=0; m0(2)=0; % k2
%     i=5;
%     for(d=1:length(fitting_struct.data))
%         fitting_struct.data(d).k_usage_vector = [1 0 1 1];
%         fitting_struct.data(d).usage_vector = ones(1,length(fitting_struct.data(d).gamma));
%         fitting_struct.data(d).gamma = fitting_struct.data(d).gamma0;
%         for(q=1:5)
%             if(q==2) % B
%                 fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
%             end
%             i=i+1;
%         end
%     end
%     fitting_struct = m_to_fitting_struct(m0, fitting_struct);
%     fitting_struct = fit_fitting_struct(m0, fitting_struct);
%     fit_structs(k) = fitting_struct;
%     figure(k), plot_fitting_struct(fit_structs(k), stimulus, sprintf('%s %s',prefix,fit_structs(k).model) );
%     save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

    
%     % three-state on -> two-state off
%     k=k+1;
%     m0 = fitting_struct.m0;
%     fitting_struct.usage_vector = ones(1, length(fitting_struct.usage_vector));
%     
%     fitting_struct.model = 'three-state-on-two-state-off';
%     fitting_struct.usage_vector(4)=0; m0(4)=0; % k4
%     i=5;
%     for(d=1:length(fitting_struct.data))
%         fitting_struct.data(d).k_usage_vector = [1 1 1 0];
%         fitting_struct.data(d).usage_vector = ones(1,length(fitting_struct.data(d).gamma));
%         fitting_struct.data(d).gamma = fitting_struct.data(d).gamma0;
%         for(q=1:5)
%             if(q==4) % D
%                 fitting_struct.usage_vector(i)=0; m0(i) = 0; fitting_struct.data(d).usage_vector(q)=0;
%             end
%             i=i+1;
%         end
%     end
%     fitting_struct = m_to_fitting_struct(m0, fitting_struct);
%     fitting_struct = fit_fitting_struct(m0, fitting_struct);
%     fit_structs(k) = fitting_struct;
%     figure(k), plot_fitting_struct(fit_structs(k), stimulus, sprintf('%s %s',prefix,fit_structs(k).model) );
%     save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;
    

    % three-state on -> three-state off
    k=k+1;
    m0 = fitting_struct.m0;
    fitting_struct.model = 'three-state-on-three-state-off';
    fitting_struct.usage_vector = ones(1, length(fitting_struct.usage_vector));
    for(d=1:length(fitting_struct.data))
        fitting_struct.data(d).k_usage_vector = ones(1,length(fitting_struct.data(d).k));
        fitting_struct.data(d).usage_vector = ones(1,length(fitting_struct.data(d).gamma));
        fitting_struct.data(d).gamma = fitting_struct.data(d).gamma0;
    end
    fitting_struct = m_to_fitting_struct(m0, fitting_struct);
    fitting_struct = fit_fitting_struct(m0, fitting_struct);
    fit_structs(k) = fitting_struct;
    figure(k), plot_fitting_struct(fit_structs(k), stimulus, sprintf('%s %s',prefix,fit_structs(k).model) );
    save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;
    
end

clear('fitting_struct');
aic_vector = [];
for(k=1:length(fit_structs))
    aic_vector = [aic_vector fit_structs(k).f.aic];
end
best_model_idx = find(aic_vector == min(aic_vector));
best_delta_aic = max(aic_vector - min(aic_vector));

fit_structs(best_model_idx).is_best_flag = 1;
fitting_struct = fit_structs(best_model_idx);
fitting_struct = calc_fitting_errors( fitting_struct ); 

k=k+1;
figure(k), plot_fitting_struct(fitting_struct, stimulus, ...
    sprintf('%s best model: %s delta-AIC = %f',prefix,fitting_struct.model,best_delta_aic) );
save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

k=k+1;
figure(k), bargraph_fitting_struct(fitting_struct, fitting_struct.model);
save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

k=k+1;
k = plot_fitting_errors(k, fitting_struct, prefix, temp_prefix);


% k=k+1;
% figure(k), plot_fitting_histograms(fitting_struct, sprintf('%s simulated error estimates for %s',prefix,fitting_struct.model) ); 
% save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

if(~isempty(prefix))
    pool_temp_pdfs(k, localpath, sprintf('%s.fit',prefix), temp_prefix);
    
    dummystring = sprintf('%s%s.fit_structs.mat',localpath, prefix);
    save(dummystring,'fit_structs');
    
    dummystring = sprintf('%s%s.fitting_struct.mat',localpath, prefix);
    save(dummystring,'fitting_struct');
end

close all;

return;
end
