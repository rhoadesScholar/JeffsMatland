function v = ethogram_simple_colormap(a)

v=[1 1 1];
for(i=0.8:-0.015625:0.31562)
   v = [v; 0.7 0.7 0.7;];
end

v = [v;    1.0000    0.0000    0.0000;]; % red 34

% % upsilon count as fwd
% v = [v;    0.7 0.7 0.7;];
% upsilon count as omega
v = [v;    1.0000    0.0000    0.0000;];
% v = [v;    1.0000    0.0000    1.0000;]; % magenta 35

% all rev are blue
v = [v;    0.0000    0.0000    1.0000;]; % blue 36

v = [v;    0.0000    0.0000    1.0000;]; 
% v = [v;    0.0000    1.0000    1.0000;]; % cyan 37

v = [v;    0.0000    1.0000    0.0000;]; % green 38
v = [v;    1.0000    1.0000    1.0000;]; % white 39
v = [v;    1.0000    1.0000    1.0000;]; % white 40
v = [v;    1.0000    1.0000    1.0000;]; % white 41

if(nargin<1)
    return;
end

a = round(a);
if(a>39)
    a=39;
end
if(a<1)
    a=1;
end

x = v(a,:);
v = x;

% x = uint8(v(a,:)*255);

return;

return;
end
