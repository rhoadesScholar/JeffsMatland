function save(obj,varargin)
%SAVE function saves current data.
    fileName = get(obj.hMainFig,'filename');
    if ~isempty(fileName)
        [fid,message] = fopen(fileName,'a+');
        if fid == -1
            errordlg(message,'Cannot open the file')
            return
        end
        str_1 = ['Curve info: ',obj.curveNames{get(obj.hCurveList,'userdata')}];
        str_2 = ['Time: ', datestr(now)];
        str_3 = '%-------------------------------------------%';
        str_4 = 'X-data';
        str_5 = 'Y-data';
        form='%10.6e ';
        data = get(obj.hCurveDataTable,'data');
        fprintf(fid,'%s\n%s\n%s\n',str_1,str_2,str_3);
        fprintf(fid,'%s (%s)\t\t%s (%s)\n',str_4,obj.xAxisLabel,str_5,obj.yAxisLabel);
        for k = 1:length(data(:,1))
            fprintf(fid,[form,'\t\t',form,'\n'],data(k,1),data(k,2));
        end
        fprintf(fid,'%s\n\n',str_3);
        ptr = fclose(fid);
        if ptr == -1
            errordlg('Error while closing the file!','File Error')
            return
        end
        obj.isGuiAlter = false;
        return
    else
        saveAs(obj,varargin)
    end
end