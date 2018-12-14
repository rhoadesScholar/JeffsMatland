function background = center_mask_background(background, setvalue)

s = size(background);

if(nargin==1)
    setvalue=0;
end

for(i=1:round(s(1)/4))
    background(i,:)=setvalue;
end
for(i=1:round(s(2)/4))
    background(:,i)=setvalue;
end    
for(i=round(3*s(1)/4):s(1))
    background(i,:)=setvalue;
end    
for(i=round(3*s(2)/4):s(2))
    background(:,i)=setvalue;
end 

return;
end
