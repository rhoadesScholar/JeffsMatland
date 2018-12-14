%
% Bar plot by groups, showing means and std/err, with statistics 
%
% USAGE: output = barplotstat(datavector, groupvector, errbar, plist, pmarker, compgroup, comparisontype, ShowPoints)
%
%       datavector is vector of values
%       groupvector is vector of names assigning groups to each data value; same size as datavector
%       errbar is 'std' (default) or 'sem'
%       plist is list of p-values to test (default is : [0.05 0.01 0.001 0.0001]
%       pmarker is cell array of markers to label p-values on bars
%                                         (default: {'.','+','*','**'})
%       compgroup is name of a group for p-value comparison
%       comparisontype is 'tukey-kramer' (default), 'bonferroni', etc.
%       ShowPoints, if true, shows scatter of data points;
%           if vector, point styles are grouped by vector value

%---------------------------- 
% Dirk Albrecht 
% Version 1.0 
% 11-Feb-2011 10:41:34 
%---------------------------- 

% datavector 
% columns = strains
% rows = data from indvidual experiments
%     strain1 strain2 strain3 strain4 strainX
% exp1
% exp2
% exp3
% exp4
% expY

function output = barplotstat(datavector, groupvector, errbar, plist, pmarker, compgroup, comparisontype, ShowPoints)

if isnumeric(groupvector)
    if diff(size(groupvector))>0 groupvector = groupvector'; end
    groupvector = cellstr(num2str(groupvector));
end

if nargin < 8 || isempty(ShowPoints) ShowPoints = false; end
if nargin < 7 || isempty(comparisontype) comparisontype = 'tukey-kramer'; end
if nargin < 6 || isempty(compgroup) compgroup = unique(groupvector); end
if nargin < 5 || isempty(pmarker) pmarker = {'.','+','*','**'}; end
if nargin < 4 || isempty(plist) plist = [0.05 0.01 0.001 0.0001]; end
if nargin < 3 || isempty(errbar) errbar = 'std'; end

stat = anova1multicompare(datavector,groupvector,plist,comparisontype);

% calculate std, sem
for i = 1:length(stat.groups)
    index = find(strcmp(stat.groups(i),groupvector));
    stat.anovast.mean(i) = mean(datavector(index));
    stat.anovast.std(i) = std(datavector(index));
    stat.anovast.sem(i) = stat.anovast.std(i) / sqrt(stat.anovast.n(i));
end

if strcmp(errbar,'sem') 
    eb = stat.anovast.sem;
else
    eb = stat.anovast.std;
end


if isnumeric(compgroup) 
    compidx = compgroup; 
else
    [sortedgroups,sortidx] = sort(stat.groups);
    isortidx = []; for i=1:length(sortidx); isortidx(i)=find(sortidx==i); end
    compidx = find(strcmp(compgroup,sortedgroups));
end

h = barploterr(stat.anovast.means,eb,stat.groups);
ylim = get(gca,'YLim'); delta = 0.05*diff(ylim);

nbars = length(unique(groupvector));
ncol = max(5,nbars); sep = floor(254/(ncol-1));
cmap = jet(sep*(ncol) + 1); cmap = cmap(1:sep:size(cmap,1),:);
colormap(cmap(1:nbars,:));
barcolors = cmap;

% cmap = colormap;
% cmaps = size(cmap,1);
% barcolors = cmap(round(1:((cmaps-1)/(nbars-1)):cmaps),:)

pmarker = [{'ns'},pmarker];
ht = [];
for compn = 1:length(compidx)
    [m,n] = find(stat.stats(:,1:2) == compidx(compn));
    pdat = sortrows([diag(stat.stats(m,3-n)),m,stat.stats(m,4)]);

    if length(compidx)==1
        pmarkerpos = eb + stat.anovast.means + delta*compn;
        pmarkerpos(find(eb + stat.anovast.means < 0)) = delta*compn;
    else
        pmarkerpos = max(0,repmat(max(datavector),1,nbars)) + delta*compn;
    end

    ht = [ht; text(pdat(:,1),pmarkerpos(pdat(:,1)),char(pmarker(pdat(:,3)+1)), ...
          'HorizontalAlignment','center','Color',0.5*barcolors(compidx(compn),:))];
end

if ShowPoints == 1
    plot(grp2idx(groupvector),datavector,'ko','MarkerSize',4);
elseif length(ShowPoints)==length(datavector)
    [pa,pb,pc] = unique(ShowPoints);
    mlist = ['ko';'ks';'kd';'kx'];
    gi = grp2idx(groupvector);
    for i=1:max(pc)
        pi = find(pc == i);
        plot(gi(pi),datavector(pi),mlist(i,:),'MarkerSize',5);
    end
end

stat.pdat = pdat;
set(gca,'UserData',stat);

output = [h, ht'];



%--------------------------------------------------------------------------




function [handles, bounds] = barploterr(bardata,barerr,xvals,facecolor,linecolor)
% USAGE:    [handles, bounds] = barploterr(bardata,barerr,xvals,facecolor,linecolor);
%

if ~exist('facecolor') || isempty(facecolor) facecolor = []; end
if ~exist('linecolor') || isempty(linecolor) linecolor = [0 0 0]; end
if ~exist('xvals') || isempty(xvals) xvals = 1:length(bardata); end

hold on; 
if iscell(xvals)
    hb = bar(bardata); set(gca,'XTick',[1:length(xvals)],'XTickLabel',xvals);
    he = errorbar(1:length(bardata),bardata,barerr,'k.'); 
else
    hb = bar(xvals,bardata,'histc'); %set(gca,'XTick',[1:length(xvals)],'XTickLabel',xvals);
    %he = errorbar(xvals(1:end-1)+diff(xvals)/2,bardata(1:length(xvals)-1),barerr(1:length(xvals)-1),'k.');
    xd = diff(xvals)/2; xd = [xd, xd(end)];
    he = errorbar(xvals+xd,bardata,barerr,'k.');
    set(gca,'XLim',xvals([1 end]))
end
set(he,'Marker','none','Color',linecolor);
if ~isempty(facecolor)
    set(hb,'FaceColor',facecolor,'EdgeColor',linecolor)
else
    set(get(hb,'Children'),'CData',1:length(xvals))
end
%xlabel('Flow Velocity [mm/s]'); ylabel('Worm Speed [mm/s] (10-60sec
%avg)');

handles = [hb, he];
bounds = [get(gca,'XLim'), get(gca,'YLim')];

    