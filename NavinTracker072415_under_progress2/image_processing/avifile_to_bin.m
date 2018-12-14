function avifile_to_bin(original_file, new_file, startframe, endframe, axis_limits)
% avifile_to_bin(original_file, new_file, startframe, endframe, [xmin xmax ymin ymax])


error('poor performance compared to mjpeg');

if(nargin==0)
    disp('avifile_to_bin(original_file, new_file, startframe, endframe, axis_limits)')
    return;
end

if(nargin<5)
    axis_limits=[]; % [xmin xmax ymin ymax]
end

FileInfo = moviefile_info(original_file);

if(nargin<4)
    startframe = 1;
    endframe =  FileInfo.NumFrames;
end

if(isempty(strfind(new_file,'bin')))
    new_file = sprintf('%s.bin',new_file);
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    rm(new_file);
end

tempfilename = sprintf('%s.bin',tempname);

fid = fopen(tempfilename, 'w');
fwrite(fid,[FileInfo.Height FileInfo.Width],'uint8');
fclose(fid);

ctr=1;
for(i=startframe:endframe)
    disp(num2str([ctr i]))
    
    if(mod(ctr,100)==0 || ctr==1)
        aviread_to_gray;
        aviread_to_gray(original_file, i:min((i+100),endframe));
    end
    F = aviread_to_gray(original_file, i);
    
    if(~isempty(axis_limits))
        F.cdata = F.cdata(axis_limits(3):axis_limits(4), axis_limits(1):axis_limits(2));
    end
    
    fid = fopen(tempfilename, 'a');
    fwrite(fid,F.cdata,'uint8');
    fclose(fid);
    
    ctr = ctr+1;
end

return

disp(sprintf('Saving %s to %s',tempfilename, new_file))
mv(tempfilename, new_file);

return;
end
