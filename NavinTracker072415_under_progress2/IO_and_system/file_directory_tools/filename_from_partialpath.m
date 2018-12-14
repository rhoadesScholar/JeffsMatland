function [filename, path] = filename_from_partialpath(partialpath)
% [filename, path] = filename_from_partialpath(partialpath)
% given a partial path, return the name of the file
% example filename = filename_from_partialpath('tempdir/blah.avi')
% filename = blah.avi

i=length(partialpath);
while(i>1 && partialpath(i)~='/' && partialpath(i)~='\')
    i=i-1;
end
if(partialpath(i)=='/' || partialpath(i)=='\')
    i=i+1;
end

filename = partialpath(i:end);
path = partialpath(1:i-1);
    
return;
end
