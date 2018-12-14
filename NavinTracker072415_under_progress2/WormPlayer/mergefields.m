% --------------------------------------------------------
function z = mergefields(varargin)
%MERGEFIELDS Merge fields into one structure
%   Z = MERGEFIELDS(A,B,C,...) merges all fields of input structures
%   into one structure Z.  If common field names exist across input
%   structures, values from later input arguments prevail.
%
%   Example:
%     x.one=1;  x.two=2;    % Define structures
%     y.two=-2; y.three=3;  % containing a common field (.two)
%     z=mergefields(x,y)  % => .one=1, .two=-2, .three=3
%     z=mergefields(y,x)  % => .one=1, .two=2,  .three=3
%
%   See also SETFIELD, GETFIELD, RMFIELD, ISFIELD, FIELDNAMES.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: $ $Date: $

z=varargin{1};
for i=2:nargin,
    f=fieldnames(varargin{i});
    for j=1:length(f),
        z.(f{j}) = varargin{i}.(f{j});
    end
end
