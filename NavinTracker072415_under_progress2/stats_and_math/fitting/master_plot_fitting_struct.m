function master_plot_fitting_struct(fit_structs, fitting_struct, stimulus, localpath, prefix)

if(nargin<3)
    stimulus = [];
end

if(nargin<5)
    localpath = '';
    prefix = '';
end

if(~isempty(localpath))
   if(localpath(end)~=filesep)
       localpath = sprintf('%s%s',localpath,filesep);
   end
end

temp_prefix = sprintf('page.%d',randint(1000));

k = length(fit_structs);

aic_vector = [];
for(i=1:k)
   figure(i), plot_fitting_struct(fit_structs(i), stimulus, sprintf('%s %s',prefix,fit_structs(i).model) );
   save_figure(i, tempdir, temp_prefix, num2str(i),1); close all;
   aic_vector = [aic_vector fit_structs(i).f.aic];
end
best_delta_aic = max(aic_vector - min(aic_vector));

k=k+1;
figure(k), plot_fitting_struct(fitting_struct, stimulus, ...
    sprintf('%s best model: %s delta-AIC = %f',prefix,fitting_struct.model,best_delta_aic) );
save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;


k=k+1;
figure(k), plot_fitting_histograms(fitting_struct, sprintf('%s simulated error estimates for %s',prefix,fitting_struct.model) );
save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

k=k+1;
figure(k), bargraph_fitting_struct(fitting_struct, fitting_struct.model);
save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;

if(~isempty(prefix))
    pool_temp_pdfs(k, localpath, sprintf('%s.fit',prefix), temp_prefix);
    
%     dummystring = sprintf('%s%s.fit_structs.mat',localpath, prefix);
%     save(dummystring,'fit_structs');
%     
%     dummystring = sprintf('%s%s.fitting_struct.mat',localpath, prefix);
%     save(dummystring,'fitting_struct');
end

close all;

return;
end
