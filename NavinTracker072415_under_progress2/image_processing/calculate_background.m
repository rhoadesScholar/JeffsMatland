function bkgnd = calculate_background(MovieName, startFrame, endFrame, frameinterval)
% bkgnd = calculate_background(MovieName, startFrame, endFrame, frameinterval) 

FileInfo = moviefile_info(MovieName);

if(nargin<2)
    startFrame = 1;
    endFrame = FileInfo.NumFrames;
end

if(endFrame > FileInfo.NumFrames)
    endFrame = FileInfo.NumFrames;
end

[PathName, FilePrefix, ext] = fileparts(MovieName);
if(~isempty(PathName))
    bkgnd_filename = sprintf('%s%s%s.%d.%d.background.mat',PathName, filesep, FilePrefix, startFrame, endFrame);
else
    PathName = pwd;
    bkgnd_filename = sprintf('%s%s%s.%d.%d.background.mat',PathName,filesep, FilePrefix, startFrame, endFrame);
end

if(file_existence(bkgnd_filename)==1)
   load(bkgnd_filename);
   return;
end

def_flag = 0;
if(nargin<4)
    global Prefs;
    [Prefs, def_flag] = define_preferences(Prefs);
    frameinterval = max(1,round(Prefs.BackgroundCalcInterval*(endFrame - startFrame)/100));
end

Frames = unique([startFrame:frameinterval:endFrame endFrame]);

aviread_to_gray(MovieName,Frames);

cdatasum = zeros(FileInfo.Height,FileInfo.Width,'double');
k=0;
for(i=1:length(Frames))
    
    
    Mov = aviread_to_gray(MovieName,Frames(i));
    
    if(~isempty(Mov.cdata))
        k=k+1;
        cdatasum = cdatasum + double(Mov.cdata)/255;
        clear('Mov');
    end
    
end
cdataaverage = cdatasum./k;
bkgnd = uint8(round(cdataaverage*255));

save(bkgnd_filename, 'bkgnd');

clear('FileInfo');
clear('cdatasum');
clear('cdataaverage');

if(def_flag==1)
    clear('Prefs');
end

return;

end