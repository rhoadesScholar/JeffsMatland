function [p] = steamgraph(data, varargin)
% STEAMGRAPH displays a smoothed, sorted, centered area plot
%
% Based on excellent tutorial provided by Nathan Yau
% at flowingdata.com
% url for original R tutorial
% http://flowingdata.com/2012/07/03/a-variety-of-area-charts-with-r/
%
% Nathan Yau's tutorial presents a R implementation of the steamgraph as
% described in Byron and Wattenberg, InfoVis 2008.
% 'Stacked Graphs - Geometry & Aesthetics'
%
% Java implementation
% https://github.com/leebyron/streamgraph_generator
%
% This function is a Matlab implementation of equations delineated in their
% manuscript.
%
% INPUTS:
% * DATA : numeric matrix;
%
% OTHER PARAMETERS (passed as parameter-value pairs)
% * 'Colormap': 'gradient' to use 1 out of 657 color options. 
%               'cbrewer' to use a color brewer set palatte.

%                See http://colorbrewer2.org/
%
%                Matlab File Exchange Entry:
%                http://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab
%
% DEFAULT : 'cbrewer'
%
% * 'ColorLevels': User selected color values associated with color choice;
% IF 'cbrewer' selected then user must input cell array with name of
% category and palette.
% See http://colorbrewer2.org/ for categories and color palettes
% EXAMPLE = {'div','PuOr'} % 'diverging' and 'Purple to Orange' palette
%
% IF 'gradient' selected then user must input a cell array with the min and max colors to
% use; intervening colors will be interpolated.
% EXAMPLE : {min,max} = {'green','red'};
%
%
% DEFAULT : {'seq','Blues'}
%
% * 'SortLayers': Logical to apply layer sort algorithm to improve presentation of curves;
% USE true or false; DEFAULT is false;
%
%
% * 'SmoothLayers':  Logical to generate smooth curves to give Steamgraph aesthetic;
% USE true or false; DEFAULT is false;
%
%
% OUTPUTS:
% p : Parameters used for plot.
% hImage : Steamgraph plot
% 
%
% USAGE:
%
% -------- INITIALIZE FAKE DATA
% numCols = 20;
% numLayers = 20;
% Data = nan(numLayers,numCols);
% 
% for i = 1:numLayers
%    heights = 1 ./ rand(1,numCols);
%    newRow = heights .* exp(-heights .* heights);
%    Data(i,:) = newRow;
% end
%
% -------- EXAMPLE USAGE
% TO OBSERVE DEFAULT LTS:
% p = steamgraph(fakeData)

% WITH PARAMETERS
% p = steamgraph(Data,'ColorMap','gradient','ColorLevels',{'white','black'},'SortLayers',1)

% Copyright The MathWorks, Inc. 2014


% Handle missing inputs
if nargin < 1, error('Steamgraph requires at least one input argument'); end

% Parse parameter/value inputs
p = parseInputs(data, varargin{:});

% Create SteamGraph
p = plotSteamGraph(p, data); % New properties hImage and cdata added

% Set outputs

end

% ---------------------- Blah ----------------------

% Parse PV inputs & return structure of parameters
function param = parseInputs(data, varargin)

load('colorbrewer.mat')
load('colorgradient.mat')

p = inputParser;

p.addParamValue('ColorMap','cbrewer');
p.addParamValue('ColorLevels',{'seq','Blues'});
p.addParamValue('SortLayers', false, @(x)islogical(logical(x)));
p.addParamValue('SmoothLayers', false, @(x)islogical(logical(x)));
p.parse(varargin{:});

param = p.Results;

[param.numRows , param.numCols] = size(data);

switch param.ColorMap
    case 'cbrewer'
        tempColors = colorbrewer.(param.ColorLevels{1}).(param.ColorLevels{2});
        param.colors2use = getColorsSP(param.numRows, tempColors, param.ColorMap);

    case 'gradient'
        minColor = GradientCNs.RGB{strcmpi(param.ColorLevels{1},GradientCNs.ColorName)};
        maxColor = GradientCNs.RGB{strcmpi(param.ColorLevels{2},GradientCNs.ColorName)};
        
        tempColors = [minColor ; maxColor];
        param.colors2use = getColorsSP(param.numRows, tempColors, param.ColorMap);
end

end

% Visualize steamplot
function p = plotSteamGraph(p, data)

data2use = data;

% Sorting the layers by the weight of each layer can enhance smaller curves
% See Byron and Wattenburg for detials.

if p.SortLayers
    
    data2use = data(1,:);
    weights = sum(data,2); % Get layer/row sums
    topWeight = weights(1);
    bottomWeight = weights(1);
    
    for sortI = 2:size(data,1)
        if topWeight > bottomWeight
            data2use = [data2use ; data(sortI,:)];
            topWeight = topWeight + weights(sortI);
        else
            data2use = [data(sortI,:) ; data2use];
            bottomWeight = bottomWeight + weights(sortI);
        end
    end
end

% Smooth the data for the Steamgraph aesthetic

if p.SmoothLayers
    
    numpoints = 200;
    
    smoothFactor = linspace(1,p.numCols,numpoints);
    firstRow = interp1(1:length(data(1,:)),data(1,:),smoothFactor,'spline');
    firstRow = arrayfun(@(x) zeroNegatives(x), firstRow);
    
    smoothData = zeros(size(data,1),numpoints);
    smoothData(1,:) = firstRow;
    
    if size(data,1) > 1
        for i8 = 2:size(data,1)
            splineRow = interp1(1:length(data(i8,:)) , data(i8,:) , smoothFactor,'spline');
            splineRow = arrayfun(@(x) zeroNegatives(x), splineRow);
            
            smoothData(i8,:) = splineRow;
            
        end
    end
    data2use = smoothData;
end

n = size(data2use,1);
i = 1:length(data2use(:,1));
partF = n - i + 1;
parts = nan(size(data2use));
for piter = 1:n
    parts(piter,:) = data2use(piter,:) .* partF(piter);
end

% This will reduce wiggle by minimizing by optimizing the vertical offset 
% and finding the best layer sorting. See Byron and Wattenburg for details.

theSums = sum(parts);
totals = sum(data2use);
yOffset = theSums / (n + 1); % ThemeRiver which centers the middle layer to 0
yLower = min(yOffset);
yUpper = max(yOffset + totals);

% Initialize blank plot
p.hImage = axes;
set(p.hImage,'XLim', [1,length(data2use)], 'YLim', [yLower  yUpper])
set(p.hImage,'XTick',[]);

nColors = abs(p.colors2use)./255;

for plotI = 1:size(data2use,1)
    
    X = [1:length(data2use(plotI,:)) , fliplr(1:length(data2use(plotI,:)))];
    Y = [data2use(plotI,:) + yOffset , fliplr(yOffset)];
    
    patch(X,Y,nColors(plotI,:), 'EdgeColor',[1 1 1])
    
    yOffset = yOffset + data2use(plotI,:);
end

end

% Helper function to remove negative values
function outval = zeroNegatives(x)

if x < 0
    outval = 0;
else
    outval = x;
end

end

