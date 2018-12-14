function varargout = getparam(param, paramlist, n, varargin)
% getparam  Get values for a parameter in a parameter list
%
%   processes standard 'param1', value1, 'param2', value2 lists, as well as those having arbitrary
%       number of values following a parameter: 'param1', value1a, value1b, value1c, 'param2',...
%
%   [a1, ... an] = getparam(param, paramlist, [n], [defaults])
%
%       param       parameter name
%       paramlist   cell array, an element for each arg (typically use varargin)
%       n          optional, number of values to capture following this param, defaults to 1
%       defaults   optional, n default value(s), comma separated, returned if param not found
%                       if defaults unspecified, returns empty matrices
%
%       a1, ... an  return values for param, must be n of them
%
%
%   See also ISPARAM, STRMATCH_MIXED.
%

%
%   jri 10/18/02
%

% Free for all uses, but please retain the following:
%   Original Author: John Iversen
%   john_iversen@post.harvard.edu

if nargin < 3,
    n = 1;
end

%try to find parameter name in the parameter list
[gotit, idx] = isparam(param,paramlist);

if gotit,
    %if specified more than once, warn, take the last instance
    if length(idx) > 1,
        idx = idx(end);
        warning(['parameter ' param ' was defined multiple times. Using values from last definition'])
    end  
    if length(paramlist) < idx+n,
        error(['not enough values for parameter ''' param ''' (needs ' num2str(n) ')'])
    end
    varargout = paramlist(idx+1:idx+n);
else
    %use defaults if any
    if length(varargin) == n,
        varargout = varargin;
    else
        if ~isempty(varargin),
            warning('Defaults specified, but there is incorrect number, so not using them. Is this what you wanted?')
        end
        %no defaults, return empty args
        varargout = cell(1,n);    
    end
end