function output_FileInfo = moviefile_info(MovieName, compression_type_flag)

persistent previous_Moviename;
persistent FileInfo;


if(isempty(previous_Moviename))
   previous_Moviename = '';
end

if(strcmp(previous_Moviename,MovieName))
    output_FileInfo = FileInfo;
    return;
end

if(isfunction('VideoReader'))
    movieObject = VideoReader(MovieName);
    
    FileInfo.NumFrames = movieObject.NumberOfFrames;
    FileInfo.Height = movieObject.Height;
    FileInfo.Width = movieObject.Width;
    FileInfo.VideoCompression = [];
    FileInfo.FrameRate = movieObject.FrameRate;
    
    if(nargin>1)
        if(isfunction('mmfileinfo'))
            info = mmfileinfo(MovieName);
            FileInfo.VideoCompression = info.Video.Format;
        end
    end
    
    % for custom .gray_compress.avi files in which each grayscale frame is stored in
    % a color slice of an mjpeg frame
    if(~isempty(strfind(MovieName,'.gray_compress.avi')))
        cdata = read(movieObject,FileInfo.NumFrames);
        
        FileInfo.NumFrames = FileInfo.NumFrames*3;
        
        mean_intensity = mean(matrix_to_vector(cdata(:,:,1)))/10;
        
        if(mean(matrix_to_vector(cdata(:,:,2))) < mean_intensity)
            FileInfo.NumFrames = FileInfo.NumFrames - 1;
        end
        if(mean(matrix_to_vector(cdata(:,:,3))) < mean_intensity)
            FileInfo.NumFrames = FileInfo.NumFrames - 1;
        end   
    end
    
    previous_Moviename = MovieName;
    output_FileInfo = FileInfo;
    
    return;
end


if(isfunction('mmreader'))
    movieObject = mmreader(MovieName);
    
    FileInfo.NumFrames = movieObject.NumberOfFrames;
    FileInfo.Height = movieObject.Height;
    FileInfo.Width = movieObject.Width;
    FileInfo.VideoCompression = [];
    
    if(nargin>1)
        if(isfunction('mmfileinfo'))
            info = mmfileinfo(MovieName);
            FileInfo.VideoCompression = info.Video.Format;
        else
            
            % I haven't figured out how to get the compression codec from mmreader
            
            FileInfo = aviinfo(MovieName,'Robust');
            FileInfo.VideoCompression = FileInfo.VideoFrameHeader.CompressionType;
        end
    end
    
    previous_Moviename = MovieName;
    output_FileInfo = FileInfo;
    
    return
end


FileInfo = aviinfo(MovieName,'Robust');
FileInfo.NumFrames = FileInfo.VideoStreamHeader.Length;
FileInfo.Height = FileInfo.VideoFrameHeader.Height;
FileInfo.Width = FileInfo.VideoFrameHeader.Width;
FileInfo.VideoCompression = FileInfo.VideoFrameHeader.CompressionType;

return;
end
