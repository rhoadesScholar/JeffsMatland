function movieframe_to_imagefile(moviename, frame_number, image_file_format, imagefile_prefix)
% movieframe_to_imagefile(moviename, frame_number, image_file_format, imagefile_prefix)

if(nargin==0)
   disp([sprintf('%s\n%s','usage: movieframe_to_imagefile(moviename, frame_number, image_file_format, imagefile_prefix)', ...
                 'default image_file_format = ''jpg'', default imagefile_prefix = ''moviename_prefix.framenumber.image_file_format''')])
   return
end

if(nargin<3)
    image_file_format = 'jpg';
end

if(nargin<4)
    [pathstr, imagefile_prefix, ext] = fileparts(moviename);
end

fr = aviread_to_gray(moviename,frame_number);

imwrite(fr.cdata, sprintf('%s.%d.%s',imagefile_prefix,frame_number,image_file_format), image_file_format)

return;
end
