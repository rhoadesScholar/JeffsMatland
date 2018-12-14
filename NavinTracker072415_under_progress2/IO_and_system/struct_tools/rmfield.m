function t = rmfield(s,field)
%RMFIELD Remove fields from a structure array.
%   S = RMFIELD(S,'field') removes the specified field from the
%   m x n structure array S. The size of input S is preserved.
%
%   S = RMFIELD(S,FIELDS) removes more than one field at a time
%   when FIELDS is a character array or cell array of strings.  The
%   changed structure is returned. The size of input S is preserved.
%
%   See also SETFIELD, GETFIELD, ISFIELD, FIELDNAMES.

%   JP Barnard
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.25.4.4 $  $Date: 2005/06/21 19:25:14 $

%--------------------------------------------------------------------------------------------
% handle input arguments
if ~isa(s,'struct') 
    error('MATLAB:rmfield:Arg1NotStructArray', 'S must be a structure array.'); 
end
if ~ischar(field) && ~iscellstr(field)
   error('MATLAB:rmfield:FieldnamesNotStrings',...
      'FIELDNAMES must be a string or a cell array of strings.');
elseif ischar(field)
   field = cellstr(field); 
end

% get fieldnames of struct
f = fieldnames(s);

% Navin start
i=1;
while i<=length(field)
     j = strmatch(field{i},f,'exact');
     if isempty(j)
         field(i)=[];
     end
     i=i+1;
end
% Navin end


% Determine which fieldnames to delete.
idxremove = [];
for i=1:length(field)
  j = strmatch(field{i},f,'exact');
  
  if(~isempty(j))
    idxremove = [idxremove;j];
  end
  
%   if isempty(j)
%     if length(field{i}) > namelengthmax
%       error('MATLAB:rmfield:FieldnameTooLong',...
%         'The string ''%s''\nis longer than the maximum MATLAB name length.  It is not a valid fieldname.',...
%         field{i});
%     else
%       error('MATLAB:rmfield:InvalidFieldname', 'A field named ''%s'' doesn''t exist.',field{i});
%     end
%   end
%   idxremove = [idxremove;j];
  
end

% set indices of fields to keep
idxkeep = 1:length(f);
idxkeep(idxremove) = [];

% remove the specified fieldnames from the list of fieldnames.
f(idxremove,:) = [];

% convert struct to cell array
c = struct2cell(s);

% find size of cell array
sizeofarray = size(c);
newsizeofarray = sizeofarray;

% adjust size for fields to be removed
newsizeofarray(1) = sizeofarray(1) - length(idxremove);

% rebuild struct
t = cell2struct(reshape(c(idxkeep,:),newsizeofarray),f);

%--------------------------------------------------------------------------------------------
