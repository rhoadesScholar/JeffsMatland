function bargraph_fitting_struct(fitting_struct_array, title_string, strainnames, inputcolors, diff_flag, initial_flag)


if(nargin<3)
    strainnames = '';
end

if(nargin<4)
    inputcolors = {'b','c','g','m','r'};
end

if(nargin < 5)
    diff_flag=0;
end

if(nargin < 6)
    initial_flag=0;
end

if(isempty(inputcolors))
    inputcolors = {'b','c','g','m','r'};
end

colors = [];
for(j=1:length(inputcolors))
    if(~isnumeric(inputcolors{j}))
        colors = [colors; str2rgb( inputcolors{j} ) ];
    else
        colors = [colors;  inputcolors{j}];
    end
end

if(nargin<2)
    title_string='';
end

num_fitting_structs = length(fitting_struct_array);
fitting_struct = fitting_struct_array(1);

plot_columns = 3;
plot_rows = ceil(length(fitting_struct.data)/plot_columns + 1);

bw_legend=[];

subplot(plot_rows,plot_columns,1);
barvalues=[]; barerrors=[];
bw_ylabel = 'k (/sec)';
xlabel = {fitting_struct.f.param{1},fitting_struct.f.param{2},fitting_struct.f.param{3},fitting_struct.f.param{4} };

if(num_fitting_structs==1)
    for(q=1:length(fitting_struct_array(1).k0))
        if(initial_flag==0)
            barvalues(q,q) = fitting_struct_array(1).k(q); % k_avg
            if(~isempty(fitting_struct_array(1).k_std))
                barerrors(q,q) = fitting_struct_array(1).k_std(q); 
            else
                barerrors(q,q) = 1e-4;
            end
        else
            barvalues(q,q) = fitting_struct_array(1).k0(q); 
            if(~isempty(fitting_struct_array(1).k0_std))
                barerrors(q,q) = fitting_struct_array(1).k0_std(q); 
            else
                barerrors(q,q) = 1e-4;
            end
        end
    end
    barweb((barvalues), (barerrors), 4, xlabel, '', '', bw_ylabel, colors, bw_legend);
else
    for(i=1:length(fitting_struct.k0))
        for(j=1:num_fitting_structs)
            if(initial_flag==0)
                barvalues(i,j) = fitting_struct_array(j).k(i); % k_avg
                if(~isempty(fitting_struct_array(j).k_std))
                    barerrors(i,j) = fitting_struct_array(j).k_std(i); 
                else
                    barerrors(i,j) = 1e-4;
                end
            else
                barvalues(i,j) = fitting_struct_array(j).k0(i);
                
                if(~isempty(fitting_struct_array(j).k0_std))
                    barerrors(i,j) = fitting_struct_array(j).k0_std(i); 
                else
                    barerrors(i,j) = 1e-4;
                end
            end
        end
    end
    barweb((barvalues), (barerrors), 1, xlabel, '', '', bw_ylabel, colors, bw_legend);
end

set(gca,'yscale', 'log');
set(gca, 'color', 'none');
box off
%     dummystring = sprintf('%.3f\n%.3f\n%.3f\n%.3f',fitting_struct.k(1), fitting_struct.k(2), fitting_struct.k(3), fitting_struct.k(4));
%     text(fitting_struct.t(round(0.05*length(fitting_struct.t))),0.5, dummystring,'FontSize',10);

for(q=5:length(fitting_struct.f.param))
    oldname = fitting_struct.f.param{q};
    fitting_struct.f.param{q} = sprintf('g_%s',oldname(end));
    if(findstr(oldname,'ignore'))
        fitting_struct.f.param{q}='';
    end
end

q=5;
for(d=1:length(fitting_struct.data))
    hh=subplot(plot_rows,plot_columns,d+1); 
    % hh = figure(d+1); % DUDE
    
    barvalues=[]; barerrors=[];
    xlabel = {fitting_struct.f.param{q},fitting_struct.f.param{q+1},fitting_struct.f.param{q+2},fitting_struct.f.param{q+3},fitting_struct.f.param{q+4} };
    bw_ylabel = fix_title_string(fitting_struct.data(d).fieldname);
    
    if(diff_flag~=0)
        bw_ylabel = fix_title_string(sprintf('%s\ndelta g_1',fitting_struct.data(d).fieldname));
    end
    
    if(num_fitting_structs==1)
        
        if(initial_flag==0)
            for(q=1:length(fitting_struct_array(1).data(d).un_norm_gamma))
                barvalues(q,q) = fitting_struct_array(1).data(d).un_norm_gamma(q); % un_norm_gamma_avg
                if(~isempty(fitting_struct_array(1).data(d).un_norm_gamma_std))
                    barerrors(q,q) = fitting_struct_array(1).data(d).un_norm_gamma_std(q); 
                else
                    barerrors(q,q) = 1e-4;
                end
            end
        else
            for(q=1:length(fitting_struct_array(1).data(d).un_norm_gamma0))
                barvalues(q,q) = fitting_struct_array(1).data(d).un_norm_gamma0(q);
                if(~isempty(fitting_struct_array(1).data(d).un_norm_gamma0_std))
                    barerrors(q,q) = fitting_struct_array(1).data(d).un_norm_gamma0_std(q); 
                else
                    barerrors(q,q) = 1e-4;
                end
            end
        end
        
        if(diff_flag==1)
            barvalues = fitting_struct_array(1).data(d).usage_vector'.*(barvalues - barvalues(1,1));
            barerrors = sqrt(fitting_struct_array(1).data(d).usage_vector'.*(barerrors.^2 + barerrors(1,1)^2));
        end
        if(diff_flag==2)
            barvalues = fitting_struct_array(1).data(d).usage_vector'.*((barvalues-min(barvalues))./(max(barvalues)-min(barvalues)));
            barerrors = sqrt(fitting_struct_array(1).data(d).usage_vector'.*((barerrors./barvalues).^2 + (barerrors(1,1)/barvalues(1,1))^2));
        end
        
        barweb(barvalues, barerrors, 5, xlabel, '', '', bw_ylabel, colors, bw_legend);
    else
        
        if(initial_flag==0)
            for(i=1:length(fitting_struct.data(d).un_norm_gamma))
                for(j=1:num_fitting_structs)
                    barvalues(i,j) = fitting_struct_array(j).data(d).un_norm_gamma(i); % un_norm_gamma_avg
                    if(~isempty(fitting_struct_array(j).data(d).un_norm_gamma_std))
                        barerrors(i,j) = fitting_struct_array(j).data(d).un_norm_gamma_std(i); 
                    else
                        barerrors(i,j) = 1e-4;
                    end
                end
            end
        else
            for(i=1:length(fitting_struct.data(d).un_norm_gamma0))
                for(j=1:num_fitting_structs)
                    barvalues(i,j) = fitting_struct_array(j).data(d).un_norm_gamma0(i);
                    if(~isempty(fitting_struct_array(j).data(d).un_norm_gamma0_std))
                        barerrors(i,j) = fitting_struct_array(j).data(d).un_norm_gamma0_std(i); 
                    else
                        barerrors(i,j) = 1e-4;
                    end
                end
            end
        end
        
        if(diff_flag==1)
            for(j=1:num_fitting_structs)
                barvalues(:,j) = fitting_struct_array(j).data(d).usage_vector'.*(barvalues(:,j) - barvalues(1,j));
                barerrors(:,j) = sqrt(fitting_struct_array(j).data(d).usage_vector'.*(barerrors(:,j).^2 + barerrors(1,j)^2));
            end
        end
        if(diff_flag==2)
            for(j=1:num_fitting_structs)
                barvalues(:,j) = fitting_struct_array(1).data(d).usage_vector'.*((barvalues(:,j)-min(barvalues(:,j)))./(max(barvalues(:,j))-min(barvalues(:,j))));
                barerrors(:,j) = sqrt(fitting_struct_array(j).data(d).usage_vector'.*((barerrors(:,j)./barvalues(:,j)).^2 + (barerrors(1,j)/barvalues(1,j))^2));
            end
        end
        
        
        barweb(barvalues, barerrors, 1, xlabel, '', '', bw_ylabel, colors, bw_legend);
    end
    
    
    
    set(gca, 'color', 'none');
    box off
    
    if(fitting_struct.data(d).inst_freq_code == 1)
        if(strcmp(fitting_struct.data(d).fieldname,'speed'))
            ymin = 0;
            ymax = 0.25;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'ecc'))
            ymin = 0.940;
            ymax = 0.965;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'ecc_omegaupsilon'))
            ymin = 0.55;
            ymax = 0.85;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'body_angle'))
            ymin = 145;
            ymax = 175;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'head_angle'))
            ymin = 135;
            ymax = 150;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'tail_angle'))
            ymin = 140;
            ymax = 155;
        end
        if(strcmp(fitting_struct.data(d).fieldname,'revlength'))
            ymin = 0;
            ymax = 1.25;
        end
        %    ymin = min(ymin, (min(min(barvalues)) - nanmedian(nanmedian(barerrors))));
        ymax = max(ymax, (max(max(barvalues)) + nanmedian(nanmedian(barerrors))));
    end
    if(fitting_struct.data(d).inst_freq_code == 2) % is freq
        ymin = 0;
        ymax = max(max(barvalues)) + max(max(barerrors));
        
        if(ymax > 0.5 && ymax < 1)
            ymax = 1;
        else
            ymax = custom_round(ymax,0.5);
        end
        if(ymax <= ymin)
            ymax = 0.5;
        end
    end
    if(diff_flag==0)
        ylim([ymin ymax]);
    end
    
    box off
    
    
    %     dummystring = sprintf('%.3f   %.3f   %.3f   %.3f   %.3f', ...
    %         fitting_struct.data(d).un_norm_gamma(1), fitting_struct.data(d).un_norm_gamma(2), fitting_struct.data(d).un_norm_gamma(3), ...
    %         fitting_struct.data(d).un_norm_gamma(4), fitting_struct.data(d).un_norm_gamma(5));
    %     xloc = double(t(round(0.04*length(t))));
    %     yloc = double(ymin + 1.05*(ymax-ymin));
    %     text(xloc , yloc, dummystring,'FontSize',9);
    
    hold off;
    q=q+5;
end

if(~isempty(strainnames))
    subplot_legend(strainnames, inputcolors, plot_rows, plot_columns, (length(fitting_struct.data)+2));
end

p = axes('Position',[0 0 1 1],'Visible','off');
set(gcf,'CurrentAxes',p);
text(0.5,0.97,fix_title_string(title_string),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');

orient landscape;
set(gcf,'renderer','painters');
set(gcf,'PaperPositionMode','manual');
set(gcf, 'PaperPosition',[0 0 11 8.5]);
hold off;

% pause; % DUDE

return;
end

