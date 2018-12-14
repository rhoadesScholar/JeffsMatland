function Mov = aviread_to_gray(inputMovieName, Frame, convertflag)
% Mov = aviread_to_gray(MovieName, Frame, convertflag)
% convertflag = 1 (default) returns grayscale in Mov.cdata

rgb_conv_coef = [0.2989    0.5870    0.1141];

global Prefs;
Prefs = define_preferences(Prefs);

persistent video_file_handle;
persistent previous_moviename;
persistent call_ctr;
persistent mov_array;
persistent framenum_vector;
persistent maxNumFrames;
persistent FileInfo;

Mov.colormap=[];

if(isempty(call_ctr))
    video_file_handle = [];
    previous_moviename = [];
    call_ctr = 0;
    mov_array = [];
    framenum_vector = [];
    FileInfo = [];
end

if(nargin<1) % || call_ctr > 100)
    video_file_handle = [];
    previous_moviename = [];
    call_ctr = 0;
    mov_array = [];
    framenum_vector = [];
    FileInfo = [];
end

if(nargin<1)
    Mov.cdata=[];
    return;
end



if(strcmp(inputMovieName,'rm_temp'))
    rm(sprintf('%s*.%d.avi',tempdir, Prefs.PID));
    
    % for a special WormPlayer case
    if(~isempty(strfind(previous_moviename,'temp_background.mat')))
        rm(previous_moviename);
    end
    
    aviread_to_gray;
    return;
end

% for a special WormPlayer case
if(~isempty(strfind(inputMovieName,'temp_background.mat')))
    if(isempty(mov_array))
        previous_moviename = inputMovieName;
        load(inputMovieName);
        cdata(:,:,1) = background;
        cdata(:,:,2) = background;
        cdata(:,:,3) = background;
        mov_array{1} = cdata;
        clear('cdata');
        clear('background');
    end
    Mov.cdata = mov_array{1};
    return;
end

% inputMovieName does not exist ... 
% perhaps the wrong path is given  
% see if the file exists in the current directory
if(~file_existence(inputMovieName))
    [pathstr, pref, ext] = fileparts(inputMovieName);
    inputMovieName = sprintf('%s%s',pref,ext);
    if(~file_existence(inputMovieName))
        error(sprintf('Cannot find %s in the current directory',inputMovieName));
    end
    disp([sprintf('Could not find %s in directory %s but found it in the current directory %s',inputMovieName,pathstr,pwd)])
end

MovieName = inputMovieName;
if(~islocaldir(inputMovieName)) % not a local file so copy to temp or use local temp copy
    [a,fileprefix] = fileparts(inputMovieName);
    MovieName = sprintf('%s%s.%d.avi',tempdir, fileprefix, Prefs.PID);
    if(~(file_existence(MovieName)))
        disp([sprintf('Copying %s to %s for faster access\t%s',inputMovieName, MovieName, timeString)]);
        cp(inputMovieName, MovieName);
    end
end

compressed_gray_flag = 0;
if(~isempty(strfind(MovieName,'.gray_compress.avi')))
    compressed_gray_flag = 1;
end

if(nargin<2)
    FileInfo = moviefile_info(MovieName);
    
%     movieObject = VideoReader(MovieName);
%     FileInfo.NumFrames = movieObject.NumberOfFrames;
%     FileInfo.Height = movieObject.Height;
%     FileInfo.Width = movieObject.Width;
    
    Frame = 1:FileInfo.NumFrames;
end

if(nargin<3)
    convertflag = 1;
else
    if(ischar(convertflag)) % delete Frame from the stored cache
        idx = find(framenum_vector == Frame);
        mov_array(idx) = [];
        framenum_vector(idx) = [];
        return;
    end
end



if(isempty(previous_moviename))
    previous_moviename = '';
end

if(~strcmp(MovieName,previous_moviename)) % new moviename, so read in new handle
    previous_moviename = MovieName;
    mov_array = [];
    framenum_vector = [];
    
    FileInfo = moviefile_info(MovieName);
    
%     movieObject = VideoReader(MovieName);
%     FileInfo.NumFrames = movieObject.NumberOfFrames;
%     FileInfo.Height = movieObject.Height;
%     FileInfo.Width = movieObject.Width;
    
    mem = custom_memory;
    maxNumFrames = floor(mem.PhysicalMemory.Available/(FileInfo.Height*FileInfo.Width))-100;
    maxNumFrames = floor(maxNumFrames/3);
    
    if(isfunction('VideoReader'))  % use VideoReader if it exists
        video_file_handle = VideoReader(MovieName);
    else
        if(isfunction('mmreader')) % or mmreader
            video_file_handle = mmreader(MovieName);
        end
    end
    
    
end

if(length(Frame)>1 && maxNumFrames<=10)
    mem = custom_memory;
    maxNumFrames = floor(mem.PhysicalMemory.Available/(FileInfo.Height*FileInfo.Width))-100;
    maxNumFrames = floor(maxNumFrames/3);
    
    Mov = aviread_to_gray(inputMovieName, Frame(1), convertflag);
    return;
end

if(length(Frame)>1 && maxNumFrames>10)
    mem = custom_memory;
    maxNumFrames = floor(mem.PhysicalMemory.Available/(FileInfo.Height*FileInfo.Width))-100;
    maxNumFrames = floor(maxNumFrames/3);

    del_idx=[];
    for(i=1:length(Frame))
       if(Frame(i)>FileInfo.NumFrames)
           del_idx = [del_idx i];
       end
    end
    Frame(del_idx) = [];
    
    new_frame_vector = Frame;
    call_ctr = call_ctr + 1;
    
    % need to remove some frames from memory before loading more
    if(length(new_frame_vector) + length(framenum_vector) >= maxNumFrames)
        if(length(framenum_vector)==0) % no frames in memory don't load so many frames
            frames_to_del = length(new_frame_vector) - maxNumFrames;
            new_frame_vector(max(1,(end-frames_to_del)):end) = [];
        else % already have some frames in memory
            % what new frames do we need to load?
            i=1; not_del_idx = [];
            while(i<=length(new_frame_vector))
                idx = find(framenum_vector == new_frame_vector(i));
                if(~isempty(idx))
                    new_frame_vector(i) = [];
                    not_del_idx = [not_del_idx idx];
                else
                    i=i+1;
                end
            end
            if(length(new_frame_vector) + length(framenum_vector) >= maxNumFrames) % still a problem so free memory
                i=1;
                while(i<=length(framenum_vector))
                    if(isempty(find(not_del_idx==framenum_vector(i))))
                        framenum_vector(i) = [];
                        mov_array(i) = [];
                    else
                        i=i+1;
                    end
                end
            end
            if(length(new_frame_vector) + length(framenum_vector) >= maxNumFrames) % still a problem so load fewer frames
                frames_to_del = (length(new_frame_vector) +  length(framenum_vector)) - maxNumFrames;
                new_frame_vector(max(1,(end-frames_to_del)):end) = [];
            end
        end
    end
    
    
    % what new frames do we need to load?
    i=1;
    while(i<=length(new_frame_vector))
        if(~isempty(find(framenum_vector == new_frame_vector(i))))
            new_frame_vector(i) = [];
        else
            i=i+1;
        end
    end
    
    if(~isempty(new_frame_vector))
        % load the new frames needed
        k = length(framenum_vector) + 1;
        
        % non-contigious frames
        if(~isempty(find(diff(new_frame_vector)>1)))
            i=1;
            while(i<=length(new_frame_vector))
                f = new_frame_vector(i);
                framenum_vector = [framenum_vector f];
                
                %         % a crude fix for the videoreader bug
                %         if(FileInfo.NumFrames - Frame < 100)
                %             cdata = read (video_file_handle,1);
                %         end
                
                if(compressed_gray_flag == 1)
                    [actual_grayframe, slice] = get_actual_grayframe(f);
                    local_cdata = read(video_file_handle, actual_grayframe);
                    cdata = local_cdata(:,:,slice);
                    mov_array{k} = cdata;
                    mean_intensity = mean(matrix_to_vector(cdata))/10;
                    
                    other_slices_idx = [1 2 3];
                    other_frames = [(actual_grayframe*3-2) (actual_grayframe*3-1) (actual_grayframe*3)];
                    other_slices_idx(slice) = [];
                    other_frames(slice) = [];
                    
                    for(tt = 1:2)
                        other_slice = other_slices_idx(tt);
                        if(~(mean(matrix_to_vector(local_cdata(:,:,other_slice))) < mean_intensity))
                            framenum_vector = [framenum_vector other_frames(tt)];
                            cdata = local_cdata(:,:,other_slice);
                            k=k+1;
                            mov_array{k} = cdata;
                            
                            new_frame_vector(find(new_frame_vector == other_frames(tt))) = [];
                        end
                    end
                    clear('local_cdata');
                else
                    cdata = read(video_file_handle,f);
                    if(strcmp(video_file_handle.VideoFormat, 'Grayscale')==1)
                        %then it is already a single matrix
                        mov_array{k} = cdata;
                    else
                        mov_array{k} = rgb_conv_coef(1)*cdata(:,:,1) + rgb_conv_coef(2)*cdata(:,:,2) + rgb_conv_coef(3)*cdata(:,:,3);
                    end
%                     mov_array{k} = rgb_conv_coef(1)*cdata(:,:,1) + rgb_conv_coef(2)*cdata(:,:,2) + rgb_conv_coef(3)*cdata(:,:,3);
                end
                
                clear('cdata');
                k=k+1;
                
                i=i+1;
            end
        else % contigious frames so faster to load in a block
            
            
            if(compressed_gray_flag == 1)
                for(q=1:length(new_frame_vector))
                    aviread_to_gray(inputMovieName, new_frame_vector(q), convertflag);
                end
                Mov = aviread_to_gray(inputMovieName, Frame(1), convertflag);
                return;
            else
                cdata = read(video_file_handle,[new_frame_vector(1) new_frame_vector(end)]);
            end
            
            new_frame_vector = new_frame_vector(1:size(cdata,4));
            
            for(i=1:length(new_frame_vector))
                f = new_frame_vector(i);
                framenum_vector = [framenum_vector f];
            end
            
            for(i=1:length(new_frame_vector))
                mov_array{k} = rgb_conv_coef(1)*cdata(:,:,1,i) + rgb_conv_coef(2)*cdata(:,:,2,i) + rgb_conv_coef(3)*cdata(:,:,3,i);
                k=k+1;
            end
            clear('cdata');
        end
    end
    % framenum_vector
    
    Mov = aviread_to_gray(inputMovieName, Frame(1), convertflag);
    return;
end

if(~isempty(mov_array))
    idx = find(framenum_vector == Frame);
    if(~isempty(idx)) % frame already loaded
        if(convertflag==1)
            Mov.cdata = mov_array{idx}; % mov_array(idx).cdata;
        else
            Mov.cdata(:,:,1) = mov_array{idx}; % mov_array(idx).cdata;
            Mov.cdata(:,:,2) = mov_array{idx}; % mov_array(idx).cdata;
            Mov.cdata(:,:,3) = mov_array{idx}; % mov_array(idx).cdata;
        end
        return;
    end
end

if(~isempty(video_file_handle))
    call_ctr = call_ctr + 1;
    
    %     % a crude fix for the videoreader bug
    %     if(FileInfo.NumFrames - Frame < 100)
    %         cdata = read (video_file_handle,1);
    %     end
    
    if(compressed_gray_flag == 1)
        [actual_grayframe, slice] = get_actual_grayframe(Frame);
        local_cdata = read(video_file_handle, actual_grayframe);
        cdata = local_cdata(:,:,slice);
        if(convertflag==1)
            Mov.cdata = cdata;
        else
            Mov.cdata(:,:,1) = cdata;
            Mov.cdata(:,:,2) = cdata;
            Mov.cdata(:,:,3) = cdata;
        end
        
        if(~isempty(mov_array))
            mean_intensity = mean(matrix_to_vector(cdata))/10;
            other_frames = [(actual_grayframe*3-2) (actual_grayframe*3-1) (actual_grayframe*3)];
            
            k = length(framenum_vector);
            
            for(tt = 1:3)
                if(~(mean(matrix_to_vector(local_cdata(:,:,tt))) < mean_intensity))
                    framenum_vector = [framenum_vector other_frames(tt)];
                    cdata = local_cdata(:,:,tt);
                    k=k+1;
                    mov_array{k} = cdata;
                end
            end
        end
        clear('local_cdata');
        clear('cdata');
        return;
    else
        local_cdata = read(video_file_handle,Frame);
        if(strcmp(video_file_handle.VideoFormat, 'Grayscale')==1)
            %then it is already a single matrix
            cdata = local_cdata;
        else
            cdata = rgb_conv_coef(1)*local_cdata(:,:,1) + rgb_conv_coef(2)*local_cdata(:,:,2) + rgb_conv_coef(3)*local_cdata(:,:,3);
        end
%         cdata = rgb_conv_coef(1)*local_cdata(:,:,1) + rgb_conv_coef(2)*local_cdata(:,:,2) + rgb_conv_coef(3)*local_cdata(:,:,3);
    end
    
    if(convertflag==1)
        Mov.cdata = cdata;
    else
        Mov.cdata = local_cdata;
    end
    if(~isempty(mov_array))
        k = length(framenum_vector) + 1;
        framenum_vector = [framenum_vector Frame];
        mov_array{k} = cdata;
    end
    clear('cdata');
    return;
end


% if mmreader or VideoReader not available use dxAvi functions for XVID files
file_info = moviefile_info(MovieName,'compressiontype');
if(strcmp(file_info.VideoCompression,'XVID')==1)
    [avi_hdl, avi_inf] = dxAviOpen(MovieName);
    num_elements = avi_inf.Width*avi_inf.Height*3;
    
    temp_mov = dxAviReadMex(avi_hdl,Frame);
    
    if(~isempty(temp_mov))
        
        temp_mov2 = uint8(zeros(avi_inf.Width,avi_inf.Height,3));
        temp_mov2(1:num_elements) = temp_mov(1:num_elements);
        
        if(convertflag==1)
            Mov.cdata = rgb2gray(temp_mov2);
        else
            Mov.cdata =  temp_mov2;
        end
    end
    
    dxAviCloseMex(avi_hdl);
    
    clear('temp_mov');
    clear('temp_mov2');
    clear('avi_hdl');
    clear('avi_inf');
    
    return;
end

% use aviread for non-XVID files if mmreader is not available
temp_mov = aviread(MovieName,Frame);
if(convertflag==1)
    Mov.cdata = rgb2gray(temp_mov.cdata);
else
    Mov.cdata = temp_mov.cdata;
end
clear('temp_mov');
return;

end




