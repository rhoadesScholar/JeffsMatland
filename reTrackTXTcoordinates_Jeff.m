function reTrackTXTcoordinates_Jeff()

%Jeff Rhoades changed so many things 5/3/17 (made callable function, batch
%process, no more writing blank lines, commented out retracking/intdens calculation scripts)

%SWF changed:
%   catch for no-row in imagej
%   comment away all non-essentials

%re-track imaging data from tif files using positions from imageJ txt output
%johannes 2014

%will re-track two ways simultaneously:
%1.: re-track movie using coordinates from a txt file
%--> AllSqIntOld_matlab;
%2.: re-track in the vicinity of txt file coordinates using a sliding
%threshold and matlab peak detection
%-->AllSqInt
%(3.) also re-read intensity values from txt file
%can use to specify larger square for integration. (sqSize)

    sqSize=4; %squareSize for re-tracking with maximum detection on interpolated subRegion of image
    imReadSize=30; %number of pixels to be read for re-tracking. (+/- center)
    imSizeSm=10; %subregion for faster processing of new positions on interpolation (10=default)
    interpl=2; %interpolation (2=default)
    showProgress=0; %showVideo - slows Down processing a lot!
    
    success = '';
    
    while ~strcmp(success, 'Yes')
        day = uigetdir;
        vids = dir(day);
        vids = vids(3:end);
        vids = vids([vids.isdir]);
        vids = arrayfun(@(x) [x.folder '\' x.name], vids, 'UniformOutput', false);
        
        for d = 1:length(vids)
            pn = vids{d};
            cd(pn);
            animals = dir('*sub\*.txt');

            if isempty(animals)
                %select folder with original tifs, w/ subfolder with old track files
                pn = uigetdir;
                if pn == 0
                    continue
                end
                cd(pn);
                animals = dir('*sub\*.txt');
            end
            
            for k = 1:length(animals)
                %read textfile and get position info
                try
                    dat = textread([animals(k).folder '\' animals(k).name],'','delimiter',',','headerlines',1);
                catch
                    warndlg(['Fix file ' animals(k).folder '\' animals(k).name ', then press any key to continue']);
                    pause
                    dat = textread([animals(k).folder '\' animals(k).name],'','delimiter',',','headerlines',1);
                end

                sqSizeOld=round(sqrt(dat(1,13))); %squareSize for re-tracking on old positions
                %to remove jitter between two neighboring neurons, can figure out one neuron location from position histogram this is not used for now. 
                % [TrackHist histCoor]=hist3([dat(:,2),dat(:,3)]);
                % [value, location] = max(TrackHist(:));
                % [R,C] = ind2sub(size(TrackHist),location);
                % peak=round([histCoor{1}(R) histCoor{2}(C)]);

                D = dir('*.tif');
                fn = D(1).name;
                movieFile = [pn fn];

                % info = imfinfo(movieFile);
                % movieData.NumFrames = numel(info);
                % movieData.Width = info(1).Width;
                % movieData.Height = info(1).Height;
                % movieData.info = info;

                [xMesh, yMesh] = meshgrid(1:imReadSize*2+1, 1:imReadSize*2+1);

                %define backgroundCoordinates, donut shape for background division (didn't check if still appropriate size!)
                bgRad=8;
                bgCoor=(sqrt((xMesh-(imReadSize+1)).^2 + (yMesh-(imReadSize+1)).^2))<bgRad*2.4 &(sqrt((xMesh-(imReadSize+1)).^2 + (yMesh-(imReadSize+1)).^2))>bgRad*1.2;

                initialTrshOld=dat(1,14);
                %PkCurrSm=[41 41];

                s = 1; %slice counter
                for i = 1:length(D)
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

                    if(length(IndexLast)==0)
                        ReachedEOtxtF=1; %don't use txt file coordinates if there aren't any but keep matlab tracking
                    end

                    if ~(ReachedEOtxtF==1) && ~isnan(PkCurr(1))
                        PkCurrRnd=round(PkCurr);

                        %get movie frame around coordinates
                        Mov=nan((imReadSize*2)+1);
                        try
                            [tmp,~] = imread([pn '\' D(i).name],'PixelRegion',{[1+PkCurrRnd(2)-imReadSize 1+PkCurrRnd(2)+imReadSize] [1+PkCurrRnd(1)-imReadSize 1+PkCurrRnd(1)+imReadSize]});
                            Mov(1:size(tmp,1),1:size(tmp,2))=tmp;

                            %find peaks near old neuron coordinate
                            MovSm=Mov(1+imReadSize-imSizeSm:1+imReadSize+imSizeSm,1+imReadSize-imSizeSm:1+imReadSize+imSizeSm);
                            %interpolate
                            MovSmI=interp2(double(MovSm),interpl);
                            %MovSmI=MovSm;

                            if s == 1
                               %get initial size of thresheld area from first frame
                               TrshAreaInit=nansum(nansum(MovSmI>initialTrshOld));
                               currTrsh=initialTrshOld;
                               %pkInit = pkfnd(double(MovSmI),currTrsh,13);
                               %NrOfPkInit=size(pkInit,2);       
                            else   
                                %matlab tracking of maximum: dynamically adjust threshold by keeping area above threshold constant
                                TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
                                while TrshAreaCurr>TrshAreaInit*1.2
                                    currTrsh=currTrsh*1.05 + (currTrsh<0.01)*0.01;
                                    TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
                                end

                                while TrshAreaCurr<TrshAreaInit*0.9
                                    currTrsh=currTrsh*0.95;
                                    if currTrsh < 0.001
                                        TrshAreaCurr=TrshAreaInit*0.9;
                                    else
                                        TrshAreaCurr=nansum(nansum(MovSmI>currTrsh));
                                    end
                                end

                            end   

        %                 AllPkCurr = pkfnd(double(MovSmI),currTrsh,13);
        %                 if isempty(AllPkCurr)
        %                     AllPkCurr = PkCurrRnd;
        %                 end
        %                 cnt = cntrd(double(MovSmI),AllPkCurr,7);  
        %                 if isempty(cnt)
        %                     cnt = PkCurrRnd;
        %                 end

                            %pick peak closest to previous peak location
                        %[~, pkClosest]=min(sum(abs(AllPkCurr-repmat([2*imSizeSm*interpl+1 2*imSizeSm*interpl+1],size(AllPkCurr,1),1)),2));
                        %PkCurrSm=round(cnt(pkClosest,1:2));
                            %PkCurr=PkCurrSm+[PkCurr(1)-(imSizeSm*4+2) PkCurr(2)-(imSizeSm*4+2)];
                        %PkCurr=[PkCurr(1)+((PkCurrSm(1)/4)-(imSizeSm)) PkCurr(2)+((PkCurrSm(2)/4)-(imSizeSm))];

        %                     xNewSm(i)=PkCurrSm(1);
        %                     yNewSm(i)=PkCurrSm(2);

                            Slice(s) = dat(IndexLast,1);
                            xc(s)=dat(IndexLast,2);%PkCurr(1);
                            yc(s)=dat(IndexLast,3);%PkCurr(2);
                            intdens(s)=NaN;%nansum(nansum(MovSmI(PkCurrSm(2)-sqSize*interpl:PkCurrSm(2)+sqSize*interpl,PkCurrSm(1)-sqSize*interpl:PkCurrSm(1)+sqSize*interpl)));%sum up pixel intensities around maximum
                            intsub(s) = NaN; %(intdens(s) - double((2*sqSize*interpl+1).^2 * bgmedian(s)))./((2*sqSize*interpl+1).^2);%calculate background subtracted intensity
                            bgmedian(s)=nanmedian(Mov(bgCoor));
                            maxint(s) = max(max(MovSmI));
                            area(s) = nansum(nansum(MovSmI>currTrsh));
                            x(s)=dat(IndexLast,2);
                            y(s)=dat(IndexLast,3);
                            sqintdens(s)=nansum(nansum(Mov(imReadSize-sqSizeOld:imReadSize+sqSizeOld,imReadSize-sqSizeOld:imReadSize+sqSizeOld)));
                            sqintsub(s) = (sqintdens(s) - double((2*sqSizeOld+1).^2 * bgmedian(s)))./((2*sqSizeOld+1).^2);
                            sqarea(s) = sqSizeOld^2;
                            threshold(s)=currTrsh;
                            animal(s) = k;
                            redFlag(s) = dat(IndexLast, 16);
                            useTracking(s) = dat(IndexLast, 17);
                        
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
                        catch
                            Slice(s) = dat(IndexLast,1);
                            xc(s)=dat(IndexLast,2);%PkCurr(1);
                            yc(s)=dat(IndexLast,3);%PkCurr(2);
                            intdens(s)=NaN;%nansum(nansum(MovSmI(PkCurrSm(2)-sqSize*interpl:PkCurrSm(2)+sqSize*interpl,PkCurrSm(1)-sqSize*interpl:PkCurrSm(1)+sqSize*interpl)));%sum up pixel intensities around maximum
                            intsub(s) = NaN; %(intdens(s) - double((2*sqSize*interpl+1).^2 * bgmedian(s)))./((2*sqSize*interpl+1).^2);%calculate background subtracted intensity
                            bgmedian(s)=NaN;
                            maxint(s) = NaN;
                            area(s) = NaN;
                            x(s)=dat(IndexLast,2);
                            y(s)=dat(IndexLast,3);
                            sqintdens(s)=NaN;
                            sqintsub(s) = NaN;
                            sqarea(s) = sqSizeOld^2;
                            threshold(s)=currTrsh;
                            animal(s) = k;
                            redFlag(s) = dat(IndexLast, 16);
                            useTracking(s) = dat(IndexLast, 17);
                        end

                        s = s + 1;
                    end
                end

    %             AllSqIntOld_matlab(:) = (sqintdens(:) - double((2*sqSizeOld+1).^2 * bgmedian(:)))./((2*sqSizeOld+1).^2);
    %             % AllSqInt2(:,j,k) = sqintdens(:,j,k) - double((25.^2 * dat(:,6)')')./16;
    % 
    %             AllSqIntOld_ImageJ=nan(size(AllSqIntOld_matlab));
    %             AllSqIntOld_ImageJ(1:size(dat,1))=dat(:,12)/dat(1,13);%divide by sqarea
    %             bgOld(:)=dat(:,6);            

                Slice = Slice';
                xc = xc';
                yc = yc';
                intdens = intdens';
                intsub = intsub';
                bgmedian = bgmedian';
                maxint = maxint';
                area = area';
                x = x';
                y = y';
                sqintdens = sqintdens';
                sqintsub = sqintsub';
                sqarea = sqarea';
                threshold = threshold';
                animal = animal';
                redFlag = redFlag';
                useTracking = useTracking';

                data = table(Slice,xc,yc,intdens,intsub,bgmedian,maxint,area,x,y,sqintdens,sqintsub,sqarea,threshold,animal,redFlag,useTracking);

                fileName = strsplit('\', pn);
                fileName = sprintf('%s\\%s.an%i.txt', pn, fileName{end}, k);
                writetable(data, fileName)            
                clearvars -except sqSize imReadSize imSizeSm interpl showProgress pn animals vids d
            end
        end
        success = questdlg('Done?', 'All animals retracked?', 'Yes','No', 'Yes');
        cd ..
        cd ..
    end

end

