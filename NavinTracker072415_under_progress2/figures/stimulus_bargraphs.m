function [ymin, ymax, barhandles] = stimulus_bargraphs(BinData, stimulus, attribute, axis_vector, ylabelstring)

if(nargin<5)
    ylabelstring = '';
end

bw_title = ''; % attribute;

bw_ylabel = attribute;
bw_legend=[];

ylabelstring = fix_title_string(ylabelstring);

cmap = stimulus_bargraph_colormap;

bw_xlabel = '';
groupname{1} = '';
if(isnumeric(stimulus))
    if(length(stimulus(:,1)) > 1)
        bw_xlabel = fix_title_string('stimulus');
        for(i=1:length(stimulus(:,1)))
            groupname{i} = sprintf('#%d',i);
        end
    end
else
    if(strcmp(stimulus,'staring') || strcmp(stimulus,'stare'))
        cmap = staring_bargraph_colormap;
    end
end

stattype = 'mean';

[barvalues, stddev, barerrors, n, bar_time_matrix] = stimulus_summary_stats(BinData, stimulus, attribute, stattype);

len_stim = size(barvalues,1);
len_stim_stats = size(barvalues,2);

% h = bar(barvalues, 1);
% hold on;
% colormap(cmap);
% h.xlabel = groupname;
% vals = matrix_to_vector(barvalues);
% errs = matrix_to_vector(barerrors);
% xpos = 1:length(vals);
% h = errorbar(xpos, vals, errs,'k');
% set(h,'linestyle','none');

%barweb(barvalues, stddev, 1, groupname, bw_title, bw_xlabel, bw_ylabel, cmap, bw_legend);
barhandles = barweb(barvalues, barerrors, 1, groupname, bw_title, bw_xlabel, bw_ylabel, cmap, bw_legend);

barhandles.datapoints=[];
y=[];
if(len_stim==1)
    xx = (get(barhandles.errors,'xdata'));
    x_coords = [];
    for(i=1:length(xx))
        if(sum(isnan(xx{i}))==0)
            x_coords = [x_coords; (xx{i})];
        end
    end
    
    
    for(q=1:len_stim)
        kkk=1;
        for(k=1:len_stim_stats)
            hold on;
            text(x_coords(k,q), 0, sprintf('%.0f - %.0f',bar_time_matrix(q,kkk), bar_time_matrix(q,kkk+1)), 'HorizontalAlignment','center','VerticalAlignment','top');
            kkk = kkk+2;
        end
    end
    
    for(q=1:len_stim)
        if(length(BinData)>1)
            hold on
            x=[]; y=[];
            for(p=1:length(BinData))
                b = stimulus_summary_stats(BinData(p), stimulus(q,:), attribute, stattype);
                for(k=1:len_stim_stats)
                    x = [x x_coords(k,q)];
                    y = [y b(k)];
                end
            end
            barhandles.datapoints = plot(x,y,'ok');
        end
    end
end

ymin = min([axis_vector(1) y]);
ymax = max([axis_vector(2) y]);

if( (max(max(barvalues)) + max(max(barerrors))) > ymax )
    ymax = (max(max(barvalues)) + max(max(barerrors)));
    ymax = ymax(1);
    if(~isempty(regexpi(attribute,'freq')))
        ymax=custom_round(ymax, 0.25, 'ceil');
    end
end

if( (min(min(barvalues)) - max(max(barerrors))) < ymin )
    ymin = (min(min(barvalues)) - max(max(barerrors)));
    ymin = ymin(1);
    if(~isempty(regexpi(attribute,'freq')))
        ymin=0; % custom_round(ymin, 0.25, 'ceil');
    end
end


if(ymin<0) % since ymin is already defined as being negative, we can go even more negative if need be
    if( min(min(barvalues)) - max(max(barerrors)) < ymin )
        ymin = min(min(barvalues)) - max(max(barerrors));
        ymin = ymin(1);
        %         if(abs(ymin)>0.25)
        %             ymin=custom_round(ymin, 0.25);
        %         else
        %             if(abs(ymin)>0.1)
        %                 ymin=custom_round(ymin, 0.1);
        %             end
        %         end
    end
    
    if(ymax<0)
        ymax=0;
    end
end

if(ymax<=ymin)
    if(abs(ymin)>1e-4)
        ymax = 1.1*ymin;
    else
        ymax = 0.1;
    end
end

ylim([ymin, ymax]);
ylabel(ylabelstring);

% stats for comparing the pre-stim values within a given stimulus batch
% ie: pre-stim w/ on-response, on-equilib, off-response, off-equilib
% barhandles.stat_symbols = [];
% if(length(stimulus(:,1))==1)
%     for(i=1:len_stim_stats)
%         labll{i} = num2str(i);
%     end
%
%     for(i=1:length(stimulus(:,1)))
%         p_value_vector = multicompare_to_base_value(barvalues(i,:), stddev(i,:), n(i,:), labll);
%         signif_symbols = p_value_vector_to_significance_thresh(p_value_vector);
%
%         for(k=1:len_stim_stats)
%             if(~isempty(signif_symbols{k}))
%                 x = get(barhandles.errors(k), 'xdata');
%                 x=x(1);
%
%                 y = max(get(gca,'ylim'));
%                 barhandles.stat_symbols(k) = text(x,y, signif_symbols{k}, 'FontName','Helvetica','HorizontalAlignment','center' );
%             else
%                 barhandles.stat_symbols(k) = -10;
%             end
%         end
%     end
% end

clear('barvalues');
clear('barerrors');

hold off

return;
end

function x = stimulus_bargraph_colormap()


% x = [0.7 0.7 0.7; ...
%     0 1 1; ...
%     0.7 0.7 1];

x = [0.7 0.7 0.7; ...   % mean before stimulus
    0 0 1; ...          % max/min 1st half of stimulus
    0 1 1; ...          % mean 2nd half of stimulus
    0.7 0.7 1; ...      % max/min 1st half of post-stimulus
    0.7 0.7 0.7];       % mean 2nd half of post-stimulus

% x = [0 0 1; ...
%     0 1 1; ...
%     0 1 0; ...
%     1 0 1; ...
%     1 0 0];

return;
end

function x = staring_bargraph_colormap()

x = [0.7 0.7 0.7; ...   % food   gray
    0 0 1; ...          % 0-5min blue
    0 1 1; ...          % 5-10   cyan
    0 0.5 0; ...        % 10-15  dark green
    0.5 0.5 0; ...          % 15-20  yellow
    1 0 1; ...    % 20-30  magenta
    1 0 0; ];    % 30-60  red


return;
end
