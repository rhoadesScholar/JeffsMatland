function markers = htrReadFile(filepath);
% testing
%filepath = '\\140.247.178.37\Jesse\Vicon3\OtherHTRfiles\Jodi_TwentyTwo_rerun.htr';
% end testing

fid = fopen(filepath, 'r');
markers = struct;

% skip opening comments
lin = fgetl(fid);
while strcmp(lin(1),'#');
    lin = fgetl(fid);
end

% read initial information
lin = fgetl(fid);
while ~strcmp(lin(1),'['); % moves into hierarchy
c = strsplit(lin);
[num,status] = str2num(c{2});
if status
    markers.(c{1}) = num;
else
    markers.(c{1}) = c{2};
end
lin = fgetl(fid);
end

% skip next comment
lin = fgetl(fid);

% read in hierarchical structure
tree = struct;
for ii = 1:markers.NumSegments
    lin = fgetl(fid);
    c = strsplit(lin);
    tree.(c{1}) = c{2};
end
markers.tree = tree;

% skip next comment
lin = fgetl(fid);
lin = fgetl(fid);

% read in base position
baseposition = struct;
for ii = 1:markers.NumSegments
    lin = fgetl(fid);
    c = strsplit(lin);
    
    vec = cell2mat(cellfun(@str2num,c(2:end),'un',0));
    baseposition.(c{1}) = vec;
    
end

markers.baseposition = baseposition;

% skip comment
lin = fgetl(fid);


% read in data


%* loop over limbs fread bitwise
data = fread(fid);
segmentNames = fieldnames(baseposition);
fieldskip = 27;

[ind] = find(data==91); % this is '[' character
if length(ind) ~= markers.NumSegments;
    disp('error');
end

for jj = 1:markers.NumSegments
    % read in name
    namelength = length(segmentNames{jj});
    current_limb = char(data(ind(jj)+1:ind(jj)+namelength))';
    
    disp(['reading ' current_limb]);
    
    % get range to read
    readstart = ind(jj) + namelength + 2 + fieldskip;
    if jj==markers.NumSegments
        readend = length(data);
    else
    readend = ind(jj+1) - 1;
    end

    c = textscan(char(data(readstart:readend)'),'%f64');
    if length(c{1}) ~= 8 * markers.NumFrames;
        disp('problem');
    end
    
    % parse c
    c = c{:};
    markers.(current_limb).frame = c(1:8:end);
    markers.(current_limb).Tx = c(2:8:end);
    markers.(current_limb).Ty = c(3:8:end);
    markers.(current_limb).Tz = c(4:8:end);
    markers.(current_limb).Rx = c(5:8:end);
    markers.(current_limb).Ry = c(6:8:end);
    markers.(current_limb).Rz = c(7:8:end);
    markers.(current_limb).SF = c(8:8:end);
end



%{
%*loop over limbs
for jj = 1:markers.NumSegments

current_limb = fgetl(fid);
current_limb = current_limb(2:end-1);
lin = fgetl(fid); % read in comment

disp(['Reading ' current_limb]);

% get data
data = zeros(7,markers.NumFrames);
for ii = 1:markers.NumFrames;
    lin = fgetl(fid);
    c = strsplit(lin);
    vec = cell2mat(cellfun(@str2num,c(1:end),'un',0));
    data(:,vec(1)) = vec(2:end);
end

% save data
markers.(current_limb).Tx = data(1,:);
markers.(current_limb).Ty = data(2,:);
markers.(current_limb).Tz = data(3,:);
markers.(current_limb).Rx = data(4,:);
markers.(current_limb).Ry = data(5,:);
markers.(current_limb).Rz = data(6,:);
markers.(current_limb).SF = data(7,:);


end
%}
end