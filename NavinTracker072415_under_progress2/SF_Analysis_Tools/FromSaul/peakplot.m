function peakplot(vec,thresh)
%PEAKPLOT plot peaks 
%
%peakplot(vec,thresh)
%
%uses peakfind

%saul kato
%created 092109
%updated 100602
%

if nargin<2 || ~exist('thresh','var')
    thresh=10;
end

minval=min(vec);
start=100;
finish=size(vec,1);
[peaks valleys] = peakfind(vec(start:finish),thresh);        

if size(peaks,1) > 0 
peaks(:,1)=start+peaks(:,1);
end

if size(valleys,1) > 0
valleys(:,1)=start+valleys(:,1);
end

%add valley at end time if there is no final valley
if size(valleys,1)<size(peaks,1)
    valleys=[valleys ; finish minval];
end   

%draw segmentation rectangles

%draw first rectangle
if size(valleys,1)>0
    rectangle('Position',[start,minval,valleys(1,1)-start,peaks(1,2)-minval],'FaceColor',[0.9 0.9 1]);
end
%draw middle rectangles
if size(valleys,1)>1    
    for i=1:(size(valleys,1)-1)
        rectangle('Position',[valleys(i,1),minval,valleys(i+1,1)-valleys(i,1),peaks(i+1,2)-minval],'FaceColor',[0.8 1 1]);
    end
end

%draw last rectangle
 if size(valleys,1)==0
     if size(peaks,1)==0
         disp('no peaks or valleys found. try decreasing thresh.');
     else
         rectangle('Position',[start,minval,length(vec)-start,peaks(1,2)-minval],'FaceColor',[1 0.9 0.9]); 
     end
    %elseif size(valleys,1)==1
    %rectangle('Position',[valleys(1,1),minval,length(vec)-valleys(1,1),peaks(2,2)-minval],'FaceColor',[1 0.9 0.9]); 
 elseif size(peaks,1)>size(valleys,1)
    rectangle('Position',[valleys(i+1,1),minval,length(vec)-valleys(i+1,1),peaks(i+2,2)-minval],'FaceColor',[1 0.9 0.9]);
 end

hold on;    
plot(vec);

plot(peaks(:,1), peaks(:,2), 'go');
if size(valleys,1)>0
    plot(valleys(:,1), valleys(:,2), 'ro');
end
    
    
%    sensitivity test.  run peakfind for a number of different threshold
%    values
%
%    i=1;
%    ithreshvec=1:1:100;
%    for ithresh=ithreshvec
%          [peaks valleys] = peakfind(vec,ithresh);
%          numpeaks(i)=size(peaks,1);
%          i=i+1;
%    end
%       
%    figure('Position',[800 600 600 400]);
%    plot(ithreshvec,numpeaks,'.-');
%    ylabel('number of peaks detected');
%    xlabel('threshold (%\DeltaF/F)');
    
end


