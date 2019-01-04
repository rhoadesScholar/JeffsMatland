function movie = danceLimbs(limbPos, varargin) ####INCOMPLETE
    
    %parse inputs/initialize variables
    frameRate_temp = 10; %hard coded default framerate
    limbNames_temp = fields(limbPos);
    par = inputParser();
        addParameter(par, 'EulerRotationOrder', 'ZYX')
        addParameter(par, 'limbNames', limbNames_temp)
        addParameter(par, 'frameInds', [1:frameRate_temp:size(limbPos.(limbNames_temp{1}), 3)])
        addParameter(par, 'displayString', '')        
        addParameter(par, 'plotColor', 'k')
        addParameter(par, 'Xcolor', [1 1 1])
        addParameter(par, 'Ycolor', [1 1 1])
        addParameter(par, 'Zcolor', [1 1 1])
        addParameter(par, 'zlimit', [0 250])
        addParameter(par, 'xlimit', [-350 350])        
        addParameter(par, 'ylimit', [-350 350])    
    parse(par, varargin{:});    
        results_temp = fields(par.Results);
        for r = 1:numel(results_temp)
            eval(sprintf('%s = extractfield(par.Results, %s);', results_temp{r}, results_temp{r}))
        end
    
    toClear_temp = whos('*_temp');
    toClear_temp = {toClear_temp.name, 'toClear_temp'};
    clear(toClear_temp{:});
    %done parsing/initializing variables
    
    %setup plot
    fig = figure;
    set(fig,'Color', plotColor)
    ax = gca;
    axis(ax,'manual')
    grid on;
    set(ax,'Color', plotColor)
    set(ax,'Xcolor', Xcolor);
    set(ax,'Ycolor', Ycolor);
    set(ax,'Zcolor', Zcolor);
   
    zlim(zlimit)
    xlim(xlimit)
    ylim(ylimit)
    
    set(ax,'XTickLabels',[],'YTickLabels',[],'ZTickLabels',[])





end