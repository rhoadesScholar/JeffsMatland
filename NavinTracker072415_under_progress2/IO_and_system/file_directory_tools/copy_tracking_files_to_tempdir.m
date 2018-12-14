function tempPathName = copy_tracking_files_to_tempdir(localpath, FilePrefix, pid)

if(~isempty(localpath))
    if(localpath(end)~=filesep)
        localpath = sprintf('%s%s',localpath,filsep);
    end
end

tempPathName = sprintf('%s%s.%d%s',tempdir, FilePrefix,pid,filesep);
mkdir(tempPathName);
sprintf('%s%s*',localpath, FilePrefix)
tempPathName
cp(sprintf('%s%s*',localpath, FilePrefix), tempPathName);
return;
end
