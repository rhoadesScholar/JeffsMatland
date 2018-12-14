function save_figure(gcf, path, prefix, suffix, rotateflag)
% save_figure(gcf, path, prefix, suffix, rotateflag)

if(nargin<1)
    disp('usage: save_figure(gcf, path, prefix, suffix, rotateflag)')
    return
end

% rotateflag = 1 --> rotate the pdf by 90deg
if(nargin<5)
    rotateflag = 0;
end

if(~isempty(path))
    if(path(length(path))~=filesep) % add filesep if not at the end of the path
        localpath = sprintf('%s%s',path, filesep);
    else
        localpath = sprintf('%s',path);
    end

    % we have a relative path; make it absolute to avoid saveas problems
    if(isempty(findstr('temp',localpath)) && isempty(findstr('Temp',localpath)))
        if(isempty(findstr(pwd,localpath)))
            localpath = sprintf('%s%s%s',pwd,filesep,localpath);
        end
    end
else
    localpath = sprintf('%s%s',pwd,filesep);
end

if(nargin>=4)
    fileprefix = sprintf('%s%s.%s',localpath, prefix, suffix);
    if(isempty(suffix))
        fileprefix = sprintf('%s%s',localpath, prefix);
    end
else
    fileprefix = sprintf('%s%s',localpath, prefix);
end



dummystring = sprintf('%s.fig',fileprefix);
saveas(gcf,dummystring,'fig');

dummystring = sprintf('%s.pdf',fileprefix);
save_pdf(gcf, dummystring, rotateflag);

clear('dummystring');
clear('localpath');

return;
