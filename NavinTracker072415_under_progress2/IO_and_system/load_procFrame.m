function procFrame = load_procFrame(filename)

if(file_existence(filename)==0)
    disp([sprintf('%s does not exist',filename)])
    procFrame = [];
    return;
end

load(filename);
pause(30);

if(~exist('procFrame', 'var'))
    procFrame = [];
    disp([sprintf('%s failed to load %s',filename, timeString)])
    return;
end

% is a compressed procFrame, so uncompress
if(isfield(procFrame(1),'scalars'))
    procFrame = compress_decompress_procFrame(procFrame);
end

return;
end
