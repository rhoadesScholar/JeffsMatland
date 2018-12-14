function summary_image = calculate_summary_image(MovieName, startFrame, endFrame, frameinterval)
% summary_image = calculate_summary_image(MovieName, startFrame, endFrame, frameinterval) 

if(file_existence(MovieName)==0)
    error(sprintf('Cannot find %s for calculate_summary_image',MovieName));
end

FileInfo = moviefile_info(MovieName);

if(nargin<2)
    startFrame = 1;
    endFrame = FileInfo.NumFrames;
end

if(endFrame > FileInfo.NumFrames)
    endFrame = FileInfo.NumFrames;
end

if(nargin<4)
    global Prefs;
    frameinterval = round(Prefs.BackgroundCalcInterval*(endFrame - startFrame)/100);
end

[PathName, FilePrefix, ext] = fileparts(MovieName);

if(~isempty(PathName))
    bkgnd_filename = sprintf('%s%s%s.%d.%d.background.mat',PathName, filesep, FilePrefix, startFrame, endFrame);
    summary_image_filename = sprintf('%s%s%s.%d.%d.summary_image.mat',PathName, filesep, FilePrefix, startFrame, endFrame);
else
    PathName = pwd;
    bkgnd_filename = sprintf('%s%s%s.%d.%d.background.mat',PathName,filesep, FilePrefix, startFrame, endFrame);
    summary_image_filename = sprintf('%s%s%s.%d.%d.summary_image.mat',PathName,filesep, FilePrefix, startFrame, endFrame);
end

if(file_existence(summary_image_filename)==1)
   load(summary_image_filename);
   return;
end

if(file_existence(bkgnd_filename)==1)
    load(bkgnd_filename);
else
    bkgnd = calculate_background(MovieName, startFrame, endFrame, frameinterval);
end

tempMovieName = sprintf('%s.avi',tempname);
if(isempty(regexp(MovieName,'Temp')))
    cp(MovieName,tempMovieName);
    MovieName = tempMovieName;
end


cdatasum = zeros(FileInfo.Height,FileInfo.Width,'double');
for (Frame = startFrame:frameinterval:endFrame)
    
    Mov = aviread_to_gray(MovieName,Frame);
    
    if(~isempty(Mov.cdata))
        cdatasum = cdatasum + (double(imsubtract(Mov.cdata, bkgnd)))/255;
    end
    clear('Mov');
    
end
summary_image = bkgnd - uint8(round(cdatasum*255));

save(summary_image_filename, 'summary_image');

clear('FileInfo');
clear('cdatasum');

rm(tempMovieName);

return;
end
