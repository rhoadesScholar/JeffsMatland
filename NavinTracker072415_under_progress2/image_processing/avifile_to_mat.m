function avifile_to_mat(original_file, new_file, startframe, endframe, axis_limits)
% avifile_to_mat(original_file, new_file, startframe, endframe, [xmin xmax ymin ymax])

error('doesn''t work due to the way matfiles are appended ... too much overhead!')

if(nargin==0)
    disp('avifile_to_mat(original_file, new_file, startframe, endframe, axis_limits)')
    return;
end

if(nargin<5)
    axis_limits=[]; % [xmin xmax ymin ymax]
end

if(isempty(endframe))
    FileInfo = moviefile_info(original_file);
    startframe = 1;
    endframe =  FileInfo.NumFrames;
end

if(isempty(strfind(new_file,'mat')))
    new_file = sprintf('%s.mat',new_file);
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    rm(new_file);
end

tempfilename = sprintf('%s.mat',tempname);

save(tempfilename,'original_file','-v7.3');

% mObj = matfile(tempfilename,'Writable',true);
% aviread_to_gray;
% F = aviread_to_gray(original_file, 1);
%     if(~isempty(axis_limits))
%         F.cdata = F.cdata(axis_limits(3):axis_limits(4), axis_limits(1):axis_limits(2));
%     end
% mObj.frame = uint8(zeros(size(F.cdata,1), size(F.cdata,2), 2));


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
    
    % mObj.frame(1:size(F.cdata,1), 1:size(F.cdata,2), ctr) = F.cdata;
    
    eval(sprintf('frame_%d = F.cdata;',ctr));
    save(tempfilename,sprintf('frame_%d',ctr),'-append','-v7.3');
    clear(sprintf('frame_%d',ctr));
    
    ctr = ctr+1;
end

disp(sprintf('Saving %s to %s',tempfilename, new_file))
mv(tempfilename, new_file);

return;
end
