% the curvature in this function is defined as the ratio of euclidean
% distance travelled vs actual distance travelled during Prefs.curvStep

% x and y are the x-coordinates and y-coordinates of the path

function curvature_array = straightness(x, y)

global Prefs;

dt = 5*Prefs.FrameRate;

curvWindow = floor(dt/2);

curvature_array=zeros(1,length(x));
curvature_array = curvature_array+NaN;


for (i=curvWindow+1:length(x)-curvWindow)

    j = i-curvWindow; 
    k = i+curvWindow;
    
    d = sqrt( (x(k) - x(j))^2 + (y(k) - y(j))^2 ); % euclidean distance travelled
    
    
    % calculate actual distance travelled
    travel_dist=0;
    for n=j:(k-1)
        travel_dist = travel_dist + sqrt( (x(n) - x(n+1))^2 + (y(n) - y(n+1) )^2 );
    end    
    
    if(travel_dist==0)
       curvature_array(i) = NaN;
    else
        curvature_array(i) = d/travel_dist;
    end
    
end

% for the ends of the track, assign the curvature of the closest point
% with measured curvature
for(i=1:curvWindow)
    curvature_array(i) = curvature_array(curvWindow+1);
end    
for(i=length(x)-curvWindow+1:length(x))    
    curvature_array(i) = curvature_array(length(x)-curvWindow);
end



return;

end

