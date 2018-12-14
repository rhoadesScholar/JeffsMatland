function main
showwindow('SPtrack','hide');
showwindow('instructions','minimize');
clc;

fid = fopen('parameter.m','r');
A = fscanf(fid,'%u');
fclose(fid);
sz = A(1,1);
itcf = A(2,1);
m = A(3,1)
p = 0 
for i = 1:m
fileName = uigetfile('*.tif;*.jpg')
imshow(imread(fileName))
a = double(imread(fileName));
colormap('gray'), imagesc(a);


b = bpass(a,1,sz);
%colormap('gray'), image(b);
pk = pkfnd(b,itcf,sz);
%pk

cnt = cntrd(b,pk,sz);
cnt
x_final = cnt(1,1) ;
y_final = cnt(1,2) ;
button = questdlg('The peak values are written on the command line.DO you wanna accept?','congrats','yes','no','default');
switch button
    case 'yes'
       p = p + 1
        fid = fopen('x.m','a+');
       fprintf(fid,'\n %12.8f ',x_final);
       fid = fopen('y.m','a+');
       fprintf(fid,'\n %12.8f ',y_final);
       %fprintf(fid,'%6.2f ',i); if u wanna print the frame.
    
    case 'no'
    ;   
end

end

fid = fopen('x.m','r');
X = fread(fid,p) ;
fclose(fid) ;

fid = fopen ('y.m','r') ;
Y = fread(fid,p) ;
fclose(fid) ;


figure,plot(X,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',7)
xlabel('frames or time')
ylabel('x position')
title('Plot of x position vs time')


figure,plot(Y,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',7)
xlabel('frames or time')
ylabel('y position')
title('Plot of y position vs time')            


figure,plot(X,Y,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',7)
xlabel('x position')
ylabel('y position')
title('position track (x,y)')            
                
adios               