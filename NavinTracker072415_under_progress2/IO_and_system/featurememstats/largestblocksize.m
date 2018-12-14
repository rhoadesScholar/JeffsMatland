function blocksize = largestblocksize(unit, maxsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function blocksize = largestblocksize(unit, maxsize)
% unit is either { 'byte', 'kbyte', ['Mbyte'] }
% Find the largest block size
%
% WARNING: this function uses
% - feature memstates on PC
% - dichotomy search on other plateform (LONG!) because
%   there is no equivalent feature memestates
%
% Thus the behavior of the lagestblocksize is not the same.
% Help featurememstats for more details
%
% Author: Bruno Luong
%         b.luong@fogale.frm
% Last update: 21/Oct/2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Retreive unit
if nargin>=1 && ischar(unit)
    % Check validity of unit
    switch lower(unit)
        case {'b' 'byte' 'bytes'}
            unit = 1;
        case {'k' 'kb' 'kbyte' 'kbytes'}
            unit = 1024;
        case {'m' 'mb' 'mbyte' 'mbytes'}
            unit = 1024^2;
        otherwise
            error('featurememstats: incorrect unit %s', unit);
    end
else
    if nargin<1 || isempty(unit) || ~isnumeric(unit) || unit<=0
        unit = 1;
    end
end

if ispc % A PC
    
    info=featurememstats([], unit);
    
    if strcmp(computer,'PCWIN') %PCx32
        blocksize = info.LargestContiguousFreeBlocks.Block(1).size;
    else % strcmp(computer,'PCWIN64') %PCx64
        blocksize = info.LargestContiguousFreeBlocks.Block(2).size;
    end   
    
else % Other platform
    
    if nargin<2 || ~isnumeric(maxsize) || ...
       isempty(maxsize) || maxsize<1
        error('largestblocksize: incorrect maxsize');
    end
    
    % *** LONG ***
    % Try to allocate block at different sizes
    i1=1;
    i9=maxsize+1;
    while i9>i1+1 % Dichotomy search
        imid=round((i1+i9)/2);
        try
            temp = zeros(1,imid*unit,'uint8'); %#ok
            OK = 1;
        catch
            OK = 0;
        end
        clear temp;
        if OK
            i1=imid;
        else
            i9=imid;
        end
    end % of while loop
    
    blocksize=i1;
    
end % of if

end
