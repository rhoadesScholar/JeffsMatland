function testMovieRead()

MovieNameWithPath = 'C:\Users\snyderb\devel\bargmann\Steve\20120405\102111_2_n2_1.avi';
fname = MovieNameWithPath;



vObj = VideoReader(fname);

nFrames = vObj.NumberOfFrames;
vidHeight = vObj.Height;
vidWidth = vObj.Width;
% display(nFrames);
startFrame = 15000;
nFrames = 30;
% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);

% Read one frame at a time.
% for k = 1 : nFrames
%     clear mov;
%     mov(k).cdata = read(vObj, k+startFrame);
% end

mov = read(vObj, [startFrame startFrame+nFrames]);
for k = 1 : nFrames
    cdata = mov(:,:,:,k);
% display(cdata(20));
end
% display(mov);

% info = imfinfo(fname);
% num_images = numel(info);
% for k = 1:num_images
%     A = imread(fname, k, 'Info', info);
%     % ... Do something with image A ...
% end

% MovieObj = VideoReader(MovieNameWithPath);
% MovieObj = mmreader(MovieNameWithPath);
% Mov.colormap=[];

% totalFrames = 20;
% entireMov = read(MovieObj,[1 totalFrames]);

% for TrackFrame = 1:Track.NumFrames
% for TrackFrame = 1:totalFrames
%     FrameNum = TrackFrame;%Track.Frames(TrackFrame);
%     Mov.cdata = read(MovieObj,FrameNum);
%     Mov.cdata = entireMov(FrameNum);
% end

% mov(1:totalFrames) = ...
%     struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
%            'colormap', []);

% Read one frame at a time.
% for k = 1 : nFrames
%     mov(k).cdata = read(xyloObj, k);
% end


return;




end

