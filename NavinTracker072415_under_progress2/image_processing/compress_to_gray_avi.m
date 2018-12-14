function compress_to_gray_avi(original_file, new_file_prefix, quality, startframe, endframe)
% compress_to_gray_avi(original_file, new_file, startframe, endframe)

if(nargin==0)
    disp('compress_to_gray_avi(original_file, new_file, quality, startframe, endframe)')
    disp('Default: new_file_prefix = prefix of original_file, quality = 50, startframe = 1, endframe = total_number_of_frames')
    disp('new file saved as new_file_prefix.gray_compress.avi')
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
   quality = 75; 
end

if(nargin < 5)
    startframe = 1;
    endframe =  FileInfo.NumFrames;
end

if(isempty(new_file_prefix))
    [~, new_file_prefix] = fileparts(original_file);
end

if(isempty(strfind(new_file_prefix,'.gray_compress.avi')))
    new_file = sprintf('%s.gray_compress.avi',new_file_prefix);
else
    new_file = new_file_prefix;
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    rm(new_file);
end

% tempfilename = sprintf('%s.gray_compress.avi',tempname);


aviobj = VideoWriter(new_file,'Motion JPEG AVI');
aviobj.Quality = quality;
open(aviobj);

aviread_to_gray;
Mov = aviread_to_gray(original_file, startframe);
F.colormap = [];
F.cdata = uint8(zeros(size(Mov.cdata,1), size(Mov.cdata,2), 3));

ctr=1; sub_ctr = 0;
for(i=startframe:endframe)
    if(ctr==startframe || mod(ctr,180)==0 || i==endframe)
        disp(num2str([ctr i]))
    end
    
    Mov = aviread_to_gray(original_file, i);
    
    sub_ctr = sub_ctr + 1;
    F.cdata(:,:,sub_ctr) = Mov.cdata;
    
    if(sub_ctr == 3)
        writeVideo(aviobj,F);
        sub_ctr = 0;
        clear('F');
        F.colormap = [];
        F.cdata = uint8(zeros(size(Mov.cdata,1), size(Mov.cdata,2), 3));
    end
    
    ctr = ctr+1;
end

if(sub_ctr~=0)
    writeVideo(aviobj,F);
end

close(aviobj);

% disp(sprintf('Saving the compressed moviefile %s to %s',tempfilename, new_file))
% mv(tempfilename, new_file);

return;
end
