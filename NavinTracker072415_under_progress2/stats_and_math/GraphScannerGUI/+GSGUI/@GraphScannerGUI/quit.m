function quit(obj,varargin)
%QUIT function quits the program and before closing the figure checks
%whether there is a need for saving the current data.
    fh = obj.hMainFig;
    fileName = get(fh,'filename');
    if isempty(fileName)
        fileName = 'picture';
    end
    if ~isequal(get(findobj('tag','save'),'enable'),'off')
        saveFile = questdlg(['Save current ',fileName,...
                             ' before closing it?'],...
                             get(obj.hMainFig,'Name'),'Save',...
                             'Cancel','Quit','Quit');
        switch saveFile
            case 'Save'
                saveAs(obj,varargin);
            case 'Cancel'
                return
            case 'Quit'
                delete(fh)
        end
    else
        delete(fh)
        return
    end
end