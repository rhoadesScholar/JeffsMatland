function outstats = custom_regionprops(varargin)
% wrapper for regionprops ... this version is used for OS's that we haven't
% made an bona fide optimized custom_regionprops

outstats = regionprops(varargin{1}, varargin{2:end});

return;
end
