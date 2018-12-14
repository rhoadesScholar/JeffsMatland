function [y0,ymaxResp,yfinal,alpha1,tau1,alpha2,tau2, t_switch, x_err, r] = fit_double_sigmoid(t,y, y_err, stimulus_time, colorvector)

% initial guesses

if(nargin < 5)
    colorvector = [rand rand rand];
end

% y0_0
idx = find(t < stimulus_time);
if(~isempty(idx))
    y0_0 = nanmean(y(idx));
else
    y0_0=y(1);
end

p.t = t;
p.y = y;
p.y_s = y_err;
p.maxflag=1;

% ymaxResp_0
[ymaxResp_0, ymaxResp_index] = max(y);
[ymin_0, ymin_index] = min(y);
if(abs(ymaxResp_0 - y0_0) < abs(ymin_0 - y0_0)) % ymaxResp is min
    ymaxResp_0 = ymin_0;
    ymaxResp_index = ymin_index;
    p.maxflag=0;
end
ymaxResp_index = ymaxResp_index(1);
t_ymaxResp = t(ymaxResp_index);

t_switch_0 = t_ymaxResp;

p.ymaxResp_index = ymaxResp_index;

% yfinal_0 last 20% of the data for t > t_max
idx = find(t > t_ymaxResp);
idx = idx(round(0.2*length(idx)):end);
yfinal_0 = nanmean(y(idx));

y_alpha1_0 = (y0_0 + ymaxResp_0)/2; % midpoint of transitions
y_alpha2_0 = (yfinal_0 + ymaxResp_0)/2;

starttrans_index = ymaxResp_index;
if(y0_0 - y(starttrans_index) > 0)
    while(y0_0 - y(starttrans_index) > 0)
        starttrans_index = starttrans_index - 1;
    end 
else
    while(y0_0 - y(starttrans_index) < 0)
        starttrans_index = starttrans_index - 1;
    end 
end
idx = find(t <= t_ymaxResp & t >= t(starttrans_index));
x = t(idx);
w = y(idx);

% plot(x,w,'.-r');
alpha1_0 = nanmean(x);   
idx=find(~isnan(w));
[tau1_0,b] = fit_line(x(idx),w(idx)); 
clear('idx');


endtrans_index = ymaxResp_index;
if(yfinal_0 - y(endtrans_index) > 0)
    while(yfinal_0 - y(endtrans_index) > 0)
        endtrans_index = endtrans_index + 1;
    end 
else
    while(yfinal_0 - y(endtrans_index) < 0)
        endtrans_index = endtrans_index + 1;
    end 
end
idx = find(t >= t_ymaxResp & t <= t(endtrans_index));
x = t(idx);
w = y(idx);
% plot(x,w,'.-g');
alpha2_0 = nanmean(x);  
idx=find(~isnan(w));
[tau2_0,b] = fit_line(x,w); 
clear('idx');

x0 = double([y0_0 ymaxResp_0 yfinal_0 alpha1_0 tau1_0  alpha2_0 tau2_0 t_switch_0 ]);

yfit = double_sigmoid_function(t, x0);
% plot(t,yfit,'r');
% x0
% corr2(y,yfit)

fminsearchoptions = optimset('MaxFunEvals',1000*1000);

x = x0;
x = fminsearch(@(x) obj_function(x,p), x0, fminsearchoptions);
score_best = obj_function(x,p);
xbest = x;

% for(ctr=1:10)
%     x0 = double([(y0_0 + randn*abs(y0_0)) (ymaxResp_0 + randn*abs(ymaxResp_0) ) (yfinal_0 + randn*abs(yfinal_0) ) (alpha1_0 + randn*abs(alpha1_0) ) (tau1_0 + randn*abs(tau1_0) ) (alpha2_0  + randn*abs(alpha2_0)) (tau2_0  + randn*abs(tau2_0)) ]);
%     x = x0;
%     x = fminsearch(@(x) obj_function(x,p), x0, fminsearchoptions);
%     score = obj_function(x,p);
%     if(score < score_best)
%         xbest = x;
%         score_best = score;
%     end
% end

y0 = xbest(1);
ymaxResp = xbest(2);
yfinal = xbest(3);
alpha1 = xbest(4);
tau1 = xbest(5);
alpha2 = xbest(6);
tau2 = xbest(7);
t_switch = xbest(8);

x_err=[];
% x_err = fitting_error(t, y, 'double_sigmoid_function', xbest);


yfit = double_sigmoid_function(t, xbest);

if(~isempty(colorvector))
    plot(t,yfit,'color',colorvector,'LineWidth',2);
    hold on;
    plot(t,y,'color',colorvector,'marker','o'); % ,'LineStyle','none');
    hold off;
end

idx = find(~isnan(y));
r = corr2(y(idx),yfit(idx));

return;
end

function score = obj_function(x,p)

score = 0.0;

t = p.t;
y = p.y;
y_s = p.y_s;

y0 = x(1);
ymaxResp = x(2);
yfinal = x(3);
alpha1 = x(4);
tau1 = x(5);
alpha2 = x(6);
tau2 = x(7);
t_switch = x(8);

yfit=[];
for(i=1:length(y))
    
    if(~isnan(y(i)))
        
        yfit(i) =  double_sigmoid_function(t(i), [y0,ymaxResp,yfinal,alpha1,tau1,alpha2,tau2,t_switch]);
        %     score = score + ( (y(i) - yfit(i) )^2 );
        
        if(y_s(i)==0)
            score = score + ( (y(i) - yfit(i) )^2 );
        else
            score = score + ( (y(i) - yfit(i) )^2 )/y_s(i) ;
        end
        
    end
    
    
end

penalty=1e5;
if(alpha1 > t(p.ymaxResp_index))
    score = score + penalty;
end

if(alpha2 < t(p.ymaxResp_index))
    score = score + penalty;
end

if(t_switch < tau1 || t_switch > tau2)
    score = score + penalty;
end

if(y0<0)    
    score = score + penalty;
end

if(yfinal<0)    
    score = score + penalty;
end

if(ymaxResp<0)    
    score = score + penalty;
end

% % make sure the max response of the fitted function is near the actual response
% if(p.maxflag==1)
%     target = max(yfit); % (ymaxResp + max(yfit))/2;
% else
%     target = min(yfit); % (ymaxResp + min(yfit))/2;
% end
% if(abs(target/y(p.ymaxResp_index) - 1) > 0.05)
%     score = score + penalty*(target - y(p.ymaxResp_index))^2;
% end

% idx = ~isnan(y);
% score = -corr2(y(idx), yfit(idx));

return;
end

