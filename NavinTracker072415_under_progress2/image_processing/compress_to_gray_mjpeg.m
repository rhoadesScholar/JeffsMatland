function compress_to_gray_mjpeg(original_file, new_file_prefix, quality, startframe, endframe)
% compress_to_gray_mjpeg(original_file, new_file, quality, startframe, endframe)

if(nargin==0)
    disp('compress_to_gray_mjpeg(original_file, new_file_prefix, quality, startframe, endframe)')
    disp('Default: new_file_prefix = prefix of original_file, quality = 38, startframe = 1, endframe = total_number_of_frames')
    disp('new file saved as new_file_prefix.gray.avi')
    return;
end
 
movieObject = VideoReader(original_file);
FileInfo.NumFrames = movieObject.NumberOfFrames;
FileInfo.Height = movieObject.Height;
FileInfo.Width = movieObject.Width;

if(nargin < 2)
    new_file_prefix = '';
end

if(nargin < 3)
   quality = 38; 
end

if(nargin < 5)
    startframe = 1;
    endframe =  FileInfo.NumFrames;
end

if(isempty(new_file_prefix))
    [~, new_file_prefix] = fileparts(original_file);
    new_file_prefix = sprintf('%s.gray',new_file_prefix);
end

if(isempty(strfind(new_file_prefix,'.avi')))
    new_file = sprintf('%s.avi',new_file_prefix);
else
    new_file = new_file_prefix;
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    disp(new_file)
    eraseflag = input('exists ... are you sure you want to over-write? (y/n)','s');
    eraseflag = lower(eraseflag);
    if(eraseflag == 'y')
        rm(new_file);
    else
        return
    end
end

aviobj = VideoWriter(new_file,'Motion JPEG AVI');
aviobj.Quality = quality;
open(aviobj);

aviread_to_gray;

ctr=1; 
for(i=startframe:endframe)
    if(ctr==startframe || mod(ctr,180)==0 || i==endframe)
        disp(num2str([ctr i]))
    end
    
    F = aviread_to_gray(original_file, i,0);
    
    writeVideo(aviobj,F);
    
    ctr = ctr+1;
end


close(aviobj);

return;
end
