classdef imtool3D < handle
    %This is a image slice viewer with built in scroll, contrast, zoom and
    %ROI tools.
    %
    %   Use this class to place a self-contained image viewing panel within
    %   a GUI (or any figure). Similar to imtool but with slice scrolling.
    %   Only designed to view grayscale (intensity) image.
    %----------------------------------------------------------------------
    %Inputs:
    %
    %   I           An m x n x k image array of grayscale values. Default
    %               is a 100x100x10 random noise image.
    %   position    The position of the panel containing the image and all
    %               the tools. Format is [xmin ymin width height]. Default
    %               position is [0 0 1 1] (units = normalized). See the
    %               setPostion and setUnits methods to change the postion
    %               or units.
    %   h           Handle of the parent figure. Default is the current
    %               figure (gcf).
    %   range       The display range of the image. Format is [min max].
    %               The range can be adjusted with the contrast tool or
    %               with the setRange method. Default is [min(I) max(I)].
    %----------------------------------------------------------------------
    %Output:
    %
    %   tool        The imtool3D object. Use this object as input to the
    %               class methods described below.
    %----------------------------------------------------------------------
    %Constructor Syntax
    %
    %tool = imtool3d() creates an imtool3D panel in the current figure with
    %a random noise image. Returns the imtool3D object.
    %
    %tool = imtool3d(I) sets the image of the imtool3D panel.
    %
    %tool = imtool3D(I,position) sets the position of the imtool3D panel
    %within the current figure. The default units are normalized.
    %
    %tool = imtool3D(I,position,h) puts the imtool3D panel in the figure
    %specified by the handle h.
    %
    %tool = imtool3D(I,position,h,range) sets the display range of the
    %image according to range=[min max].
    %
    %Note that you can pass an empty matrix for any input variable to have
    %the constructor use default values. ex. tool=imtool3D([],[],h,[]).
    %----------------------------------------------------------------------
    %Methods:
    %
    %   tool.I = I_new sets the I (image) property of tool to I_new. Use
    %   this sytax to change the image being displayed.
    %
    %   setPostion(tool,position) sets the position of tool.
    %
    %   setUnits(tool,newUnits) sets the units of the position of tool to
    %   newUnits. See uipanel properties for possible unit strings.
    %
    %   setRange(tool,newRange) sets the display range to newRange.
    %
    %   changeSlice(tool,n) sets the current displayed slice.
    %
    %   h_P = getPanelHandle(tool) returns the handle to the uipanel
    %   containing the image and all the tools.
    %
    %   delete(tool) removes the imtool3D panel.
    %----------------------------------------------------------------------
    %Notes:
    %
    %   Author: Justin Solomon, March 9, 2013
    %
    %   Contact: justin.solomon@duke.edu
    %
    %   Current Version 1.0
    %   
    %   Created in MATLAB_R2012b
    %
    %   Requires the image processing toolbox
    %----------------------------------------------------------------------
    
    properties 
        I           %Image data
    end
    
    properties (SetAccess = private, GetAccess = private)
        h_P         %Handle of the uipanel that contains everything (image, tools, etc...)
        h_IP        %Handle of the uipanel that contains the image axes
        h_A         %Handle of the axes containing the image
        h_I         %Handle of the image object
        h_SP        %Handle of the imscrollpanel object
        h_mag       %Handle of the immagbox object
        h_slider    %Handle of the uislider used to scroll through slices
        h_pinfo     %Handle of the impixelinfoval object
        h_fit       %Handle of the uibutton object to set the zoom to fit
        h_zoomout   %Handle of the uibutton object that zooms out by 10%
        h_zoomin    %Handle of the uibutton object that zooms in by 10%
        h_contrast  %Handle of the uibutton object that allows the user to control the contrast
        h_grid      %Handle of the uitogglebutton object that turns the grid on and off
        h_lines     %Handles of the grid line objects
        h_ROItext   %Handle of the static text field for ROI measurement info
        h_ROIs      %Handles of the ROI objects
        h_ellipse   %Handle of the uibutton object that makes a circular ROI
        h_rect      %Handle of the uibutton object that makes a rectangular ROI
        h_poly      %Handle of the uibutton object that makes a polygon ROI
        h_delete    %Handle of the uibutton object that deletes the selected ROI
        h_distance  %Handle of the uibutton object that makes a distance tool
        h_profile   %Handle of the uibutton object that measures a line profile
        h_save      %Handle of the uibutton object that saves images
        h_save_pull %Handle of the pulldown menu that lets you choose options to save images
        
    end
    
    methods
        
        function tool = imtool3D(varargin)  %Constructor
            
            %--------------------------------------------------------------
            %Set the inputs
            
            switch nargin
                case 0  %tool = imtool3d()
                    I=random('unif',0,1,[100 100 10]);
                    position=[0 0 1 1]; h=gcf;
                    range=[min(I(:)) max(I(:))];
                case 1  %tool = imtool3d(I)
                    I=varargin{1}; position=[0 0 1 1]; h=gcf;
                    range=[min(I(:)) max(I(:))];
                case 2  %tool = imtool3d(I,position)
                    I=varargin{1}; position=varargin{2}; h=gcf;
                    range=[min(I(:)) max(I(:))];
                case 3  %tool = imtool3d(I,position,h)
                    I=varargin{1}; position=varargin{2}; h=varargin{3};
                    range=[min(I(:)) max(I(:))];
                case 4  %tool = imtool3d(I,position,h,range)
                    I=varargin{1}; position=varargin{2}; h=varargin{3};
                    range=varargin{4};
            end
            
            if isempty(I)
                I=random('unif',0,1,[100 100 10]);
            end
            
            if isempty(position)
                position=[0 0 1 1];
            end
            
            if isempty(h)
                h=gcf;
            end
            
            if isempty(range)
                range=[min(I(:)) max(I(:))];
            end
            
            %--------------------------------------------------------------
            %Set the properties of the class
            
            tool.h_P        = uipanel(h,'Position',position,'Title','');
            tool.h_IP       = uipanel(tool.h_P,'Position',[.05 .05 .9 .9],'Title',['Slice 1/' num2str(size(I,3))]);
            tool.h_A        = axes('Position',[0 0 1 1],'Parent',tool.h_IP);
            tool.h_I        = imshow(I(:,:,1),range);
            tool.h_SP       = imscrollpanel(tool.h_IP, tool.h_I); 
            tool.h_mag      = immagbox(tool.h_P,tool.h_I);
            tool.h_slider   = uicontrol(tool.h_P,'Style','Slider','Units','normalized','Position',[0 .05 .05 .9]);
            tool.h_pinfo    = impixelinfoval(tool.h_P,tool.h_I);
            tool.h_fit      = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_zoomout  = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_zoomin   = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_contrast = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_grid     = uicontrol(tool.h_P,'Style','togglebutton','String','#');
            tool.h_ROItext  = uicontrol(tool.h_P,'Style','text','String','AV:    STD:    MIN:    MAX:   SIZE:    ','HorizontalAlignment','left');
            tool.h_ROIs     = {};
            tool.h_ellipse  = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_rect     = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_poly     = uicontrol(tool.h_P,'Style','pushbutton','String','\_/','ForegroundColor','b');
            tool.h_delete   = uicontrol(tool.h_P,'Style','pushbutton','String','X','ForegroundColor','r');
            tool.h_distance = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_profile  = uicontrol(tool.h_P,'Style','pushbutton','String','-----');
            tool.h_save     = uicontrol(tool.h_P,'Style','pushbutton','String','');
            tool.h_save_pull= uicontrol(tool.h_P,'Style','popupmenu','String',{'As Slice','As stack'});
            
            tool.I          = I;
            
            
            %--------------------------------------------------------------
            %Position all the elements
            
            %Get the directories of the icon images
            [iptdir, MATLABdir] = ipticondir;
            
            %Set the position of the mag box to the top right corner
            p_IP=get(tool.h_IP,'Position');
            set(tool.h_mag,'Units','normalized');
            p_mag=get(tool.h_mag,'Position');
            x=p_IP(1)+p_IP(3)-p_mag(3); y=p_IP(2)+p_IP(4);
            set(tool.h_mag,'Position',[x y p_mag(3) p_mag(4)]);
            
            %Set the position of the fit button
            p_fit=get(tool.h_fit,'Position');
            set(tool.h_fit,'Position',[p_fit(1) p_fit(2) p_fit(4) p_fit(4)])
            set(tool.h_fit,'Units','normalized');
            p_fit=get(tool.h_fit,'Position');
            p_mag=get(tool.h_mag,'Position');
            x=p_mag(1)-p_fit(3); y=p_mag(2);
            set(tool.h_fit,'Position',[x y p_fit(3) p_fit(4)]);
            icon_fit = makeToolbarIconFromPNG([iptdir '/overview_zoom_in.png']);
            set(tool.h_fit,'CData',icon_fit);
            
            %Set up the position of the zoomout button tool
            p_zoomout=get(tool.h_zoomout,'Position');
            set(tool.h_zoomout,'Position',[p_zoomout(1) p_zoomout(2) p_zoomout(4) p_zoomout(4)])
            set(tool.h_zoomout,'Units','normalized');
            p_zoomout=get(tool.h_zoomout,'Position');
            p_fit=get(tool.h_fit,'Position');
            x=p_fit(1)-p_zoomout(3); y=p_fit(2);
            set(tool.h_zoomout,'Position',[x y p_zoomout(3) p_zoomout(4)])
            icon_zoomout = makeToolbarIconFromPNG([MATLABdir '/tool_zoom_out.png']);
            set(tool.h_zoomout,'CData',icon_zoomout);
            
            %Set up the position of the zoomin button tool
            p_zoomin=get(tool.h_zoomin,'Position');
            set(tool.h_zoomin,'Position',[p_zoomin(1) p_zoomin(2) p_zoomin(4) p_zoomin(4)])
            set(tool.h_zoomin,'Units','normalized');
            p_zoomin=get(tool.h_zoomout,'Position');
            p_zoomout=get(tool.h_zoomout,'Position');
            x=p_zoomout(1)-p_zoomin(3); y=p_zoomout(2);
            set(tool.h_zoomin,'Position',[x y p_zoomin(3) p_zoomin(4)])
            icon_zoomin = makeToolbarIconFromPNG([MATLABdir '/tool_zoom_in.png']);
            set(tool.h_zoomin,'CData',icon_zoomin);
            
            %Set up the position and icon of the contrast button tool
            p_contrast=get(tool.h_contrast,'Position');
            set(tool.h_contrast,'Position',[p_contrast(1) p_contrast(2) p_contrast(4) p_contrast(4)])
            set(tool.h_contrast,'Units','normalized');
            p_contrast=get(tool.h_contrast,'Position');
            p_zoomin=get(tool.h_zoomin,'Position');
            x=p_zoomin(1)-p_contrast(3); y=p_zoomin(2);
            set(tool.h_contrast,'Position',[x y p_contrast(3) p_contrast(4)]);
            icon_contrast = makeToolbarIconFromPNG([iptdir '/tool_contrast.png']);
            set(tool.h_contrast,'CData',icon_contrast);
            
            %Set up the position and icon of the grid togglebutton
            p_grid=get(tool.h_grid,'Position');
            set(tool.h_grid,'Position',[p_grid(1) p_grid(2) p_grid(4) p_grid(4)])
            set(tool.h_grid,'Units','normalized');
            p_contrast=get(tool.h_contrast,'Position');
            p_grid=get(tool.h_grid,'Position');
            x=p_contrast(1)-p_grid(3); y=p_contrast(2);
            set(tool.h_grid,'Position',[x y p_grid(3) p_grid(4)])
            
            %set up the position of the text fields on the bottom
            set([tool.h_pinfo tool.h_ROItext],'Units','normalized');
            p_pinfo=get(tool.h_pinfo,'Position');
            set(tool.h_pinfo,'Position',[0 0 p_pinfo(3)/2 p_pinfo(4)]);
            p_ROItext=get(tool.h_ROItext,'Position');
            p_pinfo=get(tool.h_pinfo,'Position');
            x=p_pinfo(1)+p_pinfo(3); width=1-p_pinfo(3);
            set(tool.h_ROItext,'Position',[x 0 width p_pinfo(4)]);
            
            %Set the position of the ellipse ROI button
            p_ellipse=get(tool.h_ellipse,'Position');
            set(tool.h_ellipse,'Position',[p_ellipse(1) p_ellipse(2) p_ellipse(4) p_ellipse(4)])
            set(tool.h_ellipse,'Units','normalized');
            p_ellipse=get(tool.h_ellipse,'Position');
            p_IP=get(tool.h_IP,'Position');
            x=p_IP(1)+p_IP(3); y=p_IP(2)+p_IP(4)-p_ellipse(4);
            set(tool.h_ellipse,'Position',[x y p_ellipse(3) p_ellipse(4)])
            icon_ellipse = makeToolbarIconFromPNG([MATLABdir '/tool_shape_ellipse.png']);
            set(tool.h_ellipse,'CData',icon_ellipse);
            
            %Set the position of the rect ROI button
            p_rect=get(tool.h_rect,'Position');
            set(tool.h_rect,'Position',[p_rect(1) p_rect(2) p_rect(4) p_rect(4)])
            set(tool.h_rect,'Units','normalized');
            p_rect=get(tool.h_rect,'Position');
            p_ellipse=get(tool.h_ellipse,'Position');
            x=p_ellipse(1); y=p_ellipse(2)-p_rect(4);
            set(tool.h_rect,'Position',[x y p_rect(3) p_rect(4)])
            icon_rect = makeToolbarIconFromPNG([MATLABdir '/tool_shape_rectangle.png']);
            set(tool.h_rect,'CData',icon_rect);
            
            %Set the position of the polygon ROI button
            p_poly=get(tool.h_poly,'Position');
            set(tool.h_poly,'Position',[p_poly(1) p_poly(2) p_poly(4) p_poly(4)])
            set(tool.h_poly,'Units','normalized');
            p_poly=get(tool.h_poly,'Position');
            p_rect=get(tool.h_rect,'Position');
            x=p_rect(1); y=p_rect(2)-p_poly(4);
            set(tool.h_poly,'Position',[x y p_poly(3) p_poly(4)])
            
            %Set the position of the delete ROI button
            p_delete=get(tool.h_delete,'Position');
            set(tool.h_delete,'Position',[p_delete(1) p_delete(2) p_delete(4) p_delete(4)])
            set(tool.h_delete,'Units','normalized');
            p_delete=get(tool.h_delete,'Position');
            p_poly=get(tool.h_poly,'Position');
            x=p_poly(1); y=p_poly(2)-p_delete(4);
            set(tool.h_delete,'Position',[x y p_delete(3) p_delete(4)])
            
            %Set the position of the distance tool
            p_distance=get(tool.h_distance,'Position');
            set(tool.h_distance,'Position',[p_distance(1) p_distance(2) p_distance(4) p_distance(4)])
            set(tool.h_distance,'Units','normalized');
            p_distance=get(tool.h_distance,'Position');
            p_delete=get(tool.h_delete,'Position');
            x=p_delete(1); y=p_delete(2)-p_distance(4);
            set(tool.h_distance,'Position',[x y p_distance(3) p_distance(4)])
            icon_distance = makeToolbarIconFromPNG([MATLABdir '/tool_line.png']);
            set(tool.h_distance,'CData',icon_distance);
            
            %Set the position of the improfile tool
            p_profile=get(tool.h_profile,'Position');
            set(tool.h_profile,'Position',[p_profile(1) p_profile(2) p_profile(4) p_profile(4)])
            set(tool.h_profile,'Units','normalized');
            p_profile=get(tool.h_profile,'Position');
            p_distance=get(tool.h_distance,'Position');
            x=p_distance(1); y=p_distance(2)-p_profile(4);
            set(tool.h_profile,'Position',[x y p_profile(3) p_profile(4)])
            
            %Set up the position of the save button tool and pulldown menu
            p_save=get(tool.h_save,'Position');
            set(tool.h_save,'Position',[p_save(1) p_save(2) p_save(4) p_save(4)])
            set(tool.h_save,'Units','normalized');
            p_save=get(tool.h_save,'Position');
            p_IP=get(tool.h_IP,'Position');
            y=p_IP(2)+p_IP(4);
            set(tool.h_save,'Position',[p_IP(1) y p_save(3) p_save(4)])
            icon_save = makeToolbarIconFromPNG([MATLABdir '/file_save.png']);
            set(tool.h_save,'CData',icon_save);
            set(tool.h_save_pull,'Units','normalized');
            p_save_pull=get(tool.h_save_pull,'Position');
            p_save=get(tool.h_save,'Position');
            x=p_save(1)+p_save(3); y=p_save(2);
            set(tool.h_save_pull,'Position',[x y p_save_pull(3)*2 p_save_pull(4)]);
            
            %--------------------------------------------------------------
            %Set callback functions and hovertips
            
            
            %Set up the zoom to fit button
            f_fit=@(hobject,eventdata)zoomToFit(tool,hobject,eventdata);
            set(tool.h_fit,'Callback',f_fit);
            set(tool.h_fit,'TooltipString','Zoom To Fit')
            
            %Set up the zoomout button
            f_zoomout=@(hobject,eventdata)zoomOut(tool,hobject,eventdata);
            set(tool.h_zoomout,'Callback',f_zoomout);
            set(tool.h_zoomout,'TooltipString','Zoom Out')
            
            %Set up the zoomin button
            f_zoomin=@(hobject,eventdata)zoomIn(tool,hobject,eventdata);
            set(tool.h_zoomin,'Callback',f_zoomin);
            set(tool.h_zoomin,'TooltipString','Zoom In')
            
            %Set up the contrast button
            f_contrast=@(hobject,eventdata)showImContrast(tool,hobject,eventdata);
            set(tool.h_contrast,'Callback',f_contrast);
            set(tool.h_contrast,'TooltipString','Contrast Tool')
            
            %Set up the grid togglebutton
            f_grid=@(hobject,eventdata)switchGrid(tool,hobject,eventdata);
            set(tool.h_grid,'Callback',f_grid);
            set(tool.h_grid,'TooltipString','Grid Lines')
            
            %Set up the ellipse ROI button
            f_ellipse=@(hobject,eventdata)addEllipseROI(tool,hobject,eventdata);
            set(tool.h_ellipse,'Callback',f_ellipse);
            set(tool.h_ellipse,'TooltipString','Circular ROI')
            
            %Set up the rect ROI button
            f_rect=@(hobject,eventdata)addRectROI(tool,hobject,eventdata);
            set(tool.h_rect,'Callback',f_rect);
            set(tool.h_rect,'TooltipString','Rectangular ROI')
            
            %Set up the poly ROI button
            f_poly=@(hobject,eventdata)addPolyROI(tool,hobject,eventdata);
            set(tool.h_poly,'Callback',f_poly);
            set(tool.h_poly,'TooltipString','Polygon ROI')
            
            %Set up the delete ROI button
            f_delete=@(hobject,eventdata)deleteROI(tool,hobject,eventdata);
            set(tool.h_delete,'Callback',f_delete);
            set(tool.h_delete,'TooltipString','Delete ROI')
            
            %Set up the distance tool button
            f_distance=@(hobject,eventdata)makeDistanceTool(tool,hobject,eventdata);
            set(tool.h_distance,'Callback',f_distance);
            set(tool.h_distance,'TooltipString','Measure Distance')
            
            %Set up the profile tool button
            f_profile=@(hobject,eventdata)drawLineProfile(tool,hobject,eventdata);
            set(tool.h_profile,'Callback',f_profile);
            set(tool.h_profile,'TooltipString','Line Profile')
            
            %Set up the save button
            f_save=@(hobject,eventdata)saveImage(tool,hobject,eventdata);
            set(tool.h_save,'Callback',f_save);
            set(tool.h_save,'TooltipString','Save Image')
            
            %--------------------------------------------------------------
            %Prepare panel for display
            
            %Set the magnification to fit
            setMag(tool,0);
            set(tool.h_lines,'Visible','off');
            
        end
        
        function set.I(tool,I_new)
            
            tool.I=I_new;
            range=get(tool.h_A,'CLim');
            api = iptgetapi(tool.h_SP);
            api.replaceImage(I_new(:,:,1),'PreserveView',true);
            set(tool.h_A,'CLim',range);
            tool.h_lines=drawGridLines(tool);
            removeAllROIs(tool)
            setupSlider(tool)
            setSlice(tool)
            switchGrid(tool)
            
        end
        
        function setPosition(tool,newPosition)
            set(tool.h_P,'Position',newPosition)
        end
        
        function setUnits(tool,newUnits)
            set(tool.h_P,'Units',newUnits)
        end
        
        function h_P = getPanelHandle(tool)
            h_P=tool.h_P;
        end
        
        function changeSlice(tool,n)
            setSlice(tool,n)
        end
        
        function setRange(tool,range)
            set(tool.h_A,'CLim',range);
        end
        
        function delete(tool)
            if ishandle(tool.h_P)
                delete(tool.h_P);
            end
        end
        
    end
    
    methods (Access = private)
        
        function saveImage(varargin)
            tool=varargin{1};
            switch get(tool.h_save_pull,'value')
                case 1 %Save just the current slice
                    I=get(tool.h_I,'CData'); lims=get(tool.h_A,'CLim');
                    I=mat2gray(I,lims);
                    [FileName,PathName] = uiputfile({'*.bmp';'*.gif';'*.hdf'; ...
                        '*.jpg';'*.jp2';'*.pbm';'*.pcx';'*.pgm';'*.png'; ...
                        '*.pnm';'*.ppm';'*.ras';'*.tif';'*.xwd'},'Save Image');
                    
                    if FileName == 0
                    else
                        imwrite(I,[PathName FileName])
                    end
                case 2
                    I=tool.I; lims=get(tool.h_A,'CLim');
                    I=mat2gray(I,lims);
                    [FileName,PathName] = uiputfile({'*.tif'},'Save Image Stack');
                    if FileName == 0
                    else
                        for i=1:size(I,3)
                            imwrite(I(:,:,i), [PathName FileName], 'WriteMode', 'append',  'Compression','none');
                        end
                    end
            end
        end
        
        function removeAllROIs(tool)
            ROIs=tool.h_ROIs;
            for i=1:length(ROIs)
                if isvalid(ROIs{i})
                    delete(ROIs{i})
                end
            end
        end
        
        function setupSlider(tool)
            set(tool.h_slider,'min',1,'max',size(tool.I,3),'value',1)
            set(tool.h_slider,'SliderStep',[1/(size(tool.I,3)-1) 1/(size(tool.I,3)-1)])
            f_slider=@(hobject,eventdata)setSlice(tool,[],hobject,eventdata); 
            set(tool.h_slider,'Callback',f_slider);
        end
        
        function zoomToFit(varargin)
            
            tool=varargin{1};
            setMag(tool,0)
            
        end
        
        function zoomOut(varargin)
            tool=varargin{1};
            api = iptgetapi(tool.h_SP);
            mag = api.getMagnification();
            mag = mag-.1;
            if mag < .1
                mag=.1;
            end
            setMag(tool,mag)
            
        end
        
        function zoomIn(varargin)
            tool=varargin{1};
            api = iptgetapi(tool.h_SP);
            mag = api.getMagnification();
            mag = mag+.1;
            setMag(tool,mag)
            
        end
        
        function setSlice(varargin)
            
            if nargin == 1
                tool=varargin{1};
                n=round(get(tool.h_slider,'value'));
            elseif nargin==2
                tool=varargin{1};
                n=varargin{2};
            else
                tool=varargin{1};
                n=round(get(tool.h_slider,'value'));
            end
            
            if n < 1
                n=1;
            end
            
            if n > size(tool.I,3)
                n=size(tool.I,3);
            end
            
            set(tool.h_slider,'value',n)
            set(tool.h_IP,'Title',['Slice ' num2str(n) '/' num2str(size(tool.I,3))])
            set(tool.h_I,'CData',tool.I(:,:,n))
            
            ROIs=tool.h_ROIs;
            for i=1:length(ROIs)
                if isvalid(ROIs{i})
                    if isequal(getColor(ROIs{i}),[1 0 0])
                        setPosition(ROIs{i},getPosition(ROIs{i}))
                    end
                end
            end
                
            
        end
        
        function setMag(tool,mag)
            
            api = iptgetapi(tool.h_SP);
            
            if mag <= 0 
                mag = api.findFitMag();
            end
            
            api.setMagnification(mag)
            
        end
        
        function showImContrast(varargin)
            
            tool=varargin{1};
            imcontrast(tool.h_I)
            
        end
        
        function makeDistanceTool(varargin)
            tool=varargin{1};
            h = imdistline(tool.h_A);
            fcn = makeConstrainToRectFcn('imline',[1 size(tool.I,2)],[1 size(tool.I,1)]);
            tool.h_ROIs{end+1}=h;
            setPositionConstraintFcn(h,fcn);
        end
        
        function drawLineProfile(varargin)
            tool=varargin{1};
            axes(tool.h_A);
            improfile(); grid on;
            
        end
        
        function h_lines = drawGridLines(tool)
            
            if ~(isempty(tool.h_lines))
                delete(tool.h_lines)
            end
            axes(tool.h_A);
            [nx ny nz]=size(tool.I);
            cx=nx/2;
            cy=ny/2;
            
            h_lines(1)=line([1 nx],[cy cy],'Color','r','LineWidth',2);
            h_lines(2)=line([cx cx],[1 ny],'Color','r','LineWidth',2);
            h_lines(3)=line([1 nx],[1 1],'Color','r','LineWidth',2);
            h_lines(4)=line([1 nx],[ny ny],'Color','r','LineWidth',2);
            h_lines(5)=line([1 1],[1 ny],'Color','r','LineWidth',2);
            h_lines(6)=line([nx nx],[1 ny],'Color','r','LineWidth',2);
            
            spacing=20; 
            
            horz1=cy-spacing/2:-spacing:0; horz2=cy+spacing/2:spacing:size(tool.I,1); horz=[horz1 horz2];
            verts1=cx-spacing/2:-spacing:0; verts2=cx+spacing/2:spacing:size(tool.I,2); verts=[horz1 horz2];
            
            for Y=horz
                h_lines(end+1)=line([0 size(tool.I,2)],[Y Y],'Color','r','LineWidth',1);
            end
            
            for X=verts
                h_lines(end+1)=line([X X],[0 size(tool.I,1)],'Color','r','LineWidth',1);
            end
            
            
            
        end
        
        function switchGrid(varargin)
            tool=varargin{1};
            if get(tool.h_grid,'Value')
                set(tool.h_lines,'Visible','on');
            else
                set(tool.h_lines,'Visible','off');
            end
            
        end
                
        function addEllipseROI(varargin)
            tool=varargin{1};
            addNewROI(tool,'Ellipse')
        end
        
        function addRectROI(varargin)
            tool=varargin{1};
            addNewROI(tool,'Rect')
        end
        
        function addPolyROI(varargin)
            tool=varargin{1};
            addNewROI(tool,'Poly')
        end
        
        function deleteROI(varargin)
            tool=varargin{1};
            ROIs=tool.h_ROIs;
            
            valid=zeros(size(ROIs));
            for i=1:length(ROIs)
                if isvalid(ROIs{i}) && ~(isa(ROIs{i},'imdistline'))
                    valid(i)=1;
                    if isequal(getColor(ROIs{i}),[1 0 0])
                        nDelete=i;
                    end
                end
            end
            
            if sum(valid)>0
                delete(ROIs{nDelete})
                if sum(valid)>1
                    ind=find(valid, 2, 'first');
                    if ind(1) ~= nDelete
                        setPosition(ROIs{ind(1)},getPosition(ROIs{ind(1)}))
                    else
                        setPosition(ROIs{ind(2)},getPosition(ROIs{ind(2)}))
                    end
                else
                    set(tool.h_ROItext,'String','AV:    STD:    MIN:    MAX:   SIZE:    ');
                end
                
            end
            
            
        end
        
        function addNewROI(tool,type)
            switch type
                case 'Ellipse'
                    fcn = makeConstrainToRectFcn('imellipse',[1 size(tool.I,2)],[1 size(tool.I,1)]);
                    h = imellipse(tool.h_A,'PositionConstraintFcn',fcn);
                    tool.h_ROIs{end+1}=h; n=length(tool.h_ROIs);
                    fcn_pos=@(pos) newROIPos(tool,pos,n);
                    addNewPositionCallback(h,fcn_pos);
                    setPosition(h,getPosition(h))
                case 'Rect'
                    fcn = makeConstrainToRectFcn('imrect',[1 size(tool.I,2)],[1 size(tool.I,1)]);
                    h = imrect(tool.h_A,'PositionConstraintFcn',fcn);
                    tool.h_ROIs{end+1}=h; n=length(tool.h_ROIs);
                    fcn_pos=@(pos) newROIPos(tool,pos,n);
                    addNewPositionCallback(h,fcn_pos);
                    setPosition(h,getPosition(h))
                case 'Poly'
                    fcn = makeConstrainToRectFcn('impoly',[1 size(tool.I,2)],[1 size(tool.I,1)]);
                    h = impoly(tool.h_A,'PositionConstraintFcn',fcn);
                    tool.h_ROIs{end+1}=h; n=length(tool.h_ROIs);
                    fcn_pos=@(pos) newROIPos(tool,pos,n);
                    addNewPositionCallback(h,fcn_pos);
                    setPosition(h,getPosition(h))
                case 'Hand'
                    fcn = makeConstrainToRectFcn('impoly',[1 size(tool.I,2)],[1 size(tool.I,1)]);
                    h = imfreehand(tool.h_A,'PositionConstraintFcn',fcn);
                    tool.h_ROIs{end+1}=h; n=length(tool.h_ROIs);
                    fcn_pos=@(pos) newROIPos(tool,pos,n);
                    addNewPositionCallback(h,fcn_pos);
                    setPosition(h,getPosition(h))
            end
            
             
        end
        
        function newROIPos(tool,pos,nROI)
            
            ROIs=tool.h_ROIs;
            for i=1:length(ROIs)
                if isvalid(ROIs{i}) && ~(isa(ROIs{i},'imdistline'))
                    setColor(ROIs{i},'k')
                end
            end
            setColor(ROIs{nROI},'r');
            
             BW=createMask(ROIs{nROI});
             STATS = regionprops(BW, get(tool.h_I,'CData'),'MaxIntensity','MinIntensity','MeanIntensity','PixelValues','Area');
             set(tool.h_ROItext,'String',['AV:' num2str(STATS.MeanIntensity,2) ' STD:' num2str(std(STATS.PixelValues),2) ...
                 ' MIN:' num2str(STATS.MinIntensity,2) ' MAX:' num2str(STATS.MaxIntensity,2) ' Size:' num2str(STATS.Area)])

        end
    end
    
end

function icon = makeToolbarIconFromPNG(filename)
% makeToolbarIconFromPNG  Creates an icon with transparent
%   background from a PNG image.

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1.8.1 $  $Date: 2004/08/10 01:50:31 $

  % Read image and alpha channel if there is one.
  [icon,map,alpha] = imread(filename);

  % If there's an alpha channel, the transparent values are 0.  For an RGB
  % image the transparent pixels are [0, 0, 0].  Otherwise the background is
  % cyan for indexed images.
  if (ndims(icon) == 3) % RGB

    idx = 0;
    if ~isempty(alpha)
      mask = alpha == idx;
    else
      mask = icon==idx; 
    end
    
  else % indexed
    
    % Look through the colormap for the background color.
    for i=1:size(map,1)
      if all(map(i,:) == [0 1 1])
        idx = i;
        break;
      end
    end
    
    mask = icon==(idx-1); % Zero based.
    icon = ind2rgb(icon,map);
    
  end
  
  % Apply the mask.
  icon = im2double(icon);
  
  for p = 1:3
    
    tmp = icon(:,:,p);
    if ndims(mask)==3
        tmp(mask(:,:,p))=NaN;
    else
        tmp(mask) = NaN;
    end
    icon(:,:,p) = tmp;
    
  end

end