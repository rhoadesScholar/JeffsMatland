%SWF changed:
%   catch for no-row in imagej
%   comment away all non-essentials

%re-track imaging data from tif files using positions from imageJ txt
%output
%johannes 2014

%will re-track two ways simultaneously:

%1.: re-track movie using coordinates from a txt file
%--> AllSqIntOld_matlab;

%2.: re-track in the vicinity of txt file coordinates using a sliding
%threshold and matlab peak detection
%-->AllSqInt

%(3.) also re-read intensity values from txt file

%can use to specify larger square for integration. (sqSize)


clear
close(get(0,'Children')); %close all figures

sqSizeOld=4; %squareSize for re-tracking on old positions
sqSize=6; %squareSize for re-tracking with maximum detection on interpolated subRegion of image
imReadSize=30; %number of pixels to be read for re-tracking. (+/- center)
imSizeSm=10; %subregion for faster processing of new positions on interpolation (10=default)
interpl=2; %interpolation (2=default)

showProgress=0; %showVideo - slows Down processing a lot!

%select txt file (track results) to retrack

[fn, pn]=uigetfile('*.txt','Select .an.txt file to re-track');
cd(pn);
D=dir(pn);

%could cycle through many animals (k)
%here just one animal


for k=1:1
%     D=dir(pn);
%     for l=1:length(D);
%         tmp=strfind(D(l).name,['an' num2str(k-1)]);
%         if ~isempty(tmp);
%             idx(l)=tmp>1;
%         end;
%     end
%     
%     D=D(idx);


%could cycle through many folders (j)
%here just one folder

j=1;

% for j=1:sum(idx)
% if mod(j,round(length(D)/20))==0, disp(sprintf('\b*')); end
%dat = textread([pn D(j).name],'','delimiter',',','headerlines',1);

%read textfile and get position info
dat = textread([pn fn],'','delimiter',',','headerlines',0);


%to remove jitter between two neighboring neurons, can figure out one neuron location from position histogram
%this is not used for now. 

% [TrackHist histCoor]=hist3([dat(:,2),dat(:,3)]);
% [value, location] = max(TrackHist(:));
% [R,C] = ind2sub(size(TrackHist),location);
% peak=round([histCoor{1}(R) histCoor{2}(C)]);

% movieFile=[pn D(j).name(1:end-8) '.tif'];

%for now, select video folder manually (assuming single frame tiff file
%folder)
[fn, pn]=uigetfile('*.tif','select first file in movie folder to re-track');
movieFile=[pn fn];

% movieFile=[pn D(j).name(1:end-8) '.tif'];
% info = imfinfo(movieFile);
% movieData.NumFrames = numel(info);
% movieData.Width = info(1).Width;
% movieData.Height = info(1).Height;
% movieData.info = info;


[x, y] = meshgrid(1:imReadSize*2+1, 1:imReadSize*2+1);

%define backgroundCoordinates, donut shape for background division (didn't check if still
%appropriate size!)
bgRad=8;
bgCoor=(sqrt((x-(imReadSize+1)).^2 + (y-(imReadSize+1)).^2))<bgRad*2.4 &(sqrt((x-(imReadSize+1)).^2 + (y-(imReadSize+1)).^2))>bgRad*1.2;

%undone: use threshold from second frame (first often empty)
initialTrshOld=dat(1,14);

%PkCurrSm=[41 41];
    
D=dir([pn,'*.tif']);

%undone: start on second frame bc first is often empty
%this is assuming long videos with single frames tiff files.

for i=1:length(D)
    
%get X/Y-coordinates for read-out on old location

% if i<size(dat,1)
    
    %deal with duplicates caused by re-tracking in imageJ after tracking
    %error. find last data for current frame
    
    IndexLast=find(dat(:,1)==i,1,'last');

    try
        PkCurr=[round(dat(IndexLast,2)) round(dat(IndexLast,3))];
        
        ReachedEOtxtF=0;
    catch
        ReachedEOtxtF=1; %don't use txt file coordinates if there aren't any but keep matlab tracking
    end
%     PkCurr=[round(dat(i,2)) round(dat(i,3))];

    if(length(IndexLast)==0)
        ReachedEOtxtF=1; %don't use txt file coordinates if there aren't any but keep matlab tracking
    end


% else
%     ReachedEOtxtF=1;
% end

if(ReachedEOtxtF==1)
    sqintdensOldPos(i,j)=nan(1);%%%fill in with a Nan, if necessary
    bgmedian(i,j,k)= nan(1);
else


    PkCurrRnd=round(PkCurr);

    %get movie frame around coordinates
    
    Mov=nan((imReadSize*2)+1);
%   [tmp,map] = imread(movieFile, i, 'Info', movieData.info,'PixelRegion',{[1+PkCurrRnd(2)-imReadSize 1+PkCurrRnd(2)+imReadSize] [1+PkCurrRnd(1)-imReadSize 1+PkCurrRnd(1)+imReadSize]});
    [tmp,map] = imread([pn,D(i).name],'PixelRegion',{[1+PkCurrRnd(2)-imReadSize 1+PkCurrRnd(2)+imReadSize] [1+PkCurrRnd(1)-imReadSize 1+PkCurrRnd(1)+imReadSize]});
    if mod(i,round(length(D)/20))==0, disp(i); end
    Mov(1:size(tmp,1),1:size(tmp,2))=tmp;
    
    %show frames (but this will slow things down!)
    %imagesc(Mov);drawnow;
    
    
    %find peaks near old neuron coordinate
    MovSm=Mov(1+imReadSize-imSizeSm:1+imReadSize+imSizeSm,1+imReadSize-imSizeSm:1+imReadSize+imSizeSm);
    %interpolate
	MovSmI=interp2(double(MovSm),interpl);
    %MovSmI=MovSm;
    
    if i==2
       %get initial size of thresheld area    
       TrshAreaInit=nansum(nansum(MovSmI>initialTrshOld));
       currTrsh=initialTrshOld;
       pkInit = pkfnd(double(MovSmI),currTrsh,13);
       NrOfPkInit=size(pkInit,2);       
    else   
        %matlab tracking of maximum:
        %dynamically adjust threshold by keeping area above threshold
        %constant
        TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
        while TrshAreaCurr>TrshAreaInit*1.2
            currTrsh=currTrsh*1.05;
            TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
        end
        
        while TrshAreaCurr<TrshAreaInit*0.9
            currTrsh=currTrsh*0.95;
            TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
        end

    end   
        AllPkCurr = pkfnd(double(MovSmI),currTrsh,13);#######
        cnt = cntrd(double(MovSmI),AllPkCurr,7);  
    
    %pick peak closest to previous peak location
    
        [dist, pkClosest]=min(sum(abs(AllPkCurr-repmat([2*imSizeSm*interpl+1 2*imSizeSm*interpl+1],size(AllPkCurr,1),1)),2));
        PkCurrSm=round(cnt(pkClosest,1:2));
        %PkCurr=PkCurrSm+[PkCurr(1)-(imSizeSm*4+2) PkCurr(2)-(imSizeSm*4+2)];
        PkCurr=[PkCurr(1)+((PkCurrSm(1)/4)-(imSizeSm)) PkCurr(2)+((PkCurrSm(2)/4)-(imSizeSm))];

        
    if ~ReachedEOtxtF %use existing positions until txt file ends. then, continue with matlab tracking only.
        
        sqintdensOldPos(i,j)=nansum(nansum(Mov(imReadSize-sqSizeOld:imReadSize+sqSizeOld,imReadSize-sqSizeOld:imReadSize+sqSizeOld)));
    else
        sqintdensOldPos(i,j)=nan(1);
    end
    
    %sum up pixel intensities around maximum
    sqintdens(i,j,k)=nansum(nansum(MovSmI(PkCurrSm(2)-sqSize*interpl:PkCurrSm(2)+sqSize*interpl,PkCurrSm(1)-sqSize*interpl:PkCurrSm(1)+sqSize*interpl)));
    bgmedian(i,j,k)=nanmedian(Mov(bgCoor));
    xNew(i,j,k)=PkCurr(1);
    yNew(i,j,k)=PkCurr(2);
    xNewSm(i,j,k)=PkCurrSm(1);
    yNewSm(i,j,k)=PkCurrSm(2);
    AllTrsh(i,j,k)=currTrsh;
    
    %show movie frames with rectangle overlay
    if showProgress
        figure(1);
        subplot(1,2,1)
        imagesc(Mov);
        hold on
        rectangle('Position',[imReadSize-sqSizeOld,imReadSize-sqSizeOld,sqSizeOld*2+1,sqSizeOld*2+1]);
        subplot(1,2,2)
        imagesc(MovSmI);
        hold on
        rectangle('Position',[PkCurrSm(1)-sqSize*interpl,PkCurrSm(2)-sqSize*interpl,interpl*sqSize*2+1,interpl*sqSize*2+1]);
        drawnow;

    end
end
end

%calculate background subtracted intensity
################################################
%AllSqInt(:,j,k) = (sqintdens(:,j,k) - double((2*sqSize*interpl+1).^2 * bgmedian(:,j,k)))./((2*sqSize*interpl+1).^2);
AllSqIntOld_matlab(:,j,k) = (sqintdensOldPos(:,j,k) - double((2*sqSizeOld+1).^2 * bgmedian(:,j,k)))./((2*sqSizeOld+1).^2);
% AllSqInt2(:,j,k) = sqintdens(:,j,k) - double((25.^2 * dat(:,6)')')./16;

AllSqIntOld_ImageJ=nan(size(AllSqIntOld_matlab));
AllSqIntOld_ImageJ(1:size(dat,1),j,k)=dat(:,12)/16;
xOld(:,j,k)=dat(:,2);
yOld(:,j,k)=dat(:,3);
bgOld(:,j,k)=dat(:,6);

movieName = fn(1:(end-9));
fileNameHere = strcat(movieName,'_row12.mat');
save(fileNameHere,'AllSqIntOld_matlab');
% CorrPos(:,j,k)=peak;

% %calculate normalization for comparison plot
% All=[AllSqIntOld_ImageJ,AllSqIntOld_matlab,AllSqInt];
% AllNorm=normalizeImagingTraces(All,500);
% AllNormNorm=normalizeImagingTraces(All,500,1);
% 
% %plot results
% figure(2);clf;
% subplot(1,3,1);
% plot(All);
% title('raw');
% 
% subplot(1,3,2);
% plot(AllNorm);
% title('normToBaseLine');
% 
% subplot(1,3,3);
% plot(AllNormNorm);
% title('norm_0to1','interpreter','none');
% 
% 
% lg={'ImageJ','matLabOldPos','matLabTrack'};
% legend(lg)

end

