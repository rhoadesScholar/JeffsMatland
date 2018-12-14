function plot_attribute_histograms(Tracks, stimulus, localpath, prefix, fignum_start)
% plot_attribute_histograms(Tracks, stimulus, localpath, prefix, fignum_start)


global Prefs;

if(nargin<2)
    stimulus=[];
    localpath='';
    prefix='';
    fignum_start=1;
end

if(nargin>2)
    if(~isempty(localpath) || ~isempty(prefix))
        if(isempty(localpath))
            localpath=pwd;
        end
        localpath = sprintf('%s%s',localpath,filesep);
    end
else
    localpath='';
    prefix='';
end

if(nargin < 5)
    fignum_start=1;
end

disp([sprintf('plot attribute histograms\t%s',timeString())])

temp_prefix = sprintf('page.%d',randint(1000));

title_string = fix_title_string(prefix);

attributes = {'Speed','revSpeed','Curvature','body_angle,','head_angle','tail_angle',

if(~isempty(stimulus))
    pool pre-stim data as defined for bargraphs
    pool post-stim data as defined for bargraphs
    stim?
    
end

% page 1
fignum = fignum_start;
hold off
hidden_figure(fignum);
plot_rows = 6; plot_columns=2;


return;
end




