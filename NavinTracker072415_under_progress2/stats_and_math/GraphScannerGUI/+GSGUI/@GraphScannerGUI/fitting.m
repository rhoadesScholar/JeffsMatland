function fitting(obj,varargin)
%FITTING function enables user to fit a curve for a given data. 
%Function opens a new figure and plots current data specified in the 
%GUI. By using EzyFit package features you are able to fit a curve. 

    if ~isempty(obj.xDataHistory{get(obj.hCurveList,'userdata')})
        if numel(obj.xDataHistory{get(obj.hCurveList,'userdata')}) < 2
            helpdlg('There must be at least 2 points selected','Point Selection')
            return
        end
        try 
            evalin('base','efmenu;')
        catch ME
            errordlg(ME.message,ME.identifier)
            return
        end
        data = get(obj.hCurveDataTable,'data');
        xData = data(:,1);
        yData = data(:,2);
        limits = obj.coordinateHistory{get(obj.hCurveList,'userdata')}(1:3,1:2);
        xyScale = {}; 
        switch obj.scaleHistory{get(obj.hCurveList,'userdata')}(1)
            case 2
                xyScale{1} = 'log';
            otherwise
                xyScale{1} = 'linear';
        end
        switch obj.scaleHistory{get(obj.hCurveList,'userdata')}(2)
            case 2
                xyScale{2} = 'log';
            otherwise 
                xyScale{2} = 'linear';
        end
        xLimit = [limits(1,1) limits(2,1)];
        yLimit = [limits(1,2) limits(3,2)];
        if sign(diff(xLimit)) ~= 1 
            xLimit = fliplr(xLimit);
        elseif sign(diff(yLimit)) ~= 1
            yLimit = fliplr(yLimit);
        end
        fig = figure;
        h = line(xData,yData,...
                 'color','k',...
                 'marker','o',...
                 'linestyle','-');
        set(gca,'box','off',...
            'xlim',xLimit,...
            'ylim',yLimit,...
            'xscale',xyScale{1},...
            'yscale',xyScale{2},...
            'fontname','verdana');
        xlabel(obj.xAxisLabel,'fontname','verdana');
        ylabel(obj.yAxisLabel,'fontname','verdana');
        set(fig,'name','Fitting',...
                'numbertitle','off',...
                'CloseRequestFcn',@closeFittingFig);
    end
    
    %----------------------------------------------------------------------
    function closeFittingFig(varargin)
        try 
            if ishandle(varargin{1})
                delete(varargin{1})
                evalin('base','efmenu off;')
            end
        catch ME
            errordlg(ME.message,ME.identifier)
            return
        end
    end
end
 


