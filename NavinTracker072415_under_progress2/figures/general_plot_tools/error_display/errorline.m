function h = errorline(varargin)
% h = errorline(varargin)

% variation of v6 MATLAB errorbar function w/ errorbar tee length set to zero
% Navin Pokala
%ERRORBAR Error bar plot. % edit by navin to set the error bar t to zero
%   ERRORBAR(X,Y,L,U) plots the graph of vector X vs. vector Y with
%   error bars specified by the vectors L and U.  L and U contain the
%   lower and upper error ranges for each point in Y.  Each error bar
%   is L(i) + U(i) long and is drawn a distance of U(i) above and L(i)
%   below the points in (X,Y).  The vectors X,Y,L and U must all be
%   the same length.  If X,Y,L and U are matrices then each column
%   produces a separate line.
%
%   ERRORBAR(X,Y,E) or ERRORBAR(Y,E) plots Y with error bars [Y-E Y+E].
%   ERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   ERRORBAR(AX,...) plots into AX instead of GCA.
%
%   H = ERRORBAR(...) returns a vector of errorbarseries handles in H.
%
%   Backwards compatibility
%   ERRORBAR('v6',...) creates line objects instead of errorbarseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.19.4.9 $  $Date: 2005/04/28 19:56:17 $


% Parse possible Axes input
%error(nargchk(2,6,nargin,'struct'));
[cax,args,nargs] = axescheck(varargin{:});

x = args{1};
y = args{2};
l = args{3}; 
u = l;
npt = size(x,1);

if nargs > 3
    symbol = args{4}; 
else
    symbol = '-';
end

u = abs(u);
l = abs(l);
    
if ischar(x) || ischar(y) || ischar(u) || ischar(l)
    error(id('NumericInputs'),'Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) || ~isequal(size(x),size(l)) || ~isequal(size(x),size(u)),
  error(id('InputSizeMismatch'),'The sizes of X, Y, L and U must be the same.');
end

tee = 0; % (max(x(:))-min(x(:)))/100;  % make tee .02 x-distance for error bars
xl = x - tee;
xr = x + tee;
ytop = y + u;
ybot = y - l;
n = size(y,2);

% Plot graph and bars
cax = newplot(cax);
hold_state = ishold(cax);

% build up nan-separated vector for bars
xb = zeros(npt*9,n);
xb(1:9:end,:) = x;
xb(2:9:end,:) = x;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xl;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = ytop;
yb(5:9:end,:) = ytop;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ybot;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;

[ls,col,mark,msg] = colstyle(symbol); 
if ~isempty(msg), error(msg); end %#ok
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

if(nargin>=5)
    h = plot(xb,yb,esymbol,'parent',cax,varargin{5:end}); hold(cax,'on')
    h = [h;plot(x,y,symbol,'parent',cax,varargin{5:end})]; 
else
    h = plot(xb,yb,esymbol,'parent',cax,'LineWidth',1.5); hold(cax,'on')
    h = [h;plot(x,y,symbol,'parent',cax,'LineWidth',1.5)]; 
end

if ~hold_state, hold(cax,'off'); end

return;
end



