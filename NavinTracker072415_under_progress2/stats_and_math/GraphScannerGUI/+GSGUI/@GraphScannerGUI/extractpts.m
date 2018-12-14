function [x,y] = extractpts(handle)
%EXTRACTPTS Summary of this function goes here
    if ~ishandle(handle) || ~strcmp(get(handle,'type'),'axes')
        errordlg('extractpts function only accepts axes handle as a input argument',...
                 'extractpts:incorrectinputargument')
        return
    end
    fig = ancestor(handle,'figure');
    [pointerShape, pointerHotSpot] = GSGUI.GraphScannerGUI.createPointer;
    set(fig,'pointer','custom',...
        'pointershapecdata',pointerShape,...
        'pointershapehotspot',pointerHotSpot);
    x = [];
    y = [];
    markerSize = 9;
    h1 = line('parent',handle,...
              'xdata',[],...
              'ydata',[],...
              'visible','off',...
              'clipping','off',...
              'color','b',...
              'linestyle','none',...
              'marker','x',...
              'markersize',markerSize);
    h2 = line('parent',handle,...
              'xdata',[],...
              'ydata',[],...
              'visible','off',...
              'clipping','off',...
              'color','r',...
              'linestyle','none',...
              'marker','+',...
              'markersize',markerSize);     
    set(fig,'WindowButtonDownFcn',@wbdFcn);
    set(fig,'WindowKeyPressFcn',@kpFcn)
    try
        waitfor(h1,'userdata','complete')
    catch ME
        errordlg(ME.message,ME.identifier)
    end
    %----------------------------------------------------------------------
    function wbdFcn(varargin)
        if strcmp(get(fig,'selectiontype'),'normal')
            pt = get(handle,'currentpoint');
            x = [x;pt(1,1)];
            y = [y;pt(1,2)];
            set([h1 h2],'xdata',x,...
                        'ydata',y,...
                        'visible','on');
        elseif isequal(get(fig,'selectiontype'),'alt')
            if ishandle(h1)
                set(h1,'userdata','complete');
                delete(h1);
            end
            if ishandle(h2)
                delete(h2);
            end
            set(fig,'WindowButtonDownFcn','');
            set(fig,'WindowKeyPressFcn','');
            set(fig,'pointer','arrow');
        end
    end

    %----------------------------------------------------------------------
    function kpFcn(varargin)
        if ishandle(h1)
            set(h1,'userdata','complete');
            delete(h1);
        end
        if ishandle(h2) 
            delete(h2)
        end
        set(fig,'WindowButtonDownFcn','');
        set(fig,'WindowKeyPressFcn','');
        set(fig,'pointer','arrow');
    end
end

