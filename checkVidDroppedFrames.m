vids = dir('*/*.avi');

for v = 1:length(vids)
    vid = VideoReader([vids(v).folder '/' vids(v).name]);
    fprintf('%s has %i frames. \n', vid.name, vid.NumberOfFrames);    
end