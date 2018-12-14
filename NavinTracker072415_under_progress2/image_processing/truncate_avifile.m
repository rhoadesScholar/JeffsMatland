function truncate_avifile(original_file, new_file, startframe, endframe, axis_limits, actually_trim_flag)
% truncate_avifile(original_file, new_file, startframe, endframe, [xmin xmax ymin ymax], actually_trim_flag)
% actually_trim_flag = 1 default trims to axis_limits; otherwise, draws a
% red box around the axis limits

if(nargin==0)
    disp('truncate_avifile(original_file, new_file, startframe, endframe, axis_limits, actually_trim_flag)')
    return;
end

if(nargin<5)
    axis_limits=[]; % [xmin xmax ymin ymax]
end

if(nargin<6)
    actually_trim_flag=1;
end

FileInfo = moviefile_info(original_file);
if(nargin < 4)
    startframe = 1;
    endframe =  FileInfo.NumFrames;
end

if(isempty(strfind(new_file,'avi')))
    new_file = sprintf('%s.avi',new_file);
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    rm(new_file);
end

tempfilename = sprintf('%s.avi',tempname);

aviobj = VideoWriter(tempfilename); % ,'Motion JPEG AVI');
aviobj.Quality = 100;
open(aviobj);

aviread_to_gray;
ctr=1;
for(i=startframe:endframe)
    disp(num2str([ctr i]))
    
%     if(mod(ctr,100)==0 || ctr==1)
%         aviread_to_gray;
%         aviread_to_gray(original_file, i:min((i+100),endframe), 0);
%     end
    F = aviread_to_gray(original_file, i, 0);
    
    if(actually_trim_flag==1)
        if(~isempty(axis_limits))
            F.cdata = F.cdata(axis_limits(3):axis_limits(4), axis_limits(1):axis_limits(2),  :);
        end
    else
        if(~isempty(axis_limits))
            fig = figure(1);
            imshow(F.cdata,'Border','tight');
            hold on;
            plot([axis_limits(1) axis_limits(1)  axis_limits(2) axis_limits(2) axis_limits(1)],[axis_limits(3) axis_limits(4) axis_limits(4) axis_limits(3) axis_limits(3)],'r');
            hold off;
            F = getframe(fig);
            close(fig);
        end
    end
    
    
    
    writeVideo(aviobj,F);
    ctr = ctr+1;
    
    
    
end

close(aviobj);

disp(sprintf('Saving the truncated moviefile %s to %s',tempfilename, new_file))
mv(tempfilename, new_file);

return;
end
