function [colors2use] = getColorsSP(numLayers, colorChoice, cMAP)
% GETCOLORSSP : Interpolates color gradient based on color inputs
%
% USAGE:
% [colors2use] = getColorsSP(numLayers, colorChoice, cMAP)
%
% INPUTS:
% * "numLayers" number of unique groups : in use through steamgraph it 
%   is extracted programmtically from row number from input matrix
%
% * "colorChoice" matrix of RGB
%
% * "cMAP" selection between different color strategies
%   1. 'cbrewer' utilizes colorbrewer categories
%   2. 'graident' utilizes two user selected colors
%
% EXAMPLES:
% getColorsSP(5, RGBmat, 'cbrewer')
%
% For detailed examples, see the associated document heatmap_examples.m

% Copyright The MathWorks, Inc. 2014

% colorChoice = colorbrewer.seq.Blues
% numLayers = number of rows

switch cMAP
    
    case 'cbrewer'
        
        if numLayers > numel(colorChoice)
            tempColors = colorChoice{numel(colorChoice)};
            
            maxNumel = numel(colorChoice);
            
            xVals = linspace(1,maxNumel,numLayers);
            colors2use = nan(numLayers,3);
            for i = 1:3
                colors2use(:,i) = round(interp1(1:length(tempColors),tempColors(:,i), xVals, 'spline'))';
            end
        else
            colors2use = colorChoice{numLayers};
        end
        
    case 'gradient'
        
        if numLayers > 2
            xVals = linspace(1,2,numLayers);
            colors2use = nan(numLayers,3);
            for i = 1:3
                colors2use(:,i) = round(interp1(1:size(colorChoice,1),colorChoice(:,i), xVals, 'spline'))';
            end
        else
            colors2use = colorChoice;
        end
  
end

return