function varargout = measuretool(varargin)
% This tool (measure tool) is intended to aid measuring on images.
% In order to do this the image needs to have some visual scale to
% calibrate the pixel to length ratio on, e.g. scale bar, ruler.
%
% This is a two file GUI (Graphical User Interface)
%     measuretool.m   - the code, run this file to start the GUI
%     measuretool.fig - the figure, keep this file toghether with
%                       measuretool.m
%
% Quick Help:
% =============================%
% - Select a folder containing images using <Browse>
% - Press <Load>, and select one image from the list'
% - Press <Calibrate> and select two points of which the distance is known'
% - Use the zoom function of the toolbar and correct your initial selection'
% - Double Click the line to confirm'
% - Enter the length of the selected distance in the calibration panel'
% - Calibration is ready:'
% - Use the <Distance>, <Caliper>, <Circle> or <Angle> tools to measure'
% - Each measurement can be deleted using <Delete> or modified using <Edit>'
%
%
% For a more elaborate help, hit the <Help> button in the GUI

% Initializing the GUI:
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @measuretool_OpeningFcn, ...
    'gui_OutputFcn',  @measuretool_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes just before measuretool is made visible.
function measuretool_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

if isfield(handles,'Data')
    Data = handles.Data;
end

% setting default plot options
options.marker1 = 'o';
options.marker2 = '.';
options.markersize = '10';
options.linestyle1 = '-';
options.linestyle2 = '--';
options.linewidth = '1' ;
options.color1 = 'r';
options.color2 = 'k';
options.textcolorfg = 'k';
options.textcolorbg = 'none';
options.fontsize = '14';
options.zoomfactor = 2;
options.splinemethod = 'spline';

% storing the ascii degree symbol
Data.degree = char(186);% i.e. ??

% put the tool on the right side of the screen
movegui('southeast')

% detect old matlab version
if verLessThan('matlab', '7.9.0')
    set(handles.Quickmeasure,'Value',1,'foregroundcolor',[0.5 0.5 0.5]);
end

% detect image processing toolbox
if ~exist('imline','file')
    set(handles.Quickmeasure,'Value',1,'foregroundcolor',[0.5 0.5 0.5]);
end

% storing in the Data structure
Data.options = options;
handles.Data = Data;
% Update handles structure
guidata(hObject, handles);

% optional, use the tool on a figure already open
if ~isempty(varargin)
    argin = varargin{1};
else
    argin = [];
end
if ishandle(argin)
    Data.gcf = argin;
    handles.Data = Data;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % configure the gui for use without file selection
    currentfigure_fun(hObject, eventdata, handles)
end

function varargout = measuretool_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function currentfigure_fun(hObject, eventdata, handles)
% read the Data structure
Data = handles.Data;

tmpname = 'measuretool_gcf.fig';
tmpfile = fullfile(tempdir,tmpname);

saveas(Data.gcf,tmpfile,'fig');

% Fill the Data structure
Data.unit      = 'pixels';
Data.cfile     = tmpname;
Data.ctype     = '*.fig';
Data.cfilenum  = 1;
Data.files     = {tmpname};
Data.ftypes    = {'*.fig'};
Data.path      = tempdir ;
Data.Im(1,1,3) = 0;

% Disable the file selection options
set(handles.FileBrowse,'Enable','off')
set(handles.FileBox,'Enable','off')
set(handles.FileBox,'String',{'Current Figure'})

% Disable the calibration options
set(handles.Calibrate,'Enable','off')
set(handles.CalibLength,'Enable','off')
% set(handles.CalibUnit,'Enable','off')

handles.Data = Data;
% Update handles structure
guidata(hObject, handles);

plotfun(hObject, eventdata, handles)

function FileBrowse_Callback(hObject, eventdata, handles)
% load the Data structure
Data = handles.Data;

% start browsing from the current folder
if isfield(Data,'path')
    oldpath = Data.path;
else
    oldpath = pwd;
end

% possible image types to list
imagetypes = {'*.png';'*.jpg';'*.jpeg';'*.gif';'*.tif';'*.tiff'};
imagetypes = [imagetypes ; upper(imagetypes)];

% popup, ask for a fiel
[filename, filepath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.png;*.tif;*.tiff;*.PNG;*.JPG;*.TIF','All Image Files';'*.*','All Files' },'Select an Image',oldpath);

% if cancel
if filename == 0
    set(handles.Status,'string','Browse: no file selected')
    return
end

% get a list of fiels
files = {}; filetypes = {};
% for each file type
for i = 1:length(imagetypes)
    % read the files from the dir for this type
    filestmp = dir([filepath filesep '*' imagetypes{i}]);
    filestmp = {filestmp(:).name};
    filetypestmp = repmat(imagetypes(i),1,length(filestmp));
    
    % store them with the other types
    files = {files{:} filestmp{:}}.';
    filetypes = {filetypes{:} filetypestmp{:}}.';
end

% get the current file from the list
n = length(files);
for k = 1:n
    if strcmp(files{k},filename);
        cfile = files{k};
        ctype = filetypes{k};
        cfilenum = k;
    end
end

% select the current file from in the list
set(handles.FileBox,'String',files);
set(handles.FileBox,'Value',cfilenum);

% update status
set(handles.Status,'string','Browse: file loaded')

% storing in the Data structure
Data.cfile    = cfile ;
Data.ctype    = ctype ;
Data.cfilenum = cfilenum ;
Data.files  = files ;
Data.ftypes = filetypes ;
Data.path   = filepath ;

% Update handles structure
handles.Data = Data;
guidata(hObject, handles);

% plot the figure
plotfun(hObject, eventdata, handles)

function [u v] = zoomselect(h,zoomfactor)
% store current axes
xlim = get(h,'xlim');
ylim = get(h,'ylim');

% get the position of the zoomed box
[u v] = ginput(1);

% calculate size of the zoombox
fovx = diff(xlim)./zoomfactor;
fovy = diff(ylim)./zoomfactor;

% position zoombox centered around selected position
xzoom = [u-fovx/2 , u+fovx/2] ;
yzoom = [v-fovy/2 , v+fovy/2] ;

% shift the zoom xlimit to be within the initial view
if xzoom(1) < xlim(1)
    % zoom select is on the left edge of the axes
    xzoom(1) = xlim(1);
    xzoom(2) = xlim(1) + fovx;
elseif xzoom(2) > xlim(2)
    % zoom select is on the right edge of the axes
    xzoom(2) = xlim(2);
    xzoom(1) = xlim(2) - fovx;
end

% shift the zoom ylimit to be within the initial view
if yzoom(1) < ylim(1)
    % zoom select is on the bottom edge of the axes
    yzoom(1) = ylim(1);
    yzoom(2) = ylim(1) + fovy;
elseif yzoom(2) > ylim(2)
    % zoom select is on the top edge of the axes
    yzoom(2) = ylim(2);
    yzoom(1) = ylim(2) - fovy;
end


% zoom
set(h,'xlim',xzoom,'ylim',yzoom)

% select a point
[u v] = ginput(1);

% restore old axes
set(h,'xlim',xlim,'ylim',ylim)





function plotfun(hObject, eventdata, handles)
% read the Data structure
Data = handles.Data;
O = Data.options;

if ~isfield(Data,'cfile')
    return
end

% Evaluate options
% ==============================
marker = {O.marker1 ; O.marker2};
markersize = eval(O.markersize);
if length(O.color1) == 1 || strcmpi(O.color1,'none')
    color{1,1} = O.color1;
else
    color{1,1} = eval(O.color1);
end
if length(O.color2) == 1 || strcmpi(O.color2,'none')
    color{2,1} = O.color2;
else
    color{2,1} = eval(O.color2);
end
linestyle = {O.linestyle1 ; O.linestyle2};
linewidth = eval(O.linewidth);
if length(O.textcolorfg) == 1 || strcmpi(O.textcolorfg,'none')
    textcolorfg = O.textcolorfg;
else
    textcolorfg = eval(O.textcolorfg);
end
if length(O.textcolorbg) == 1  || strcmpi(O.textcolorbg,'none')
    textcolorbg = O.textcolorbg;
else
    textcolorbg = eval(O.textcolorbg);
end
fontsize = eval(O.fontsize);

% Plot the image
% ==============================
% some shorthands
filename = Data.cfile;
filetype = Data.ctype;
filepath = Data.path;
fileext  = regexprep(filetype,{'\*','\.'},'');

% start a new window
if ~isfield(Data,'gcf')
    Data.gcf = figure(1234);
    clf(Data.gcf);
    
    % get the screensize
    fullscreen = get(0,'ScreenSize');
    P = fullscreen .* [50 50 0.8 0.8];
    % fix the new figure
    set(Data.gcf,'Name','measure window','HandleVisibility','callback','NumberTitle','off')
    set(Data.gcf,'Position',P)
else
    figure(Data.gcf);
    clf(Data.gcf);
end

% Read the image
if strcmp(fileext,'fig')
    position = get(Data.gcf,'Position');
    close(Data.gcf);
    Data.gcf = openfig(fullfile(filepath,filename));
    Data.gca = get(Data.gcf,'Children');
    set(Data.gcf,'Position',position);
    set(Data.gcf,'Name','measure window','HandleVisibility','callback','NumberTitle','off')
    Im = Data.Im;
else
    Im = imread(fullfile(filepath,filename),fileext);
    Data.Im = Im;
end

% set the default unit
if ~isfield(Data,'unit')
    Data.unit = 'pixels';
end

% check the size (ndims = 3 for RGB images)
if ndims(Im) == 3
    [n m k] = size(Im);
else
    [n m] = size(Im);
    % fix for showing grayscale images as colored
    colormap(gray);
end
% create default x and y vectors
x = 1:m;
y = 1:n;

% if calibrated update x and y vectors
if ~strcmpi('...',get(handles.CalibRatio,'String'))
    if isfield(Data,'Lppx')
        % length per pixel
        Lppx = Data.Lppx;
        % update x and y vectors
        x = x*Lppx;
        y = y*Lppx;
    end
else
    Lppx = 1;
end

% store x and y vectors
Data.x = x;
Data.y = y;

% plot the image
if ~strcmp(fileext,'fig')
    Data.imagehandle = imagesc(x,y,Im);drawnow
    % get the axes handles of the image
    Data.gca = get(Data.imagehandle,'Parent');
else
    Data.gca = get(Data.gcf,'Children');
end
% tune the axes settings
set(Data.gca,'Box','On','NextPlot','add','DataAspectRatio',[1 1 1]);


% add labels
if strcmp(Data.unit,'um')
    Data.xlabh = xlabel(Data.gca,'\mum');
    Data.ylabh = ylabel(Data.gca,'\mum');
else
    Data.xlabh = xlabel(Data.gca,Data.unit);
    Data.ylabh = ylabel(Data.gca,Data.unit);
end

% set fontsize
set(Data.gca,'FontSize',fontsize);
set(Data.xlabh,'FontSize',fontsize);
set(Data.ylabh,'FontSize',fontsize);


% Plot the calibration scale bar
% ==============================
if isfield(Data,'Calib')
    X = Data.Calib.X*Lppx;
    Y = Data.Calib.Y*Lppx;
    h = plot(Data.gca,X,Y,'-xw',X,Y,':+k');drawnow
    set(h,{'Marker'},marker)
    set(h,'MarkerSize',markersize)
    set(h,{'MarkerEdgeColor'},color)
    set(h,{'LineStyle'},linestyle)
    set(h,{'Color'},color)
    set(h,'LineWidth',linewidth)
end

% store and update the handles structure
handles.Data = Data;
guidata(hObject, handles);

% Plot the measurements
% ==================================
if ~isfield(Data,'Mdata')
    return
end
Mdata = Data.Mdata ;

% put the tool again back on top
figure(Data.gcf)

% forloop over each measurement
n = length(Mdata);
for k = 1:n
    
    % read the Mdata structure
    type  = Mdata(k).type;
    value = Mdata(k).value;
    unit  = Mdata(k).unit;
    X     = Mdata(k).X;
    Y     = Mdata(k).Y;
    circ  = Mdata(k).circ;
    spl   = Mdata(k).spline;
    
    % set the fancy units
    if strcmp(unit,'um')
        unit =  '\mum';
    elseif strcmp(unit,Data.degree)
        unit = '\circ';
    end

    % use intensity instead of value
    if get(handles.Intensity,'Value')
        value = Mdata(k).intensity;
        unit  = '';
    end
    
    % convert the value to string
    value = sprintf('%.2f',value);
    
    % skip measurements from other images
    if ~get(handles.ShowAll,'Value')
        if Data.Mdata(k).filenum ~= Data.cfilenum
            continue
        end
    end
    
    % plot the measurement, and set the plot options
    switch type
        case 'Distance'
            ht = text(X(2),Y(2),[' ' value ' ' unit]);
            h1 = plot(X,Y,'-xw',X,Y,':+k');
            h  = h1;
        case 'Caliper'
            ht = text(X(3),Y(3),[' ' value ' ' unit]);
            h1 = plot(X(1:2),Y(1:2),'-xw',X(1:2),Y(1:2),':+k');
            h2 = plot(X(3:4),Y(3:4),'-xw',X(3:4),Y(3:4),':+k');
            h  = [h1 ; h2];
            
            set(h2,{'Marker'},marker)
            set(h2,'MarkerSize',markersize)
            set(h2,{'MarkerEdgeColor'},color)
            set(h2,{'LineStyle'},linestyle)
            set(h2,{'Color'},color)
            set(h2,'LineWidth',linewidth)
        case 'Circle (R)'
            ht = text(circ.xc,circ.yc,[' ' value ' ' unit]);
            h1 = plot(circ.xc,circ.yc,'xw',circ.xc,circ.yc,'+k');
            h2 = plot(X,Y,'-w',X,Y,':k');
            h  = [h1 ; h2];
            
            set(h2,'Marker','none')
            set(h2,{'LineStyle'},linestyle)
            set(h2,{'Color'},color)
            set(h2,'LineWidth',linewidth)
        case 'Angle'
            ht = text(X(3),Y(3),[' ' value unit]);
            h1 = plot(X,Y,'-xw',X,Y,':+k');
            h  = h1;
        case 'Spline'
            ht = text(spl.x(end),spl.y(end),[' ' value ' ' unit]);
            h1 = plot(spl.x,spl.y,'xw',spl.x,spl.y,'+k');
            h2 = plot(X,Y,'-w',X,Y,':k');
            h  = [h1 ; h2];
            
            set(h2,'Marker','none')
            set(h2,{'LineStyle'},linestyle)
            set(h2,{'Color'},color)
            set(h2,'LineWidth',linewidth)
    end
    
    set(h1,{'Marker'},marker)
    set(h1,'MarkerSize',markersize)
    set(h1,{'MarkerEdgeColor'},color)
    set(h1,{'LineStyle'},linestyle)
    set(h1,{'Color'},color)
    set(h1,'LineWidth',linewidth)
    
    if strcmp(type,'Spline')
        set(h1,'LineStyle','none')
    end
    
    
    set(ht,'verticalalignment','bottom');
    set(ht,'Color',textcolorfg)
    set(ht,'BackgroundColor',textcolorbg)
    set(ht,'FontSize',fontsize)
    
    
    % process the checkboxes in the gui, switch for [Show Points]
    if ~get(handles.PlotPoints,'Value')
        set(h,'marker','none')
    end
    % process the checkboxes in the gui, switch for [Show Lines]
    if ~get(handles.PlotLines,'Value')
        set(h,'LineStyle','none')
    end
    % process the checkboxes in the gui, switch for [Show Text]
    if ~get(handles.PlotText,'Value')
        set(ht,'Visible','off')
    else
        set(ht,'Visible','on')
    end
end

% put the tool again back on top
figure(handles.figure1)


function PlotOptions_Callback(hObject, eventdata, handles)
% This function provides a popup menu to change the plotting preferences,
% e.g. color, linestyle, etc.
Data = handles.Data;
O    = Data.options;

% build the popup window
prompt={'Marker Style 1',...
    'Marker Style 2',...
    'Marker Size',...
    'Line Style 1',...
    'Line Style 2',...
    'Line Width',...
    'Color 1',...
    'Color 2',...
    'Text Foreground Color',...
    'Text Background Color',...
    'Text Fontsize',...
    'Zoom Factor',...
    'Spline interp. meth.'};
name='Plot Options';
numlines=1;

fields = fieldnames(O);
n = length(fields);

% builde the default answer from the options structure
for k = 1:n
    defaultanswer{k} = O.(fields{k});
    if ~ischar(defaultanswer{k});
        defaultanswer{k} = num2str(defaultanswer{k});
    end
end

% pop the menu
A = inputdlg(prompt,name,numlines,defaultanswer);

% if cancel
if isempty(A)
    set(handles.Status,'string','Options: Canceled')
    return
end

% store the answer back to the options structure
for k = 1:n
    O.(fields{k}) = A{k};
end

% evaluate the field of view
O.zoomfactor = eval(O.zoomfactor);

% error detection switch
optionerror = false;

% check if a proper interpolation method is entered
if ~any(strcmp(O.splinemethod,{'spline','linear','nearest','cubic'}))
    set(handles.Status,'string','Options: invalid method, use "linear", "cubic", or "spline", value reset to default')
    O.splinemethod = 'spline';
    optionerror = true;
end

% check if a proper marker entered
if ~any(strcmp(O.marker1,{'o','s','^','d','v','*','<','>','.','p','h','+','x','none'}))
    set(handles.Status,'string','Options: invalid marker, value reset to default')
    O.marker1 = 'o';
    optionerror = true;
end
if ~any(strcmp(O.marker2,{'o','s','^','d','v','*','<','>','.','p','h','+','x','none'}))
    set(handles.Status,'string','Options: invalid marker, value reset to default')
    O.marker1 = '.';
    optionerror = true;
end

% check if a proper linestyle is entered
if ~any(strcmp(O.linestyle1,{'-','--','-.',':','none'}))
    set(handles.Status,'string','Options: invalid linestyle, value reset to default')
    O.linestyle1 = '-';
    optionerror = true;
end
if ~any(strcmp(O.linestyle2,{'-','--','-.',':','none'}))
    set(handles.Status,'string','Options: invalid linestyle, value reset to default')
    O.linestyle1 = '--';
    optionerror = true;
end

% check if a proper color is entered
if ~any(strcmp(O.color1,{'y','m','c','r','g','b','w','k','none'})) ...
   && isempty(regexp(O.color1,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
    set(handles.Status,'string','Options: invalid color, value reset to default')
    O.color1 = 'r';
    optionerror = true;
end
if ~any(strcmp(O.color2,{'y','m','c','r','g','b','w','k','none'})) ...
   && isempty(regexp(O.color2,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
    set(handles.Status,'string','Options: invalid color, value reset to default')
    O.color2 = 'k';
    optionerror = true;
end
if ~any(strcmp(O.textcolorfg,{'y','m','c','r','g','b','w','k','none'})) ...
   && isempty(regexp(O.textcolorfg,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
    set(handles.Status,'string','Options: invalid color, value reset to default')
    O.textcolorfg = 'k';
    optionerror = true;
end
if ~any(strcmp(O.textcolorbg,{'y','m','c','r','g','b','w','k','none'})) ...
   && isempty(regexp(O.textcolorbg,'\[[(\d*)(\s*)(\.*)]*\]', 'once'))
    set(handles.Status,'string','Options: invalid color, value reset to default')
    O.textcolorbg = 'none';
    optionerror = true;
end


% storing in the big Data structure
Data.options = O;

if ~optionerror
    set(handles.Status,'string','Options adjusted')
end


% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)


function CalibLength_Callback(hObject, eventdata, handles)
% called when changing the calibration Length
Data = handles.Data;

% update the current unit
unit = get(handles.CalibUnit,'String');
unit = unit{get(handles.CalibUnit,'Value')};
Data.unit = unit;

if ~isfield(Data,'Calib')
    % update the measurements
    if isfield(Data,'Mdata')
        Mdata = Data.Mdata;
        n = length(Mdata);
        for k = 1:n
            Mdata(k).unit = Data.unit ;
        end
        Data.Mdata = Mdata ;
    end
    % update the gui
    handles.Data = Data;
    guidata(hObject, handles);
    plotfun(hObject, eventdata, handles)
    return
end

% store previous Length per Pixel (if any)
if isfield(Data,'Lppx')
    oldLppx = Data.Lppx;
else
    oldLppx = 1;
end

% get the current length
L = eval(get(handles.CalibLength,'String'));

% update the length per pixel ratio
Lppx = L/Data.Calib.Pixels;
Data.Lppx = Lppx;


%update the gui
set(handles.CalibRatio,'String',sprintf('%.2f %s',Lppx,unit));

% correction, for recalibration
Lppx = Lppx / oldLppx;


% update the measurements
if isfield(Data,'Mdata')
    Mdata = Data.Mdata;
    n = length(Mdata);
    for k = 1:n
        Mdata(k).X = Mdata(k).X * Lppx;
        Mdata(k).Y = Mdata(k).Y * Lppx;
        Mdata(k).value = Mdata(k).value * Lppx;
        Mdata(k).unit = Data.unit ;
        if isstruct(Mdata(k).circ)
            Mdata(k).circ.xc = Mdata(k).circ.xc * Lppx;
            Mdata(k).circ.yc = Mdata(k).circ.yc * Lppx;
            Mdata(k).circ.R  = Mdata(k).circ.R  * Lppx;
        end
        if isstruct(Mdata(k).spline)
            Mdata(k).spline.x = Mdata(k).spline.x * Lppx;
            Mdata(k).spline.y = Mdata(k).spline.y * Lppx;
        end
    end
    Data.Mdata = Mdata ;
end

set(handles.Status,'string','Calibration done')

% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)


function CalibLength_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CalibUnit_Callback(hObject, eventdata, handles)
CalibLength_Callback(hObject, eventdata, handles)

function CalibUnit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Calibrate_Callback(hObject, eventdata, handles)
% this function allows the user to calibrate on the scalebar, ruler, etc.
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;
buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')

figure(Data.gcf)

% select two preliminary points
set(handles.Status,'string','Calibrate: Select two points to form a Line')
if get(handles.ZoomSelect,'Value')
    [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u v] = ginput(1);
end
h = plot(u,v,'r+',u,v,'bo','markersize',10);
if get(handles.ZoomSelect,'Value')
    [u(2) v(2)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(2) v(2)] = ginput(1);
end
h(3:4) = plot(u,v,'r+',u,v,'bo','markersize',10);
% remove the points
delete(h);

if get(handles.Quickmeasure,'value')
    position = [u(1) v(1) ; u(2) v(2)];
else
    set(handles.Status,'string','Calibrate: Adjust the Line, double click the line when ready')
    h = imline(Data.gca,[u(1) v(1) ; u(2) v(2)]);
    % update status info
    % get the position, and wait for double click
    position = wait(h);
    % remove the line
    delete(h);
end

% calculate distance (hypot = robust sqrt(x^2+y^2))
A = diff(position(:,1));
B = diff(position(:,2));
pixels = hypot(A,B);

% store the position
X = position(:,1);
Y = position(:,2);

% put the tool again back on top
figure(handles.figure1)

if isfield(Data,'Lppx')
    Lppx = Data.Lppx;
else
    Lppx = 1;
end

X = X / Lppx;
Y = Y / Lppx;
pixels = pixels / Lppx;

% store calibration data in the Data structure
Data.Calib.Pixels = pixels;
Data.Calib.X = X;
Data.Calib.Y = Y;

% update the status
set(handles.CalibPixel,'String',sprintf('%.2f',pixels));drawnow
set(handles.Status,'string','Calibration done')

handles.Data = Data;
guidata(hObject, handles);
% redraw the image (first check the unit and length)
set(handles.Status,'String',sprintf('Calibration: %g pixels selected',pixels));drawnow
set(buttons,'Enable','on')

CalibLength_Callback(hObject, eventdata, handles)

function Distance_Callback(hObject, eventdata, handles)
% this function preselects the distance measurement
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;

buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')


% first ask for 2 points, plot each point and remove the points when done.
set(handles.Status,'string','Distance: Select two points')
figure(Data.gcf)
% select two preliminary points
if get(handles.ZoomSelect,'Value')
    [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u v] = ginput(1);
end
h = plot(u,v,'r+',u,v,'bo','markersize',10);
if get(handles.ZoomSelect,'Value')
    [u(2) v(2)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(2) v(2)] = ginput(1);
end
h(3:4) = plot(u,v,'r+',u,v,'bo','markersize',10);
delete(h);

% call the real distance measurement function
Distancefun(hObject, eventdata, handles,u,v)
set(buttons,'Enable','on')


function Distancefun(hObject, eventdata, handles,u,v)
% this function allows the measuring of a two point distance
Data = handles.Data;

if get(handles.Quickmeasure,'value')
    position = [u(1) v(1) ; u(2) v(2)];
else
    % place an imline using the two points
    set(handles.Status,'string','Distance: Adjust the Line, double click the line when ready')
    h = imline(Data.gca,[u(1) v(1) ; u(2) v(2)]);
    % wait for double click, and get position
    position = wait(h);
    % remove the line
    delete(h);
end

% calculate the distance (hypot = pythagoras)
A = diff(position(:,1));
B = diff(position(:,2));
Distance = hypot(A,B);

% store position for later plotting
X = position(:,1);
Y = position(:,2);

% create image space (for intensity)
[x y] = meshgrid(Data.x,Data.y);

% calculate a length vector
t = [ 0 ; hypot(diff(X),diff(Y)) ];
t = cumsum(t);

% discretize the measurement line
Ni = 200;
ti = linspace(0,max(t),Ni);
xi = interp1(t,X,ti);
yi = interp1(t,Y,ti);

% grayscale the image
im = grayscale(Data.Im);

% interpolate the intensity profile along the measurement line
profile = interp2(x,y,im,xi,yi);

% calculate the average intensity
intensity = mean(profile);

% get the unit, or set it to pixels
if ~isfield(Data,'unit')
    Data.unit = 'pixels';
end

%Save the measurement in the structure
if ~isfield(Data,'Mdata')
    % if first measurement
    n = 1;
else
    % or open a new slot in the measurement data structure
    n = length(Data.Mdata) + 1;
end

% store the measurement
Data.Mdata(n).n         = n;
Data.Mdata(n).type      = 'Distance';
Data.Mdata(n).value     = Distance;
Data.Mdata(n).unit      = Data.unit;
Data.Mdata(n).X         = X;
Data.Mdata(n).Y         = Y;
Data.Mdata(n).spline    = [];
Data.Mdata(n).circ      = [];
Data.Mdata(n).filenum   = Data.cfilenum;
Data.Mdata(n).file      = Data.cfile;
Data.Mdata(n).intensity = intensity;
Data.Mdata(n).profile   = [ti ; profile];


% update the status
set(handles.Status,'String',sprintf('Distance: %.2f %s stored to measurements',Distance,Data.unit));drawnow

% put the tool again back on top
figure(handles.figure1)

% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)

function Caliper_Callback(hObject, eventdata, handles)
% start the caliper measurement (preselecting)
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;
buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')

% first select 2 points to position a line
set(handles.Status,'string','Caliper: Select two points, to position the Line')
figure(Data.gcf)
% select two preliminary points
if get(handles.ZoomSelect,'Value')
    [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u v] = ginput(1);
end
h = plot(u,v,'r+',u,v,'bo','markersize',10);
if get(handles.ZoomSelect,'Value')
    [u(2) v(2)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(2) v(2)] = ginput(1);
end
h(3:4) = plot(u,v,'r+',u,v,'bo','markersize',10);
delete(h);

if get(handles.Quickmeasure,'value')
    L = [u(1) v(1) ; u(2) v(2)];
else
    % position the line
    h = imline(Data.gca,[u(1) v(1) ; u(2) v(2)]);
    set(handles.Status,'string','Caliper: Adjust the Line, double click the line when ready')
    L = wait(h);
    delete(h);
end

% when done plot the temporary line
X = L(:,1);
Y = L(:,2);
h = plot(X,Y,'-+r',X,Y,'--ob','markersize',10);

if get(handles.Quickmeasure,'value')
    set(handles.Status,'string','Caliper: Select the perpendicular Point')
    if get(handles.ZoomSelect,'Value')
        [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
    else
        [u v] = ginput(1);
    end
    P = [u(1) v(1)];
else
    % now position a point
    set(handles.Status,'string','Caliper: Adjust the Point, double click the line when ready')
    hp = impoint(Data.gca);
    P = wait(hp);
    delete(hp);
    delete(h);
end

u = [X ; P(1)];
v = [Y ; P(2)];

% the real caliper measurement part
Caliperfun(hObject, eventdata, handles,u,v)
set(buttons,'Enable','on')


function Caliperfun(hObject, eventdata, handles,u,v)
% this function allows a distance measurement of a line-point type
Data = handles.Data;

% calculate the perpendicular distance
% =================================
x1 = u(1);
x2 = u(2);
y1 = v(1);
y2 = v(2);

x3 = u(3);
y3 = v(3);

% The perpendicular distance (http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html)
D = ( (x2-x1)*(y1-y3) - (x1-x3)*(y2-y1) ) / hypot(x2-x1,y2-y1);
Caliper = abs(D);

% now determine the location of the fourth point for plotting
dx = x1-x2;
dy = y1-y2;
dist = sqrt(dx*dx + dy*dy);
dx = dx / dist;
dy = dy / dist;
x4 = x3 + D*dy;
y4 = y3 - D*dx;

% Storing the four points
X = [x1 ; x2 ; x3 ; x4];
Y = [y1 ; y2 ; y3 ; y4];

% create image space (for intensity)
[x y] = meshgrid(Data.x,Data.y);

% calculate a length vector
t = [ 0 ; hypot(diff(X(3:4)),diff(Y(3:4))) ];
t = cumsum(t);

% discretize the measurement line
Ni = 200;
ti = linspace(0,max(t),Ni);
xi = interp1(t,X(3:4),ti);
yi = interp1(t,Y(3:4),ti);

% grayscale the image
im = grayscale(Data.Im);

% interpolate the intensity profile along the measurement line
profile = interp2(x,y,im,xi,yi);

% calculate the average intensity
intensity = mean(profile);

if ~isfield(Data,'unit')
    Data.unit = 'pixels';
end

%Save the measurement in the structure
if ~isfield(Data,'Mdata')
    n = 1;
else
    n = length(Data.Mdata) + 1;
end
Data.Mdata(n).n         = n;
Data.Mdata(n).type      = 'Caliper';
Data.Mdata(n).value     = Caliper;
Data.Mdata(n).unit      = Data.unit;
Data.Mdata(n).X         = X;
Data.Mdata(n).Y         = Y;
Data.Mdata(n).spline    = [];
Data.Mdata(n).circ      = [];
Data.Mdata(n).filenum   = Data.cfilenum;
Data.Mdata(n).file      = Data.cfile;
Data.Mdata(n).intensity = intensity;
Data.Mdata(n).profile   = [ti ; profile];

% update the status
set(handles.Status,'String',sprintf('Caliper: %.2f %s stored to measurements',Caliper,Data.unit));drawnow

% put the tool again back on top
figure(handles.figure1)

handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)

function circ = circlefit(x,y)
% least squares circle fitting (see matlab help/demo (pendulum))
n = length(x);
M   = [x(:), y(:) ones(n,1)];
abc = M \ -( x(:).^2 + y(:).^2);
xc  = -abc(1)/2;
yc  = -abc(2)/2;
R   = sqrt((xc^2 + yc^2) - abc(3));

circ.xc = xc;
circ.yc = yc;
circ.R  = R;

function Circle_Callback(hObject, eventdata, handles)
% initiate the circle measurement
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;
buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')

% ask for two points (center and radius)
if get(handles.Quickmeasure,'value')
    set(handles.Status,'string','Circle: Select Point 1 / 5 on the Edge of the circle')
else
    set(handles.Status,'string','Circle: Select the Center of the circle')
end
figure(Data.gcf)
if get(handles.ZoomSelect,'Value')
    [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u v] = ginput(1);
end
h = plot(u,v,'r+',u,v,'bo','markersize',10);
if get(handles.Quickmeasure,'value')
    set(handles.Status,'string','Circle: Select Point 2 / 5 on the Edge of the circle')
else
    set(handles.Status,'string','Circle: Select a Point on the Edge of the circle')
end
if get(handles.ZoomSelect,'Value')
    [u(2) v(2)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(2) v(2)] = ginput(1);
end
h(3:4) = plot(u,v,'r+',u,v,'bo','markersize',10);
delete(h);

Circlefun(hObject, eventdata, handles,u,v)
set(buttons,'Enable','on')


function Circlefun(hObject, eventdata, handles,u,v)
% This function allows the measurement of a radius, using a cirlce
Data = handles.Data;
% calculate the box around the circle
A = diff(u);
B = diff(v);
R = hypot(A,B);
P = [u(1)-R v(1)-R 2*R 2*R];


if get(handles.Quickmeasure,'value')
    position = [u(1) v(1) ; u(2) v(2)];
    h = plot(u,v,'r+',u,v,'bo','markersize',10);
    for k = 3:5
        set(handles.Status,'string',sprintf('Circle: Select Point %g / 5 on the Edge of the circle',k))
        if get(handles.ZoomSelect,'Value')
            [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
        else
            [u v] = ginput(1);
        end
        h = [h plot(u,v,'or',u,v,'.b','markersize',10)];
        position(k,:) = [u v];
    end
    delete(h);
else
    % position a draggable circle
    set(handles.Status,'string','Circle: Adjust the Circle, double click the line when ready')
    h = imellipse(Data.gca,P);
    % fix the aspect ratio (so no ellipses are allowed)
    setFixedAspectRatioMode(h,true)
    position = wait(h);
    delete(h);
end
% use circlefit to obtain the radius
circ = circlefit(position(:,1),position(:,2));
xc = circ.xc;
yc = circ.yc;
Radius = circ.R;

% store points on the circle for later plotting
if get(handles.Quickmeasure,'value')
    phi = linspace(0,2*pi,30);
    X = circ.R*sin(phi) + circ.xc;
    Y = circ.R*cos(phi) + circ.yc;
else
    X = position(:,1);
    Y = position(:,2);
end

% create image space (for intensity)
[x y] = meshgrid(Data.x,Data.y);

% find all pixels inside the circle
incircle = inpolygon(x,y,X,Y);

% grayscale the image
im = grayscale(Data.Im);

% calculate the average intensity
intensity = mean(im(incircle));

% distance from center
ti = hypot(x(incircle)-xc,y(incircle)-yc).';

% profile
profile = im(incircle).';


if ~isfield(Data,'unit')
    Data.unit = 'pixels';
end

%Save the measurement in the structure
if ~isfield(Data,'Mdata')
    n = 1;
else
    n = length(Data.Mdata) + 1;
end

Data.Mdata(n).n         = n;
Data.Mdata(n).type      = 'Circle (R)';
Data.Mdata(n).value     = Radius;
Data.Mdata(n).unit      = Data.unit;
Data.Mdata(n).X         = X;
Data.Mdata(n).Y         = Y;
Data.Mdata(n).spline    = [];
Data.Mdata(n).circ      = circ;
Data.Mdata(n).filenum   = Data.cfilenum;
Data.Mdata(n).file      = Data.cfile;
Data.Mdata(n).intensity = intensity;
Data.Mdata(n).profile   = [ti ; profile];

% update the status
set(handles.Status,'String',sprintf('Circle: %.2f %s stored to measurements',Radius,Data.unit));drawnow

% put the tool again back on top
figure(handles.figure1)

% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)


function Angle_Callback(hObject, eventdata, handles)
% initate the Angle measurement
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;
buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')

figure(Data.gcf)
set(handles.Status,'string','Angle: Select the Intersection')
if get(handles.ZoomSelect,'Value')
    [u v] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u v] = ginput(1);
end
h = plot(u,v,'r+',u,v,'bo','markersize',10);
set(handles.Status,'string','Angle: Select a Point to form a Line 1 with the Intersection')
if get(handles.ZoomSelect,'Value')
    [u(2) v(2)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(2) v(2)] = ginput(1);
end
h(3:4) = plot(u,v,'r+',u,v,'bo','markersize',10);
set(handles.Status,'string','Angle: Select a Point to form a Line 2 with the Intersection')
if get(handles.ZoomSelect,'Value')
    [u(3) v(3)] = zoomselect(Data.gca,Data.options.zoomfactor);
else
    [u(3) v(3)] = ginput(1);
end
h(5:6) = plot(u,v,'r+',u,v,'bo','markersize',10);
delete(h);

Anglefun(hObject, eventdata, handles,u,v)
set(buttons,'Enable','on')


function Anglefun(hObject, eventdata, handles,u,v)
% This function allows the measurement of an angle using three points
Data = handles.Data ;

if get(handles.Quickmeasure,'value')
    position = [u(2),v(2);u(1),v(1);u(3),v(3)];
else
    set(handles.Status,'string','Angle: Adjust the Polygon, double click the line when ready')
    h = impoly(Data.gca,[u(2),v(2);u(1),v(1);u(3),v(3)],'Closed',false);
    position = wait(h);
    delete(h);
end

% Create two vectors from the vertices.
v1 = [position(1,1)-position(2,1), position(1,2)-position(2,2)];
v2 = [position(3,1)-position(2,1), position(3,2)-position(2,2)];
phi = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
Angle = (phi * (180/pi)); % radtodeg(phi)

X = position(:,1);
Y = position(:,2);

% create image space (for intensity)
[x y] = meshgrid(Data.x,Data.y);

% calculate a length vector
t = [ 0 ; hypot(diff(X),diff(Y)) ];
t = cumsum(t);

% discretize the measurement line
Ni = 200;
ti = linspace(0,max(t),Ni);
xi = interp1(t,X,ti);
yi = interp1(t,Y,ti);

% grayscale the image
im = grayscale(Data.Im);

% interpolate the intensity profile along the measurement line
profile = interp2(x,y,im,xi,yi);

% calculate the average intensity
intensity = mean(profile);

%Save the measurement in the structure
if ~isfield(Data,'Mdata')
    n = 1;
else
    n = length(Data.Mdata) + 1;
end

Data.Mdata(n).n         = n;
Data.Mdata(n).type      = 'Angle';
Data.Mdata(n).value     = Angle;
Data.Mdata(n).unit      = Data.degree;
Data.Mdata(n).X         = X;
Data.Mdata(n).Y         = Y;
Data.Mdata(n).spline    = [];
Data.Mdata(n).circ      = [];
Data.Mdata(n).filenum   = Data.cfilenum;
Data.Mdata(n).file      = Data.cfile;
Data.Mdata(n).intensity = intensity;
Data.Mdata(n).profile   = [ti ; profile];

% update the status
set(handles.Status,'String',sprintf('Angle: %.2f %s stored to measurements',Angle,Data.degree));drawnow

% put the tool again back on top
figure(handles.figure1)

% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)

function Spline_Callback(hObject, eventdata, handles)
% % this function preselects the spline measurement
if ~isfield(handles.Data,'gcf')
    return
end
Data = handles.Data;
buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);
set(buttons,'Enable','off')

prompt = 'Enter number of points:';
dlg_title = 'Select the number of Spline points';
num_lines = 1;
def = {'5'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% if cancel
if isempty(answer)
    set(handles.Status,'string','Spline: Canceled')
    return
end
n = eval(answer{1});

% set minimum to 2
n = max([2 n]);

figure(Data.gcf)
u = zeros(1,n);
v = zeros(1,n);
h = zeros(2,n);
for k = 1:n
    set(handles.Status,'string',sprintf('Spline: Select Point %g / %g',k,n))
    if get(handles.ZoomSelect,'Value')
        [u(k) v(k)] = zoomselect(Data.gca,Data.options.zoomfactor);
    else
        [u(k) v(k)] = ginput(1);
    end
    h(:,k) = plot(u(k),v(k),'r+',u(k),v(k),'bo');
end
delete(h);

% call the real distance measurement function
Splinefun(hObject, eventdata, handles,u,v)
set(buttons,'Enable','on')


function Splinefun(hObject, eventdata, handles,u,v)
% this function allows the measuring of a multi point spline length
Data = handles.Data;

if get(handles.Quickmeasure,'value')
    position = [u ; v ].';
else
    % place an imline using the two points
    set(handles.Status,'string','Spline: Adjust the Polygon, double click the line when ready')
    h = impoly(Data.gca,[u ; v ].','Closed',false);
    % wait for double click, and get position
    position = wait(h);
    % remove the line
    delete(h);
end

X = position(:,1);
Y = position(:,2);

% save for later plotting
spl.x = X;
spl.y = Y;

% calculate a length vector
t = [ 0 ; hypot(diff(X),diff(Y)) ];
t = cumsum(t);

% testing for uniqueness
I = unique(t);
if length(I) ~= length(t)
    set(handles.Status,'string','Spline: error, points must be distict')
    return
end


% number of interpolation points
N = 50*length(X);

% interpolation method
method = Data.options.splinemethod;

% intepolate along the length vector
ti = linspace(0,max(t),N) ;
xi = interp1(t,X,ti,method);
yi = interp1(t,Y,ti,method);

% calculate the spline length
L = sum( hypot( diff(xi),diff(yi) ) );

% create image space (for intensity)
[x y] = meshgrid(Data.x,Data.y);

% grayscale the image
im = grayscale(Data.Im);

% interpolate the intensity profile along the measurement line
profile = interp2(x,y,im,xi,yi);

% calculate the average intensity
intensity = mean(profile);

% get the unit, or set it to pixels
if ~isfield(Data,'unit')
    Data.unit = 'pixels';
end

%Save the measurement in the structure
if ~isfield(Data,'Mdata')
    % if first measurement
    n = 1;
else
    % or open a new slot in the measurement data structure
    n = length(Data.Mdata) + 1;
end

% store the measurement
Data.Mdata(n).n         = n;
Data.Mdata(n).type      = 'Spline';
Data.Mdata(n).value     = L;
Data.Mdata(n).unit      = Data.unit;
Data.Mdata(n).X         = xi;
Data.Mdata(n).Y         = yi;
Data.Mdata(n).spline    = spl;
Data.Mdata(n).circ      = [];
Data.Mdata(n).filenum   = Data.cfilenum;
Data.Mdata(n).file      = Data.cfile;
Data.Mdata(n).intensity = intensity;
Data.Mdata(n).profile   = [ti ; profile];

% update the status
set(handles.Status,'String',sprintf('Spline: %.2f %s stored to measurements',L,Data.unit));drawnow

% put the tool again back on top
figure(handles.figure1)

% update the gui
handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)

function PlotPoints_Callback(hObject, eventdata, handles)
plotfun(hObject, eventdata, handles)

function PlotLines_Callback(hObject, eventdata, handles)
plotfun(hObject, eventdata, handles)

function PlotText_Callback(hObject, eventdata, handles)
plotfun(hObject, eventdata, handles)

function Edit_Callback(hObject, eventdata, handles)
% This function allows the editing of a previous measurement
if ~isfield(handles.Data,'Mdata') || isempty(handles.Data.Mdata)
    set(handles.Status,'String','Edit: No measurements to edit');drawnow
    return
end
Data = handles.Data;
Mdata = Data.Mdata;
n = length(Mdata);

% build a list of previous measurements
for i = 1:n
    prompt{i} = [num2str(Mdata(i).n) ': ' Mdata(i).type ' ' sprintf('%.2f',Mdata(i).value) ' ' Mdata(i).unit];
end

% always ask which one (allows for abort)
[Selection,ok] = listdlg('Name','Select a measurement','PromptString','Select a measurement:','SelectionMode','single','ListString',prompt);
if (ok == 0) || isempty(Selection)
    return
end
k = Selection;

type = Mdata(k).type;
set(handles.Status,'string',['Edit: ' type])

% create a list for each dataset
N = 1:n;
% select the not selected sets
C = setdiff(N,k);
Data.Mdata = Mdata(C);
handles.Data = Data;
guidata(hObject, handles);

buttons = findobj(handles.figure1,'Enable','on');
buttons = setdiff(buttons,[handles.Status handles.Clear]);


% repeat the measurement function above, except with the old
% points as input/base of the new measurement
switch type
    case 'Distance'
        figure(Data.gcf)
        if get(handles.Quickmeasure,'value')
            Distance_Callback(hObject, eventdata, handles)
        else
            set(buttons,'Enable','off')
            u = Mdata(k).X;
            v = Mdata(k).Y;
            Distancefun(hObject, eventdata, handles,u,v)
            set(buttons,'Enable','on')
        end
    case 'Caliper'
        figure(Data.gcf)
        if get(handles.Quickmeasure,'value')
            Caliper_Callback(hObject, eventdata, handles)
        else
            set(buttons,'Enable','off')
            u = Mdata(k).X;
            v = Mdata(k).Y;
            
            % position the line
            set(handles.Status,'string','Caliper: Adjust the Line, double click the line when ready')
            h = imline(Data.gca,[u(1) v(1) ; u(2) v(2)]);
            L = wait(h);
            delete(h);
            
            % when done plot the temporary line
            X = L(:,1);
            Y = L(:,2);
            h = plot(X,Y,'-+r',X,Y,'--ob');
            
            % now position a point
            set(handles.Status,'string','Caliper: Adjust the Point, double click the line when ready')
            hp = impoint(Data.gca, u(3), v(3));
            P = wait(hp);
            delete(hp);
            delete(h);
            
            u = [X ; P(1)];
            v = [Y ; P(2)];
            
            Caliperfun(hObject, eventdata, handles,u,v)
            set(buttons,'Enable','on')
        end
    case 'Circle (R)'
        if get(handles.Quickmeasure,'value')
            Circle_Callback(hObject, eventdata, handles)
        else
            set(buttons,'Enable','off')
            u = Mdata(k).circ.xc;
            v = Mdata(k).circ.yc;
            u(2) = u + Mdata(k).circ.R;
            v(2) = v;
            Circlefun(hObject, eventdata, handles,u,v)
            set(buttons,'Enable','on')
        end
    case 'Angle'
        if get(handles.Quickmeasure,'value')
            Angle_Callback(hObject, eventdata, handles)
        else
            set(buttons,'Enable','off')
            figure(Data.gcf)
            u = Mdata(k).X([2 1 3]);
            v = Mdata(k).Y([2 1 3]);
            Anglefun(hObject, eventdata, handles,u,v)
            set(buttons,'Enable','on')
        end
    case 'Spline'
        if get(handles.Quickmeasure,'value')
            Spline_Callback(hObject, eventdata, handles)
        else
            set(buttons,'Enable','off')
            u = Mdata(k).spline.x.' ;
            v = Mdata(k).spline.y.' ;
            Splinefun(hObject, eventdata, handles,u,v)
            set(buttons,'Enable','on')
        end
    otherwise
        set(handles.Status,'string','Edit: unkown measurement type')
        return
end


function Delete_Callback(hObject, eventdata, handles)
% this function allows the removal of one or several previously made
% measurements.
if ~isfield(handles.Data,'Mdata') || isempty(handles.Data.Mdata)
    set(handles.Status,'String','Delete: No measurements to edit');drawnow
    return
end
Data = handles.Data;
Mdata = Data.Mdata;
n = length(Mdata);

% build a list of previously made measurements
for i = 1:n
    prompt{i} = [num2str(Mdata(i).n) ': ' Mdata(i).type ' ' sprintf('%.2f',Mdata(i).value) ' ' Mdata(i).unit];
end

% always ask which one (allows for abort)
[Selection,ok] = listdlg('Name','Select measurements','PromptString','Select measurements:','SelectionMode','multiple','ListString',prompt);
if (ok == 0) || isempty(Selection)
    return
end

% create a list for each dataset
N = 1:n;
% select the not selected sets
C = setdiff(N,Selection);
Data.Mdata = Mdata(C);

handles.Data = Data;
guidata(hObject, handles);
plotfun(hObject, eventdata, handles)


function guihelp(handles)
% this function prints this help to a temporary file and opens the file in
% a text editor.
txt = {;
    'This tool (measure tool) is intended to aid measuring on images.'
    'In order to do this the image needs to have some visual scale to calibrate the pixel to length ratio on, e.g. scale bar, ruler.'
    ''
    'Updates can be found at:'
    'http://www.mathworks.nl/matlabcentral/fileexchange/25964-image-measurement-utility'
    ''
    'Quick Help'
    '============================='
    ' - Select an image using <Browse>'
    ' - Press <Calibrate> and select two points of which the distance is known'
    ' - Use the zoom function of the toolbar and correct your initial selection'
    ' - Double Click the line to confirm'
    ' - Enter the length of the selected distance in the calibration panel'
    ' - Calibration is ready:'
    ' - Use the <Distance>, <Spline>, <Caliper>, <Circle>, or <Angle> tools to measure'
    ' - Each measurement can be deleted using <Delete> or modified using <Edit>'
    ''
    'Image processing toolbox tools'
    '============================='
    'The tool is intended for high quality measurements, and is therefore build around tools like "imline" from the image processing toolbox. These tools are powerful because they allow you to select, zoom, re-adjust, and than confirm your selection. As a result, all measurements require several "clicks", the first set of clicks can be quick, and allow you to place the measurement tool, where after the tool can be modified using its control points, when ready double click on the tool to finalize the selection. Finally, it is important that the full sequence of "clicks" is finished before a new measurement is started, otherwise the GUI will terminate less gracefully. If the image processing toolbox is unavailable, or a Matlab version older then 2009b (7.9.0) is used, then the <Quick> option can be used (optionally with <Zoom Select>) to bypass the "imline" selection tools.'
    ''
    'Listbox of images'
    '============================='
    'After selecting an image (using the <Browse...> button), a list of all images in the folder is loaded in the tool, this allows the measurement on several files without the need to re-calibrate, which off coarse only works if the images actually share the same scale, e.g. like in a movie.'
    ''
    'Status'
    '============================='
    'Status information is shown here.'
    ''
    'Calibrate'
    '============================='
    'It goes without saying that each measurement depends on the calibration, so it is worth spending some time on getting it right. Furthermore, the calibration can be re-done at any time, all measurements will be updated accordingly.'
    ''
    'Measure'
    '============================='
    '<Distance>: measure the distance between two points, first place two initial points, then correct and confirm the selected distance by double clicking on the line.'
    '<Caliper>: measure the perpendicular distance between a line and a point, first place two initial points, then correct and confirm (double click) the position of the line, now place a point at a distance perpendicular to the line, again correct the position and confirm with a double click.'
    '<Spline>: measure the length of a multi-point spline. This tool is very similar to the "Distance" tool, except it handles more than 2 points and interpolates them using the spline interpolation method of interp1 (tip: set the method to "linear" in the options menu to measure polygons).'
    '<Circle>: measure a radius by placing a circle, first select the center of the circle and then one point on the circle, the position and size of the circle can be corrected, confirm with a double click on the circle. The selection behavior changes slightly when the "Quick" option is selected, then five points need to be selected through which a circle is fitted.'
    '<Angle>: measure an angle between two lines, first select the intersection and then two more points to one for each line, the three point line can be moved and the position of the points can be moved by dragging them with the mouse, double click on the line to confirm the measurement.'
    '<Edit>: Reposition the points of one measurement which can be selected from a list'
    '<Delete>: Delete one or multiple measurements using a list'
    ''
    'Plot'
    '============================='
    'In this panel a set of plotting options can be found, which switch on (or off) visual objects. <Points>, <Lines>, and, <Text>, not quite unexpectedly, enable (or disable) to plotting of points, lines, and texts. When <All> is enabled then measurements from all images in the "List" are shown simultaneously, when disabled then only measurements from the current image are shown. <Intensity> switches the text from the spatial quantity to the average intensity of the pixels underneath the measured object. For "Distance", "Angle", and "Spline" the intensity is calculated by interpolating the pixel values on discretized points of the measured (and plotted) line, and average those. For "Caliper" the intensity is calculated in the same way but only for the "perpendicular" line, i.e., the line connecting the selected line and point. For "Circle" the average intensity is calculated for all pixels inside the circle. Actually, for all measurement types except "Circle", the intensity profiles are stored and can be found in the myname(k).profile matrix (see "save to workspace"), where the first column is the distance along the measurement and the second column the corresponding intensity.'
    ''
    'Save'
    '============================='
    '<Workspace>: A popup asks for a variable name, to which all measurements are stored to the base workspace in the form of a structure. The measurement data can be found by typing myname(k) where k is an integer selecting the specific measurement.'
    '<Text>: A popup asks for a .txt file name, after which all data is written to the file.'
    '<Image (png)>: A popup asks for a .png file name, after which the "measure window" is saved as a .png file (note, the image is anti-aliased which takes some time)'
    '<Image (pdf)>: A popup asks for a .pdf file name, after which the "measure window" is saved as a .pdf file'
    ''
    'Current Figure'
    '============================='
    'Calling measuretool(gcf) will open the tool for use on the current figure, for instance one created with imagesc(x,y,Z). In this mode all file selection tools are disabled. Typically, such figures have non-square pixels for which the calibration process is not well defined, therefore, the axes are assumed to be calibrated (i.e. have meaningful values) and the calibration options are also disabled.'
    ''
    'Changelog'
    '============================='
    'version 1.13 by Jan Neggers, Jan,12,2012'
    '   - added feature to measure the intensity (as suggested by Jakub)'
    '   - included the "Plot" section in the help'
    '   - simplified the save to workspace structure'
    ''
    'version 1.12 by Jan Neggers, Dec,7,2011'
    '   - most GUI buttons are now disabled during measurements to prevent confusion'
    '   - added a "clear" button to reset the tool'
    '   - added more input checks for the "options" menu'
    ''
    'version 1.11 by Jan Neggers, Sept,29,2011'
    '   - minor update, added the possibility to use a figure window which is already open (e.g. measuretool(gcf))'
    '   - changed the zoom select from absolute to relative'
    '   - all buttons are now disabled during measurement'
    ''
    'version 1.10 by Jan Neggers, Sept,27,2011'
    '   - entire overhaul of the gui, added quite a few features, some of which as proposed by Mark Hayworth'
    ''
    'version 1.00 by Jan Neggers, Sept,22,2011'
    '   - fixed some bugs related to the help'
    '   - improved displaying in micrometers'
    '   - added the four <Save> buttons'
    ''
    'version 0.92 by Jan Neggers, Apr,06,2010'
    '   - fixed grayscale images showing in color (after comment from Till)'
    '   - improved help file displaying'
    ''
    'version 0.91 by Jan Neggers, Nov,30,2009'
    '   - first version'
    };

% create a temporary file to hold the help.txt
tempfile = [tempdir 'measuretool_help.txt'];
fid = fopen(tempfile,'wt+');
for i = 1:length(txt)
    fprintf(fid,'%s\n',txt{i});
end
fclose(fid);

% open the file (in windows or unix)
try
    if ispc
        % windows
        winopen(tempfile)
    elseif isunix
        % unix (linux)
        % finding out which text editors are present
        [a b] = system('type gedit kate mousepad');
        % converting to a 3x1 cell
        a = textscan(b,'%s','delimiter','\n');
        % searching for the words not found
        a = regexpi(a{1},'.not found');
        % opening the text file
        if isempty(a{1})
            command = ['! gedit ' tempfile ' &'];
            eval(command)
        elseif isempty(a{2})
            command = ['! kate ' tempfile ' &'];
            eval(command)
        elseif isempty(a{3})
            command = ['! mousepad ' tempfile ' &'];
            eval(command)
        else
            % if no editor is found then print to command window
            set(handles.Status,'string','Help: could not find a suitable text editor to show the help file, see command window.')
            for i = 1:length(txt)
                fprintf('%s \n',txt{i})
            end
        end
        
    end
catch ME
    set(handles.Status,'string','Help: Something went wrong, printing help to command screen.')
    for i = 1:length(txt)
        fprintf('%s \n',txt{i})
    end
    %     rethrow(ME)
end

function Help_Callback(hObject, eventdata, handles)
guihelp(handles)

function SaveWorkspace_Callback(hObject, eventdata, handles)
Data = handles.Data ;
if ~isfield(Data,'Mdata')
    set(handles.Status,'string','Save: No data to save to workspace.')
    return
end

N = length(Data.Mdata);
for k = 1:N;
    % load one measurement
    M = Data.Mdata(k);
    
    % store coordinates
    if strcmp(M.type,'Circle (R)')
        X = M.circ.xc ;
        Y = M.circ.yc ;
    elseif strcmp(M.type,'Spline')
        X = M.spline.x ;
        Y = M.spline.y ;
    else
        X = M.X;
        Y = M.Y;
    end
    
    % prepare save structure
    D(k).filename  = M.file;
    D(k).type      = M.type;
    D(k).value     = M.value;
    D(k).intensity = M.intensity;
    D(k).profile   = M.profile;
    D(k).unit      = M.unit;
    D(k).x = X;
    D(k).y = Y;
end

% build the popup window
prompt={'Choose a Workspace variable name'};
name='Save to workspace';
numlines=1;
defaultanswer={'mt'};
% pop the menu
A = inputdlg(prompt,name,numlines,defaultanswer);

% if cancel
if isempty(A)
    set(handles.Status,'string','Save: Canceled')
    return
end

% save to workspace
assignin('base',A{1},D);

set(handles.Status,'string',sprintf('Save: Data saved to variable %s',A{1}))

function SaveText_Callback(hObject, eventdata, handles)
Data = handles.Data ;
if ~isfield(Data,'Mdata')
    set(handles.Status,'string','Save: No data to save to file.')
    return
end
% prompt for a filename to save to
[file,path] = uiputfile('mt_data.txt','Save file name');
if file == 0
    set(handles.Status,'string','Save: to text aborted.')
    return
end

% open file for writing (and trunctate)
fid = fopen(fullfile(path,file),'wt+');

% Write the header
fprintf(fid,'Data file created by measuretool.m \r\n');
fprintf(fid,'=========================================== \r\n');
fprintf(fid,'Filename:    %s \r\n',Data.cfile);
fprintf(fid,'Date:        %s \r\n',datestr(now));
[n m k] = size(Data.Im);
fprintf(fid,'Image Size:  (%gx%gx%g) \r\n',n,m,k);
% Calibration
if isfield(Data,'Lppx')
    fprintf(fid,'Calibration: %g %s per pixel \r\n',Data.Lppx,Data.unit);
else
    fprintf(fid,'Calibration: none \r\n');
end
fprintf(fid,'= End of Header =========================== \r\n');
fprintf(fid,'%3s, %12s, %5s, %10s, %12s, %s, %s, %s \r\n','n','value','unit','type','intensity','[xcoords]','[ycoords]','filename');

% Write the Data
N = length(Data.Mdata);
for k = 1:N;
    % load one measurement
    M = Data.Mdata(k);
    
    % get the coordinates
    if strcmp(M.type,'Circle (R)')
        X = M.circ.xc ;
        Y = M.circ.yc ;
    elseif strcmp(M.type,'Spline')
        X = M.spline.x ;
        Y = M.spline.y ;
    else
        X = M.X;
        Y = M.Y;
    end
    
    % format to a string
    xstr = '[ ';
    ystr = '[ ';
    for kk = 1:length(X);
        if kk == 1
            xstr = [ xstr sprintf('%8.2e',X(kk)) ] ;
            ystr = [ ystr sprintf('%8.2e',Y(kk)) ] ;
        else
            xstr = [ xstr ' ; ' sprintf('%8.2e',X(kk)) ] ;
            ystr = [ ystr ' ; ' sprintf('%8.2e',Y(kk)) ] ;
        end
    end
    xstr = [ xstr ' ]' ];
    ystr = [ ystr ' ]' ];
    
    % write to file
    fprintf(fid,'%3d, %12.6e, %5s, %10s, %12s, %s, %s, %s \r\n',k,M.value,M.unit,M.type,M.intensity,xstr,ystr,M.file);
end

% close the file
fprintf(fid,'= End of File ============================= \r\n');
fclose(fid);

set(handles.Status,'string',sprintf('Save: Data saved to file %s',file))


function SavePNG_Callback(hObject, eventdata, handles)
% this is an attempt to get anti-aliased png images, it works reasonably
% well execpt for the font sizes, which change a bit between saving.
Data = handles.Data;
if ~isfield(Data,'gcf')
    set(handles.Status,'string','Save: No image to save')
    return
end
H = Data.gcf;

% prompt for a filename to save to
[file,path] = uiputfile('mt_data.png','Save file name');
if file == 0
    set(handles.Status,'string','Save: to png aborted.')
    return
end

% set the status
set(handles.Status,'string','Save: Writing png...')

% fix the extention, to be always .png (small case)
filename = fullfile(path,file);
filename = [regexprep(filename,'.png$','','ignorecase') '.png'];

% get the original figure position (and size)
savepos = get(H,'Position');

% set the paper position to 1 inch per 100 pixels
set(H,'PaperUnits','inches','PaperPosition',savepos.*[0 0 1e-2 1e-2])

% get the fontsize handles
Hf = findobj(H,'-property','FontSize');

% store the original fontsize
fontsize = get(Hf(1),'FontSize');
% double the font size (temporarily)
set(Hf,'FontSize',fontsize*2);

% get a temporary filename
tmp = [tempname '.png'];

% save png (2 times bigger than original)
print(H,tmp,'-dpng','-r200')

% restore the fontsize
set(Hf,'FontSize',fontsize);


% read the temporary image
Im = imread(tmp,'PNG');

% delete the temporary file
delete(tmp);

try
    I = imresize(Im, 0.5, 'bilinear');
catch
    % workaround for missing Image Processing Toolbox
    
    % get the image size
    [n m k] = size(Im);
    % create the interpolation spacing
    xi = (1:2:m) + 0.5 ;
    yi = (1:2:n) + 0.5 ;
    
    % create a new image
    mi = length(xi);
    ni = length(yi);
    I = zeros(ni,mi,k);
    
    % interpolate (per color)
    I(:,:,1) = interp2(double(Im(:,:,1)),xi,yi.','*linear');
    I(:,:,2) = interp2(double(Im(:,:,2)),xi,yi.','*linear');
    I(:,:,3) = interp2(double(Im(:,:,3)),xi,yi.','*linear');
    
    % convert back to integer
    I = uint8(round(I));
end
% write the real .png file
imwrite(I,filename,'PNG')

set(handles.Status,'string',sprintf('Save: PNG file %s saved',file))


function SavePDF_Callback(hObject, eventdata, handles)
Data = handles.Data;
if ~isfield(Data,'gcf')
    set(handles.Status,'string','Save: No image to save')
    return
end
H = Data.gcf;

% prompt for a filename to save to
[file,path] = uiputfile('mt_data.pdf','Save file name');
if file == 0
    set(handles.Status,'string','Save: to pdf aborted.')
    return
end

set(handles.Status,'string','Save: Writing pdf...')

filename = fullfile(path,file);

% fix the extention, to be always .png (small case)
filename = [regexprep(filename,'.pdf$','','ignorecase') '.pdf'];

% get the original figure position (and size)
savepos = get(H,'Position');

% set the paper position to 1 inch per 100 pixels
set(H,'PaperUnits','inches','PaperPosition',savepos.*[0 0 1e-2 1e-2])
set(H,'PaperSize',savepos(3:4).*[1e-2 1e-2])

% save png (3 times bigger than original)
print(H,filename,'-dpdf')

set(handles.Status,'string',sprintf('Save: PDF file %s saved',file))


% --- Executes on selection change in FileBox.
function FileBox_Callback(hObject, eventdata, handles)
Data = handles.Data;

cfilenum = get(handles.FileBox,'Value');
if ~isfield(Data,'ftypes')
    return
end

ctype = Data.ftypes{cfilenum};
cfile = Data.files{cfilenum};

set(handles.Status,'string','List: new file selected')

Data.cfile    = cfile ;
Data.ctype    = ctype ;
Data.cfilenum = cfilenum ;

% storing in the Data structure
handles.Data = Data;
% Update handles structure
guidata(hObject, handles);

plotfun(hObject, eventdata, handles)

function FileBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ShowAll_Callback(hObject, eventdata, handles)
plotfun(hObject, eventdata, handles)

function Quickmeasure_Callback(hObject, eventdata, handles)

function ZoomSelect_Callback(hObject, eventdata, handles)

function Clear_Callback(hObject, eventdata, handles)
Data = handles.Data;
if isfield(Data,'gcf')
    close(Data.gcf)
end
D.options  = Data.options;
D.degree = Data.degree;

Data = D;
handles = rmfield(handles,'Data');

% Enable the all buttons
buttons = findobj(handles.figure1,'Enable','off');
set(buttons,'Enable','on')

% select the current file from in the list
set(handles.FileBox,'String',{'...'});
set(handles.FileBox,'Value',1);

% set status
set(handles.Status,'string','measuretool reset')


% storing in the Data structure
handles.Data = Data;
% Update handles structure
guidata(hObject, handles);

function Intensity_Callback(hObject, eventdata, handles)
plotfun(hObject, eventdata, handles)

function I = grayscale(I)
I = double(I);
if ndims(I) == 3
    I = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
end

