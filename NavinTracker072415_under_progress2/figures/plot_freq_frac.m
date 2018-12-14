function ylim_vector = plot_freq_frac(BinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, mvt, color, panel_number, input_ylim_vector)
% plot_freq_frac(BinData, Tracks, stimulus, plot_rows, plot_columns, xmin, xmax, xlabelstring, mvt, color, panel_number, input_ylim_vector)

global Prefs;

ylim_vector = [];

if(nargin<12)
    input_ylim_vector=[];
end

freq_field = sprintf('%s_freq',mvt);
freq_s_field = sprintf('%s_freq_s',mvt);
freq_err_field = sprintf('%s_freq_err',mvt);

frac_field = sprintf('frac_%s',mvt);
frac_s_field = sprintf('frac_%s',mvt);
frac_err_field = sprintf('frac_%s_err',mvt);

% freq
ylabelstring = sprintf('freq\n%s\n(/min)', mvt);

ymax = 1.5;
ymin=0;


freq = BinData(1).(freq_field);
frac = BinData(1).(frac_field);
n_freq = BinData(1).n_freq;
freq_err = BinData(1).(freq_err_field);
frac_err = BinData(1).(frac_err_field);
if(length(BinData)>1)
    freq = []; frac = []; n_freq = [];
    for(i=1:length(BinData))
        freq = [freq; BinData(i).(freq_field)];
        frac = [frac; BinData(i).(frac_field)];
        n_freq = [n_freq; BinData(i).n_freq];
    end
    freq_err = nanstderr(freq);
    frac_err = nanstderr(frac);
    freq = nanmean(freq);
    frac = nanmean(frac);
    n_freq = nansum(n_freq);
end



min_val = min(freq);
mean_err = nanmean(freq_err);

del = 10^round(log10((max(freq + mean_err ) - min(freq - mean_err ))/5));


ymax = max(ymax, max(freq + mean_err ));
ymax = custom_round(ymax, del,'ceil');


if(min_val < 0)
    ymin = min(freq - mean_err );
    ymin = custom_round(ymin, del,'floor');
end


if(~isempty(input_ylim_vector))
    ymin = input_ylim_vector(1);
    ymax = input_ylim_vector(2);
end


if(isnan(ymin))
    ymin = 0;
end

if((isnan(ymax)))
    ymax = 0.5;
end
    

if(isempty(ymin))
    ymin = 0;
end

if((isempty(ymax)))
    ymax = 0.5;
end

if(ymin >= ymax)
   ymax = ymin + 0.5; 
end


ylim_vector = [ylim_vector ymin ymax];

hh = errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(2), ...
    [xmin xmax ymin ymax], ...
    freq_field, color, ...
    xlabelstring, ylabelstring);
if(~isempty(stimulus))
    bargraph_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(3), ...
        [ymin ymax-0.5], ...
        freq_field, ...
        ylabelstring);
else
    if(Prefs.graph_no_stim_width > Prefs.FreqBinSize)
        if(~isfield(BinData,'xlabel'))
            plot_long_bins(BinData, freq_field, [xmin xmax ymin ymax], color, plot_rows, plot_columns, panel_number(3),xlabelstring, ylabelstring);
        end
    end
end


% frac
if(panel_number(4) >0 && panel_number(5) >0 )
    ylabelstring = sprintf('frac\n%s',mvt);
    
    
    
    ymax = max(0.2, max(frac + frac_err));
    ymin = 0;
    
    
    
    min_val = min(frac);
    if(min_val < 0)
        ymin = min(frac - frac_err);
        ymax = max(frac + frac_err);
        del = 10^round(log10((ymax-ymin)/5));
        ymin = custom_round(ymin, del);
        ymax = custom_round(ymax, del);
    end
    
    
    
    if(~isempty(input_ylim_vector))
        ymin = input_ylim_vector(3);
        ymax = input_ylim_vector(4);
    end
    
    
    
    ylim_vector = [ylim_vector ymin ymax];
    
    
   
    errorshade_stimshade_lineplot_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(4), ...
        [xmin xmax ymin ymax], ...
        frac_field, color, ...
        xlabelstring, ylabelstring);
    if(~isempty(stimulus))
        bargraph_BinData(BinData, stimulus, plot_rows, plot_columns, panel_number(5), ...
            [ymin ymax/2], ...
            frac_field, ...
            ylabelstring);
    else
        if(Prefs.graph_no_stim_width > Prefs.SpeedEccBinSize)
            if(~isfield(BinData,'xlabel'))
                plot_long_bins(BinData, frac_field, [xmin xmax ymin ymax], color, plot_rows, plot_columns, panel_number(5),xlabelstring, ylabelstring);
            end
        end
    end
end



% raster plot atop frequency plot if so desired
if(~isempty(Tracks) && panel_number(1)>0)
    mean_n_freq = round(max(n_freq));
    gg = mvt_init_ethogram(Tracks(1:mean_n_freq), stimulus, plot_rows, plot_columns, panel_number(1), mvt, 'k', [xmin xmax]);
    freq_plot_pos = get(hh, 'Position');
    set(gg,'Position',[freq_plot_pos(1), freq_plot_pos(2) + freq_plot_pos(4), freq_plot_pos(3), freq_plot_pos(4)]);
end

return;
end
