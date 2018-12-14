function k = plot_fitting_errors(start_fignum, fitting_struct, prefix, temp_prefix)

param_covar_fieldnames = []; % {'speed','Rev_freq','body_angle','revlength'};

if(nargin<3)
    prefix = '';
end

if(nargin<4)
    temp_prefix = sprintf('page.%d',randint(1000));
end

if(nargin<4)
    start_fignum = 1;
end


k = start_fignum;

figure(k), plot_fitting_histograms(fitting_struct, sprintf('%s simulated error estimates for %s',prefix,fitting_struct.model) ); 
if(~isempty(prefix))
    save_figure(k, tempdir, temp_prefix, num2str(k),1); close all;
end

for(i=1:length(param_covar_fieldnames))

k=k+1;
figure(k), plot_fit_parameter_covariance(k, fitting_struct, param_covar_fieldnames{i}, sprintf('%s simulated covariance for %s',prefix,fitting_struct.model) ); 
if(~isempty(prefix))
    save_figure(k, tempdir, temp_prefix, num2str(k),1); 
    k=k+1;
    save_figure(k, tempdir, temp_prefix, num2str(k),1); 
    k=k+1;
    save_figure(k, tempdir, temp_prefix, num2str(k),1);     
    close all;
end

end

return;
end
