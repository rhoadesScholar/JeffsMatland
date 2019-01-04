function skeleton = danceSkeleton(skeleton, varargin)
    
    %parse inputs/initialize variables
    displayFrameRate_temp = 10; %hard coded default framerate
    skeleton.limbNames = fields(skeleton.tree);
    par = inputParser();
        addParameter(par, 'limbNames', skeleton.limbNames)                              %Can specify which limbs to display (instead of all)
        addParameter(par, 'frameInds', [1:displayFrameRate_temp:skeleton.NumFrames])    %Can specify which frames to display (instead of all)
        addParameter(par, 'displayString', '')                                          %Can specify additional string to display in video title   
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
    
    %get limb positions in global cooridinates
    skeleton.limbPos = getLimbPositions(skeleton);
    
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
    
    
    
    skeleton.movie = movie;
    
end

function limbPos = getLimbPositions(skeleton)
    
    hier = getTransformHierarchy(skeleton.tree, skeleton.limbNames, 'GLOBAL');
end

function hier = getTransformHierarchy(tree, limbs, parent)
    kids = {limbs(structfun(@(x) strcmpi(x, parent), tree))};
    for k = 1:numel(kids)
        hier.(kids{k}) = getTransformHierarchy(tree, limbs, kids{k});
    end
end
