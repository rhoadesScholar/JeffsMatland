method = sprintf('euclidean');


for(i=1:50) for(j=1:25) x(i,j) = 2*((rand*i+rand*j)); end; end;

v = [1:50];
x1=[];
while(~isempty(v))  
   d=round(100*rand);
   while(d>length(v) || d<=0)
       d=round(100*rand);
   end
   x1 = [x1; x(v(d),:)];
   v(d)=[];
end
x=x1;


image(x)
axis equal

Y = pdist(x,method);
Z = linkage(Y,'average');

figure
[H,T, perm] = dendrogram(Z,0,'orientation','left');
perm

x1 = x(perm,:);
figure
image(x1);
axis equal
