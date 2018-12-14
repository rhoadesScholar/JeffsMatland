function  [X,Y,BUTTON,SCALEMAT] = ginput2(varargin)
%GINPUT2   Graphical input from mouse with zoom, pan, plot and scaling.
%   
%   SYNTAX:
%                        XY = ginput2;
%                        XY = ginput2(DoScale);          true or false
%                        XY = ginput2(...,PlotOpt);      '.r' for example
%                        XY = ginput2(...,'KeepZoom');   vs. 'UnZoom'
%                        XY = ginput2(N,...);
%                        XY = ginput2(...);
%                     [X,Y] = ginput2(...);
%              [X,Y,BUTTON] = ginput2(...);
%     [X,Y,BUTTON,SCALEMAT] = ginput2(...);
%
%   INPUT:
%     DoScale    - Single logical specifying whether the IMAGE should be
%                  interactively scaled (georeferenced), or it can be the
%                  2x4 SCALEMAT matrix for automatically scaling.
%                  DEFAULT: false (do not scales/georeferences)
%     PlotOpt    - String and/or parameter/value pairs specifying the drawn
%                  points optional inputs (see PLOT for details). 
%                  DEFAULT: 'none' (do not plot any point)
%     'KeepZoom' - When finishing selection by default the zoom is
%                  restored. By using this option this feature is ignored.
%                  DEFAULT: 'UnZoom' (restores original axis limits)
%     N          - Number of points to be selected. One of 0,1,2,...,Inf
%                  DEFAULT: Inf (selects until ENTER or ESCAPE is pressed)
%
%   OUTPUT:
%     XY        - [X(:) Y(:)] axis coordinate(s).
%     X         - X-coordinate(s).
%     Y         - Y-coordinate(s).
%     BUTTON    - Last pressed button.
%     SCALEMAT  - 2x4 matrix specifying the coordinates of two different
%                 points (1) and (2) in the Image coordinates (pixels) and
%                 the User coordinates (data):
%                                                Point 1     Point 2
%                   Image coord (pixels):     [ (I1x,I1y)   (I2x,I2y) 
%                   User  coord (data)  :       (U1x,U1y)   (U2x,U2y) ]
%                 to be use for scaling/georeferencing.
%
%   DESCRIPTION:
%     This program uses MATLAB's GINPUT function to get the coordinates
%     of a mouse-selected point in the current figure (see GINPUT for
%     details), but with five major improvements:
%                  1. ZOOMING  (left click)
%                  2. PANNING  (dragging mouse)
%                  3. DELETING (last selected point)
%                  4. PLOTING  (temporarily the selected points)
%                  5. SCALING or GEOREFERENCE IMAGES.
%     The differences are:
%      a) Obviously, the SCALEOPT and PlotOpt optional arguments.
%      b) When click is made outside the axes, it is ignored.
%      c) When LEFT-click, ZOOM-IN is performed right into the selected
%         point (PANNING).
%      d) When RIGHT-click, the point is selected (normal).
%      e) When DOUBLE-click, ZOOM-OUT is done.
%      f) When MIDDLE-click, ZOOM-RESET is done (see ZOOM for details).
%      g) When dragging while pressed left-click PAN is done (until the
%         button is released).
%      h) When pressed any KEY follows the next rules: 
%          A) If ENTER is pressed, the selection is terminated. If no point
%             was already selected, the outputs are empty's.
%          B) If BACKSPACE key is pressed, the last selected point is
%             deleted and the selection continues.
%          C) If SPACEBAR the mouse current position or NANs coordinates
%             are saved, depending whether the mouse was inside or outside
%             any of the current figure axes, respectively. In this latter
%             case, the selection is NOT counted as one of the N points.
%             Besides, when drawing the color is changed. Then, the outputs
%             may not be of length N.
%
%   NOTE:
%     * Optional inputs use its DEFAULT value when not given or [].
%     * Optional outputs may or not be called.
%     * String inputs may be shortened, as long as they are unambiguous.
%       Case is ignored.
%     * The function can be used for interactively digitalize/vectorize
%       RASTER images with:
%       >> ginput(true)
%     * The function can be used only as a georeference function with 
%       >> ginput2(0,true)
%     * The scale/georeference only works when the current axes has an
%       IMAGE type children (see Image for details). 
%     * The x and y data from axes and image are changed when scale/
%       georeference is used.
%     * The drawn points are deleted from the graphics once the selection
%       is finished. 
%     * The priority of the inputs are: N, then SCALEOPT and finally
%       PlotOpt. If the first (integer) is missing, the next is taken into
%       account (logical or 2x4 matrix) and so on.
%
%   EXAMPLE:
%     % Selects until ENTER is pressed:
%         xy = ginput2;
%     % Selects 5 points:
%         [x,y] = ginput2(5);
%     % Gets pressed button:
%         [x,y,button] = ginput2(1);
%     % Scales image and select 4 points temporarily coloring them in
%       black. Besides to not ZOOM OUT at the end:
%         imagesc(peaks(40))
%         [x,y,button,scalemat] = ginput2(4,true,'k*','KeepZoom');
%         hold on, plot(x,y,'or'), hold off
%
%   SEE ALSO:
%     GINPUT, PLOT.
%
%
%   ---
%   MFILE:   ginput2.m
%   VERSION: 3.1 (Nov 12, 2009) (<a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/authors/11258')">download</a>) 
%   MATLAB:  7.7.0.471 (R2008b)
%   AUTHOR:  Carlos Adrian Vargas Aguilera (MEXICO)
%   CONTACT: nubeobscura@hotmail.com

%   REVISIONS:
%   1.0      Released. (Jul 09, 2008)
%   2.0      Changed default YESERROR value and fixed a bug there. Changed
%            behavior when N==1. Fixed bug with zoom out. Changed default
%            selection keys. Changed default selection click mouse: from
%            left one to the right one. (Jun 08, 2009)
%   2.1      Fixed bugs related with points deletion. Added new 'KeepZoom'
%            feature. (Aug 20, 2009)
%   3.0      Now it PANs when dragging. Updated help. (Nov 05, 2009)
%   3.1      Now returns when N==1 and pressed not predefined KEYS or one
%            of DELECTION or RETURN buttons. (Nov 12, 2009)

%   DISCLAIMER:
%   ginput2.m is provided "as is" without warranty of any kind, under the
%   revised BSD license.

%   Copyright (c) 2008-2009 Carlos Adrian Vargas Aguilera


% INPUTS CHECK-IN
% -------------------------------------------------------------------------

% PARAMETERS
% Defaults:
X        = [];
Y        = [];
BUTTON   = [];
SCALEMAT = [];
N        = Inf;
DoScale  = false;
PlotOpt  = {'none'};
UnZoom   = 'UnZoom';
% Constants KEYs (on my personal keyboard):
DOUBLECLICK    =   0;
LEFTCLICK      =   1;
MIDDLECLICK    =   2;
RIGHTCLICK     =   3;
BACKSPACE      =   8;
ESCAPE         =  27;
LEFTARROW      =  28;
RIGHTARROW     =  29;
UPARROW        =  30;
DOWNARROW      =  31;
SPACEBAR       =  32;
DELETE         = 127;
ASCII          = [ ...
                    33:64  ...  UP-KEYS
                    65:90  ...  UP-LETTERS
                    91:96  ... LOW-KEYS
                    97:122 ... LOW-LETTERS
                   123:126 ... LOW-KEY
                   161:255 ...     FOREING
                   ];
% Functionality:
% NOTE: I left all this KEYs because the user may use this special case for
% other special purposes outside this function.
% % First version default:
% % SELECTS   = [LEFTCLICK ASCII ESCAPE LEFTARROW RIGHTARROW ...
% %              UPARROW DOWNARROW SPACEBAR DELETE];
% % ZOOMIN    = RIGHTCLICK; 
SELECTS   = [RIGHTCLICK SPACEBAR]; % Selection  buttons
DELETES   = BACKSPACE;             % Deletion   buttons
FINISHES  = ESCAPE;                    % Finishes   buttons
ZOOMIN    = LEFTCLICK;             % ZOOM(2)    buttons
ZOOMRESET = MIDDLECLICK;           % ZOOM RESET buttons
ZOOMOUT   = DOUBLECLICK;           % ZOOM OUT   buttons
% Other parameters
secpause  = 0.3;    % Seconds to wait for double-click response.
YESERROR  = false;  % If there is an error with GINPUT, it tells to display 
                    % an ERROR or a WARNING message.
                    
% Checks number of inputs:
if nargout>4
 error('CVARGAS:ginput2:tooManyOutputs',...
  'At most 4 outputs are allowed.')
end

% Checks N:
if ~isempty(varargin) && ~isempty(varargin{1}) && ...
  isfloat(varargin{1}) 
 N           = round(abs(varargin{1}(1))); % Forced unique, positive 
 varargin(1) = [];                         % integer.
end

% Checks DoScale:
if ~isempty(varargin) && ~isempty(varargin{1}) && ...
   ((islogical(varargin{1})) || (ndims(varargin{1})==2 && ...
    all(size(varargin{1})==[2 4])))
 DoScale     = varargin{1};
 varargin(1) = [];
end

% Checks UnZoom:
if ~isempty(varargin) 
 if ~isempty(varargin{1}) && ischar(varargin{1})
  if     strncmpi(varargin(1),'UnZoom'  ,max(length(varargin{1}),2))
   UnZoom = 'UnZoom';
   varargin(1) = [];
  elseif strncmpi(varargin(1),'KeepZoom',max(length(varargin{1}),2))
   UnZoom = 'KeepZoom';
   varargin(1) = [];
  end
 elseif (length(varargin)>1) && ~isempty(varargin{end}) && ...
     ischar(varargin{end})
  if     strncmpi(varargin(end),'UnZoom'  ,max(length(varargin{1}),2))
   UnZoom = 'UnZoom';
   varargin(end) = [];
  elseif strncmpi(varargin(end),'KeepZoom',max(length(varargin{1}),2))
   UnZoom = 'KeepZoom';
   varargin(end) = [];
  end
 end
end

% Checks PlotOpt:
if ~isempty(varargin) && ~isempty(varargin{1})
 PlotOpt = varargin;
end
clear varargin

% Checks DoScale:
if ~islogical(DoScale)
 SCALEMAT = DoScale;
 DoScale = true;
end

% SCALES/GEOREFERENCE?:
if DoScale
 method = 'linear';
 extrap = 'extrap';
 ha     = gca;
 hi     = findobj(get(ha,'Children'),'Type','image');
 axes(ha)
 if ~isempty(hi)
  hi    = hi(1);
  xlim  = get(ha,'XLim');
  ylim  = get(ha,'YLim');
  zlim  = get(ha,'ZLim');
  z     = repmat(max(zlim),1,5);
  xdata = get(hi,'XData');
  ydata = get(hi,'YData');
  if isempty(SCALEMAT) % interactively
   I1x = round(min(xdata)); I2x = round(max(xdata));
   I1y = round(min(ydata)); I2y = round(max(ydata));
   % Default (equal):
   U1x = I1x; U2x = I2x;
   U1y = I1y; U2y = I2y;
   hgeo     = [];
   dlgTitle = 'Georeference image';
   lineNo   = 1;
  
   while true
    % Selects first corner:
    theans = ...
          questdlg('Select the first corner (1 of 2):',dlgTitle,'OK','OK');
    if ~strcmp(theans,'OK'), return, end
    pause(secpause)
    
    [I1x,I1y] = ginput2(1,false,'none','UnZoom');
    I1x       = round(I1x);
    I1y       = round(I1y);
    if ~ishandle(ha), return, end
    if (ha==gca) && ~isempty(I1x) && ~isnan(I1x)
     axis(ha,[xlim ylim])
     hgeo(1) = line([xlim NaN I1x I1x],[I1y I1y NaN ylim],z,'color','m');
     prompt  = {'X-coordinate at 1st corner:',...
                'Y-coordinate at 1st corner:'};
     def     = {int2str(I1x),int2str(I1y)};
     answer  = inputdlg(prompt,dlgTitle,lineNo,def);
     answer  = str2num(char(answer{:}));
     break
    end
   end
   axes(ha)
   
   % Checks inputs:
   if ~isempty(answer) && isfloat(answer) && (length(answer)==2) && ...
                                                      all(isfinite(answer))
    U1x = answer(1); U1y = answer(2);
    secondcorner = true;
   else
    secondcorner = false;
    warning('CVARGAS:ginput2:incorrectGeoreference',...
            'Ignored incorrect georeference corners.')
   end
  
   while secondcorner
    % Selects second corner:
    theans = ...
         questdlg('Select the second corner (2 of 2):',dlgTitle,'OK','OK');
    if ~strcmp(theans,'OK'), return, end
    pause(secpause)
   
    [I2x,I2y] = ginput2(1,false,'none','UnZoom');
    I2x       = round(I2x);
    I2y       = round(I2y);
    if ~ishandle(ha), return, end
    if (ha==gca) && ~isempty(I2x) && ~isnan(I2x) && ...
      (I2x~=I1x) && (I2y~=I1y)
     axis(ha,[xlim ylim])
     hgeo(2) = line([xlim NaN I2x I2x],[I2y I2y NaN ylim],z,'color','c');
     prompt  = {'X-coordinate at 2nd corner:',...
                'Y-coordinate at 2nd corner:'};
     def     = {int2str(I2x),int2str(I2y)};
     answer  = inputdlg(prompt,dlgTitle,lineNo,def);
     answer  = str2num(char(answer{:}));
     break
    end
   end
   axes(ha)
   
   % Checks inputs:
   if secondcorner && ~isempty(answer) && isfloat(answer) && ...
                         (length(answer)==2) && all(isfinite(answer))
    U2x = answer(1); U2y = answer(2);
   else
    warning('CVARGAS:ginput2:incorrectGeoreference',...
            'Ignored incorrect georeference corners.')
   end
  
   % Deletes corner's lines:
   if any(ishandle(hgeo))
    delete(hgeo(ishandle(hgeo)))
   end
   
   % Scale matrix:
    SCALEMAT = [I1x I1y I2x I2y; U1x U1y U2x U2y];
  else
   % Continue
  end
 else
  warning('CVARGAS:ginput2:noImageFound',...
   'No image found in the current axes to georeference.')
 end
 
 % OK, set the scaling then:
 if ~isempty(SCALEMAT)
  xdata = interp1(SCALEMAT(1,[1 3]),SCALEMAT(2,[1 3]),xdata,method,extrap);
  ydata = interp1(SCALEMAT(1,[2 4]),SCALEMAT(2,[2 4]),ydata,method,extrap);
  xlim2 = interp1(SCALEMAT(1,[1 3]),SCALEMAT(2,[1 3]),xlim ,method,extrap);
  ylim2 = interp1(SCALEMAT(1,[2 4]),SCALEMAT(2,[2 4]),ylim ,method,extrap);
  set(hi,'XData',xdata);
  set(hi,'YData',ydata);  
  set(ha,'XLim' ,sort(xlim2,'ascend'));
  set(ha,'YLim' ,sort(ylim2,'ascend'));
  % Reverses axis directions:
  if diff(xlim)*diff(xlim2)<1
   if strcmp(get(ha,'XDir'),'normal')
    set(ha,'XDir','reverse')
   else
    set(ha,'XDir','normal')
   end
  end
  if diff(ylim)*diff(ylim2)<1
   if strcmp(get(ha,'YDir'),'normal')
    set(ha,'YDir','reverse')
   else
    set(ha,'YDir','normal')
   end
  end
 end
 axis(ha,'normal')
 
end

% DRAWS?:
% if strcmpi(PlotOpt{1},'none')
%  yesdraw = false;
% else
%  yesdraw = true;
% end
yesdraw = true;
% Optional parameters:
if yesdraw
 hpoints  = [];
 % Check for linestyle color:
 yescolor     = true;
 Nplotopt     = length(PlotOpt);
 yeslinestyle = rem(Nplotopt,2);
 if yeslinestyle % Given LineStyle
  for k = 1:length(PlotOpt{1})
   switch lower(PlotOpt{1}(k))
    case 'y', yescolor = false; break
    case 'm', yescolor = false; break
    case 'c', yescolor = false; break
    case 'r', yescolor = false; break
    case 'g', yescolor = false; break
    case 'b', yescolor = false; break
    case 'w', yescolor = false; break
    case 'k', yescolor = false; break
    otherwise, % no color specified
   end
  end
 end
 if ~yescolor && (Nplotopt*yeslinestyle~=1)
  for k = yeslinestyle+1:2:Nplotopt    % Given 'Color'
   if strncmpi(PlotOpt{k},'co',2), yescolor = false; break, end
  end
 end
 if yescolor
  contnan  = 1;
  colors   = get(gca,'ColorOrder');
  ncolors  = size(colors,1);
  color    = colors(1,:);
 end
end


% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

cont       = 0;
alim.ha    = [];
alim.la    = {};
undoPtrFig = [];

while cont<N     % Principal loop
 
 % GINPUT:
 try
  [x,y,button] = ginput(1);
  if(~isempty(button))
%       if(button==1)
%         button = 3;
%       else
%           if(button==3)
%               button=8;
%           end
%       end
  end
 catch % Changed for compatibility.
  % GINPUT error:
  if YESERROR
     error('CVARGAS:ginput2:executionError',lasterr)
  else
   warning('CVARGAS:ginput2:executionError',lasterr)
   if nargout<2  % Fixed BUG 29 SEP, 2008
    X = [X Y]; 
   end
   return
  end
 end
 
 % Axes clicked:
 ha = gca;
 
 % Gets limits:
 if ~any(alim.ha==ha)
  alim.ha(end+1) = ha;
  alim.la{end+1} = axis;
 end
 
 % Sets zoom:
 zlim = getappdata(ha,'zoom_zoomOrigAxesLimits');
 if isempty(zlim) % Fixed BUG, SEP 2008
  zoom reset
  zlim = getappdata(ha,'zoom_zoomOrigAxesLimits');
 end
 
 % Checks if DOUBLE clicks:
 pause(secpause) % Gives time for response
 if strcmp(get(gcf,'selectiontype'),'open')
  button = DOUBLECLICK;
 end

 % Checks if ENTER or FINISHES button:
 if isempty(button) || ismember(button,FINISHES)
  % Finishes selection:
  if (N==1) && isempty(X) % New feature v3.1
   BUTTON = button;
  end
  break
 end
 
 % Checks if DELETION button:
 if ismember(button,DELETES)
  if ~isempty(X)
   inan = isnan(X(end));
   if yesdraw
    if ~inan
     % Deletes last drawn point:
     if ~isempty(hpoints) && ishandle(hpoints(end)) % Fixed bug Aug 2009
      delete(hpoints(end)), hpoints(end) = [];
     end
    elseif yescolor
     % Change color as necessary:
     contnan = contnan-1;
     color   = colors(mod(contnan-1,ncolors)+1,:);
    end
   end
   % Deletes the last selected point:
   X(end)      = [];
   Y(end)      = [];
   BUTTON(end) = [];
   % Checks if the last point was NaN:
   if ~inan
    cont = cont-1;
   end
  elseif N==1
   % Finishes selection: New feature v3.1
   BUTTON = button;
   break
  end
  continue
 end
 
 % Checks if ZOOM OUT button:
 if ismember(button,ZOOMOUT)
  undoPtrFig = gcf;
  setptr(undoPtrFig,'glassminus')
  zoom out
  continue
 end
 
 % Checks if ZOOM RESET button:
 if ismember(button,ZOOMRESET)
  zoom reset
  continue
 end
 
 % Checks if the mouse was inside an axes of the current figure;
 lim     = axis;
 outside = x<lim(1) || x>lim(2) || y<lim(3) || y>lim(4);
 
 % Checks if ZOOM IN with PAN:
 if ismember(button,ZOOMIN) && ~outside
  % Dragging rectangle:
  undoPtrFig = gcf;
  setptr(undoPtrFig,'closedhand')
  rbbox
  ydrag = get(gca,'CurrentPoint');
  xdrag = ydrag(1,1)-x;
  ydrag = ydrag(1,2)-y;
  % Do the PANNING:
  if  any(abs([xdrag ydrag])>eps*1000000)
   % Only PAN (dragging):
   lim(1:4) = lim(1:4) - [xdrag xdrag ydrag ydrag]; 
   axis(lim)
  else
   % PAN (centers the last point) and ZOOM in:
   setptr(undoPtrFig,'glassplus')
   lim = [x+diff(lim(1:2))/2*[-1 1] y+diff(lim(3:4))/2*[-1 1]]; 
   axis(lim)
   zoom(2)
  end
  continue
 end
 
 % Checks if SELECTS button:
 if ismember(button,SELECTS)
  
  % Sets NaNs if outside the axes:
  if outside 
   if ~isnumeric(N) 
    % Change color:
    if yesdraw && yescolor 
     contnan = contnan+1;
     color   = colors(mod(contnan-1,ncolors)+1,:);
    end
    % Adds NaNs but the point counters do not take it into account:
    X      = [X;      NaN];
    Y      = [Y;      NaN];
    BUTTON = [BUTTON; button];
   else
    % Ignores the point
   end
  else
   % Draws the result:
   if yesdraw
    % Search for last point:
    x0 = []; y0 = []; z0 = [];
    inan = isnan([NaN; X; NaN]);
    if ~inan(end-1)
     inan        = find(inan);
     nlastpoints = inan(end)-inan(end-1)-1;
     npoints     = length(hpoints);
     range       = npoints-nlastpoints+1:npoints;
     range = range(end);
     hlastaxes   = get(hpoints(range),'Parent');
     if iscell(hlastaxes), hlastaxes  = cell2mat(hlastaxes); end
     [loc,loc] = ismember(ha,hlastaxes);
     if loc
      x0 = get(hpoints(range(loc)),'XData');
      y0 = get(hpoints(range(loc)),'YData');
      z0 = get(hpoints(range(loc)),'ZData');
     end
    end
%     holdon = ishold;
%     if ~holdon, hold on, end 
     hold on
     h = plot([x0 x],[y0 y], 'Marker', '*');
     % Elevates the value:
     z = get(ha,'ZLim'); z = z(2);
     set(h,'Zdata',[z0 z])
     % Sets the color:
     if yescolor
      set(h,'Color',color)
     end
     hpoints = [hpoints; h];
%     if ~holdon, hold off, end 
    % Restores limits:
    axis(lim)
   end
   
   % Centers the selected point if ZOOM-IN: 29 SEP,2008
   if all((lim~=zlim(1:4)))
    lim = [x+diff(lim(1:2))/2*[-1 1] y+diff(lim(3:4))/2*[-1 1]];
    axis(lim)
   end
   
   % Saves the result:
   X      = [X;      x];
   Y      = [Y;      y];
   BUTTON = [BUTTON; button];
   cont   = cont+1;
  end
  continue
 end

 % Checks if any other button pressed inside the axes:
 if ~outside
  X      = [X;      x];
  Y      = [Y;      y];
  BUTTON = [BUTTON; button];
  cont   = cont+1;
 else
  if N==1 % New feature v3.1
   BUTTON = button;
   break
  end
  % ignores the selection
 end
 
end

% Returns pointer.
if ~isempty(undoPtrFig) && ishandle(undoPtrFig)
 setptr(undoPtrFig,'arrow')
end

% Deletes drawn points if still exist:
if yesdraw && any(ishandle(hpoints))
 delete(hpoints(ishandle(hpoints)))
end

% Returns original limits.
if ~strcmp(UnZoom,'KeepZoom') && ~isempty(alim.ha)
 alim.ha(~ishandle(alim.ha)) = [];
 for k = 1:length(alim.ha)
  temp = axis(alim.ha(k));
  if ~all(temp(1:4)==alim.la{k}(1:4))
   axis(alim.ha(k),alim.la{k})
  end
 end
end


% OUTPUTS CHECK-OUT
% -------------------------------------------------------------------------

if nargout<2
 X = [X Y]; 
end


function [out1,out2,out3] = ginput(arg1)
%GINPUT Graphical input from mouse.
%   [X,Y] = GINPUT(N) gets N points from the current axes and returns
%   the X- and Y-coordinates in length N vectors X and Y.  The cursor
%   can be positioned using a mouse.  Data points are entered by pressing
%   a mouse button or any key on the keyboard except carriage return,
%   which terminates the input before N points are entered.
%
%   [X,Y] = GINPUT gathers an unlimited number of points until the
%   return key is pressed.
%
%   [X,Y,BUTTON] = GINPUT(N) returns a third result, BUTTON, that
%   contains a vector of integers specifying which mouse button was
%   used (1,2,3 from left) or ASCII numbers if a key on the keyboard
%   was used.
%
%   Examples:
%       [x,y] = ginput;
%
%       [x,y] = ginput(5);
%
%       [x, y, button] = ginput(1);
%
%   See also GTEXT, WAITFORBUTTONPRESS.

%   Copyright 1984-2015 The MathWorks, Inc.

out1 = []; out2 = []; out3 = []; y = [];

if ~matlab.ui.internal.isFigureShowEnabled
    error(message('MATLAB:hg:NoDisplayNoFigureSupport', 'ginput'))
end
    
    % Check Inputs
    if nargin == 0
        how_many = -1;
        b = [];
    else
        how_many = arg1;
        b = [];
        if  ~isPositiveScalarIntegerNumber(how_many) 
            error(message('MATLAB:ginput:NeedPositiveInt'))
        end
        if how_many == 0
            % If input argument is equal to zero points,
            % give a warning and return empty for the outputs.            
            warning (message('MATLAB:ginput:InputArgumentZero'));
        end
    end
    
    % Get figure
    fig = gcf;
    figure(gcf);
    
    % Make sure the figure has an axes
    gca(fig);
    
    % Setup the figure to disable interactive modes and activate pointers. 
    initialState = setupFcn(fig);
    
    % onCleanup object to restore everything to original state in event of
    % completion, closing of figure errors or ctrl+c. 
    c = onCleanup(@() restoreFcn(initialState));
    
    drawnow
    char = 0;
    
    while how_many ~= 0
        waserr = 0;
        try
            keydown = wfbp;
        catch %#ok<CTCH>
            waserr = 1;
        end
        if(waserr == 1)
            if(ishghandle(fig))
                cleanup(c);
                error(message('MATLAB:ginput:Interrupted'));
            else
                cleanup(c);
                error(message('MATLAB:ginput:FigureDeletionPause'));
            end
        end
        % g467403 - ginput failed to discern clicks/keypresses on the figure it was
        % registered to operate on and any other open figures whose handle
        % visibility were set to off
        figchildren = allchild(0);
        if ~isempty(figchildren)
            ptr_fig = figchildren(1);
        else
            error(message('MATLAB:ginput:FigureUnavailable'));
        end
        %         old code -> ptr_fig = get(0,'CurrentFigure'); Fails when the
        %         clicked figure has handlevisibility set to callback
        if(ptr_fig == fig)
            if keydown
                char = get(fig, 'CurrentCharacter');
                button = abs(get(fig, 'CurrentCharacter'));
            else
                button = get(fig, 'SelectionType');
                if strcmp(button,'open')
                    button = 1;
                elseif strcmp(button,'normal')
                    button = 1;
                elseif strcmp(button,'extend')
                    button = 2;
                elseif strcmp(button,'alt')
                    button = 3;
                else
                    error(message('MATLAB:ginput:InvalidSelection'))
                end
            end
            axes_handle = gca;
            drawnow;
            pt = get(axes_handle, 'CurrentPoint');
            
            how_many = how_many - 1;
            
            if(char == 13) % & how_many ~= 0)
                % if the return key was pressed, char will == 13,
                % and that's our signal to break out of here whether
                % or not we have collected all the requested data
                % points.
                % If this was an early breakout, don't include
                % the <Return> key info in the return arrays.
                % We will no longer count it if it's the last input.
                break;
            end
            
            out1 = [out1;pt(1,1)]; %#ok<AGROW>
            y = [y;pt(1,2)]; %#ok<AGROW>
            b = [b;button]; %#ok<AGROW>
        end
    end
    
    % Cleanup and Restore 
    cleanup(c);
    
    if nargout > 1
        out2 = y;
        if nargout > 2
            out3 = b;
        end
    else
        out1 = [out1 y];
    end
    
end

function valid = isPositiveScalarIntegerNumber(how_many) 
valid = ~ischar(how_many) && ...            % is numeric
        isscalar(how_many) && ...           % is scalar
        (fix(how_many) == how_many) && ...  % is integer in value
        how_many >= 0;                      % is positive
end

function key = wfbp
%WFBP   Replacement for WAITFORBUTTONPRESS that has no side effects.

fig = gcf;
current_char = []; %#ok<NASGU>

% Now wait for that buttonpress, and check for error conditions
waserr = 0;
try
    h=findall(fig,'Type','uimenu','Accelerator','C');   % Disabling ^C for edit menu so the only ^C is for
    set(h,'Accelerator','');                            % interrupting the function.
    keydown = waitforbuttonpress;
    current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
    if~isempty(current_char) && (keydown == 1)          % If the character was generated by the
        if(current_char == 3)                           % current keypress AND is ^C, set 'waserr'to 1
            waserr = 1;                                 % so that it errors out.
        end
    end
    
    set(h,'Accelerator','C');                           % Set back the accelerator for edit menu.
catch %#ok<CTCH>
    waserr = 1;
end
drawnow;
if(waserr == 1)
    set(h,'Accelerator','C');                          % Set back the accelerator if it errored out.
    error(message('MATLAB:ginput:Interrupted'));
end

if nargout>0, key = keydown; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

function initialState = setupFcn(fig)

% Store Figure Handle. 
initialState.figureHandle = fig; 

% Suspend figure functions
initialState.uisuspendState = uisuspend(fig);

% Disable Plottools Buttons
initialState.toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
if ~isempty(initialState.toolbar)
    initialState.ptButtons = [uigettool(initialState.toolbar,'Plottools.PlottoolsOff'), ...
        uigettool(initialState.toolbar,'Plottools.PlottoolsOn')];
    initialState.ptState = get (initialState.ptButtons,'Enable');
    set (initialState.ptButtons,'Enable','off');
end

%Setup empty pointer
cdata = NaN(16,16);
hotspot = [8,8];
set(gcf,'Pointer','custom','PointerShapeCData',cdata,'PointerShapeHotSpot',hotspot)

% Create uicontrols to simulate fullcrosshair pointer.
initialState.CrossHair = createCrossHair(fig);

% Adding this to enable automatic updating of currentpoint on the figure 
% This function is also used to update the display of the fullcrosshair
% pointer and make them track the currentpoint.
set(fig,'WindowButtonMotionFcn',@(o,e) updateCrossHair(o,initialState.CrossHair));

% Get the initial Figure Units
initialState.fig_units = get(fig,'Units');
end

function restoreFcn(initialState)
if ishghandle(initialState.figureHandle)
    delete(initialState.CrossHair);
    
    % Figure Units
    set(initialState.figureHandle,'Units',initialState.fig_units);
    set(initialState.figureHandle,'WindowButtonMotionFcn','');
    
    % Plottools Icons
    if ~isempty(initialState.toolbar) && ~isempty(initialState.ptButtons)
        set (initialState.ptButtons(1),'Enable',initialState.ptState{1});
        set (initialState.ptButtons(2),'Enable',initialState.ptState{2});
    end
    
    % UISUSPEND
    uirestore(initialState.uisuspendState);    
end
end

function updateCrossHair(fig, crossHair)
% update cross hair for figure.
gap = 3; % 3 pixel view port between the crosshairs
csize = 10;
cp = hgconvertunits(fig, [get(fig,'CurrentPoint') 0 0], get(fig,'Units'), 'pixels', fig);
cp = cp(1:2);
figPos = hgconvertunits(fig, get(fig,'Position'), get(fig,'Units'), 'pixels', get(fig,'Parent'));
figWidth = figPos(3);
figHeight = figPos(4);

% Early return if point is outside the figure
if cp(1) < gap || cp(2) < gap || cp(1)>figWidth-gap || cp(2)>figHeight-gap
    return
end

set(crossHair, 'Visible', 'on');
thickness = 1; % 1 Pixel thin lines. 
set(crossHair(1), 'Position', [cp(1)-(gap+csize) cp(2) csize thickness]);
set(crossHair(2), 'Position', [cp(1)+gap cp(2) csize thickness]);
set(crossHair(3), 'Position', [cp(1) cp(2)-(gap+csize) thickness csize]);
set(crossHair(4), 'Position', [cp(1) cp(2)+gap thickness csize]);
end

function crossHair = createCrossHair(fig)
% Create thin uicontrols with black backgrounds to simulate fullcrosshair pointer.
% 1: horizontal left, 2: horizontal right, 3: vertical bottom, 4: vertical top
for k = 1:4
    crossHair(k) = uicontrol(fig, 'Style', 'text', 'Visible', 'off', 'Units', 'pixels', 'BackgroundColor', [0 0 0], 'HandleVisibility', 'off', 'HitTest', 'off'); %#ok<AGROW>
end
end

function cleanup(c)
if isvalid(c)
    delete(c);
end
end
end
