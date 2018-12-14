function [p,Z,matValues] = get_HIS_pvalue(matHIS,matREF,boolDrawFigure)
% [p,Z] = get_HIS_pvalue(matHIS,matREF)
%
% Calculates a p-value for guessing the amount of interactions from
% "matHIS" that are also positive in "matREF".
%
% Note, only positive interactions in matHIS are considered.
%
% The p-value is calculated for the undirected case, so the maximum score
% of each direction of a possible interactions is taken as the undirected
% interaction score.
%
% Self links are ignored both from the hypothesis set and from the
% reference set.
%
% Optional values:
%
% [p,Z] = get_HIS_pvalue(matHIS, matREF, boolDrawFigure, intTopX)
%
% where boolDrawFigure is a boolean for drawing a figure, and
% intTopX limits the analysis to the top-x results.

if nargin<3
    boolDrawFigure = true;
end

if nargin<4
    intTopX = false;
end

if ~isequal(size(matHIS),size(matREF))
    error('input matrices should have equal size')
end

% Make the calculations for the undirected case as well as exclude self-links
intNodes = size(matREF,1);
intNumOfPossibleUndirectedNonSelfEdges = (intNodes*(intNodes-1))/2;

% actually we can linearize the interaction matrices (undirected, excluding
% self links), and do the counting of verified edges at each threshold
% using matrix multiplication with binary matrices
matLinearizingIX = triu(true(size(matHIS)));
matLinearizingIX(logical(eye(intNodes))) = false;

% make undirected by taking the maximal score for each direction
matREF = max(matREF, matREF');
matHIS = max(matHIS, matHIS');

% only keep one of both directions for each edge, and exclude self-links
matREF = matREF(matLinearizingIX);
matHIS = matHIS(matLinearizingIX);
clear matLinearizingIX;

if numel(matREF) ~= intNumOfPossibleUndirectedNonSelfEdges
    error('really... should. not. happen.')
end

M = intNumOfPossibleUndirectedNonSelfEdges; % total number of potential edges
K = sum(matREF(:)); % total number of positive edges

% remove non-predicted interactions
matNotPredictedIX = matHIS<=0 | isnan(matHIS);
matREF(matNotPredictedIX) = [];
matHIS(matNotPredictedIX) = [];
clear matNotPredictedIX

N = (1:numel(matHIS))'; % go from the total number of edges to the last, most strongest predicted interaction

% first sort ref & prediction such that validated interactions come last
[matREF,matSortIX] = sort(matREF,'descend');
matHIS = matHIS(matSortIX);

% sort reference according from highest to lowest predicted interaction.
[matHIS,matSortIX] = sort(matHIS,'descend');
% clear matHIS
matREF = matREF(matSortIX);

matCumulativeREF = cumsum(matREF); % nr. of positive edges at each threshold

% treat edge-scores with equal value as equals (i.e. block-process them, as
% their ordering is arbitrary which can lead to artifacts in the analysis).
[matUniqueHIS,N,N2]=unique(matHIS,'last');
X = matCumulativeREF(N);

% fraction of positive edges at each threshold
Z = X ./ N;

% corresponding probability of getting x or more true hits would be calculated like this:
% p = hygecdf(N-X,M,M-K,N);
% However, the above is very slow and can be (for enrichment cases) accurately
% approximated by the much much faster:
p = hygepdf(X,M,K,N);

% set p-values of depletion to p=1, as we only want to score enrichment...
p((X./N) <= (K/M)) = 1;

% set p==0 to minimal non-zero p-value to avoid Infs in log10(p)
p(p==0) = 1E-320;

% transform back to full data
p = p(N2);
Z = Z(N2);
if nargout==3
    matValues = matUniqueHIS(N2);
end

if boolDrawFigure
    figure;
    subplot(2,2,1)
    AX=plotyy(1:numel(p),-log10(p),1:numel(Z),Z);
    set(AX,'XDir','reverse')

    subplot(2,2,2)
    AX=plotyy(1:1000,-log10(p(1:1000)),1:1000,Z(1:1000));
    set(AX,'XDir','reverse')

    subplot(2,2,3)
    hold on
    matBarEdges = linspace(0,matHIS(1),30);
    matCount = histc(full(matHIS),matBarEdges);
    hB=bar(matBarEdges,matCount / max(matCount),'histc');%,'parent',AX(1)
    set(hB,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.5 0.5 0.5])
    AX=plotyy(matUniqueHIS(N2),Z,matUniqueHIS(N2),-log10(p));
    set(AX,'XLim',[0 matUniqueHIS(end)])
    hold off
    drawnow
end

% Published with MATLAB® 7.14
