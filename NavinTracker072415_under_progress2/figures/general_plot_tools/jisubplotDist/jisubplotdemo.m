%jisubplot / nextplot demos
%
%   demonstrates some capabilities of jisubplot, nextplot, and currentplotis
%
%   See also JISUBPLOT, NEXTPLOT, CURRENTPLOTIS.
%
%   John Iversen (john_iversen@post.harvard.edu)
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% basic usage in a loop, note automatic overflow to new pages & resizing of figure
figure
%specify orientation, custom spacing, fontsize
jisubplot(8,4,0,'tall',[.3 .4],'fontsize',6)

somedata = randn(20,40);

for idx = 1:40,
    
    nextplot('bycol')   %advance down columns
    title(sprintf('data %d',idx))
    plot(1:20,somedata(:,idx)); box off
    
    %add labels only at edge of array
    if currentplotis('atrowbeginning')
        ylabel('Y')
    end
    if currentplotis('atcolumnend')
        xlabel('X')
    end
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Example of mixing different sized axes
figure
jisubplot(4,3,0,'tall')		%create 4 row x 3 column subplot grid, orient tall

somedata = randn(100,100,4);
for idx = 1:size(somedata,3),
    nextplot('size',[2 1]) %a double-width axis
    plot(somedata(:,:,idx))
    title(num2str(idx))

    nextplot('size',[1 1])
    imagesc(somedata(:,:,idx))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% example showing a variety of uses of nextplot
figure
jisubplot(4,5,0,'portrait',[],'fontsize',7)

nextplot
    surfl(peaks);shading interp

nextplot('bycol')
    surfl(peaks);shading interp

nextplot('newcol','skip')
    surfl(peaks);shading interp

nextplot
    surfl(peaks);shading interp

nextplot('bycol')
    surfl(peaks);shading interp

nextplot('newcol','size',[1 2])
    surfl(peaks);shading interp; view(2)

nextplot('newRow','size',[3 2])
    surfl(peaks);shading interp

nextplot('size',[2 1])
    surfl(peaks);shading interp

nextplot('bycol') 
    surfl(peaks);shading interp


nextplot('size',[1 1]) %bumps to next figure
    surfl(peaks);shading interp

nextplot('delta',[1 1]) %move diagonally
    surfl(peaks);shading interp



