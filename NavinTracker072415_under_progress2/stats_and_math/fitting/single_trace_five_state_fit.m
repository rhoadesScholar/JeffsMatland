function [fitted_values, ss, r, y_fit] = single_trace_five_state_fit(t, t_on, t_off, y, initial_guess, usage_vector)
% [fitted_values, ss, r, y_fit] = single_trace_five_state_fit(t, t_on, t_off, y, initial_guess, usage_vector)

fitting_struct.t = t;
fitting_struct.y = y;
fitting_struct.t0 = t(1);
fitting_struct.t_on = t_on;
fitting_struct.t_off = t_off;
fitting_struct.t_end = t(end);

if(nargin<5)
    error('not enough values for the initial guess ....');
end

if(nargin<6)
    usage_vector = ones(1,9);
end

if(length(initial_guess)<9)
    error('not enough values for the initial guess ....');
end

fitting_struct.usage_vector = usage_vector;
fitting_struct.max_k = 1000*max(y);
fitting_struct.min_k = 0; % 1e-4;

m = initial_guess;
for(i=1:length(usage_vector))
    if(fitting_struct.usage_vector(i) == 0)
        m0(i)=0;
        m(i)=0;
    end
end


mfe = 10000*length(initial_guess); 
fminsearchoptions = optimset('MaxFunEvals',mfe,'MaxIter',mfe,'TolFun',1e-4,'Display','off');

m = fminsearch(@(m) score_five_state_on_off_single_data(m,fitting_struct), initial_guess, fminsearchoptions);

fitted_values = m;
k = m(1:4);
gamma = m(5:end);
y_fit = five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, k, gamma);

ss = nansum((fitting_struct.y - y_fit).^2) + 10000*(sum(isnan(y_fit))^2 );
r = corr2(fitting_struct.y, y_fit);

figure;
plot(t,y,'ob');
hold on;
plot(t,y_fit,'g');

return;
end


function score =  score_five_state_on_off_single_data(m, fitting_struct)

t = fitting_struct.t;

% set unused variables to zero and put limits
for(i=1:4)
    if(fitting_struct.usage_vector(i) == 0)
        m(i)=0;
    else
        if(m(i)<0)
            m(i) = abs(m(i));
        end
        if(m(i) > fitting_struct.max_k)
            m(i) =  fitting_struct.max_k;
        end
        if(m(i)<fitting_struct.min_k)
            m(i)=fitting_struct.min_k;
        end
    end
end

for(i=5:length(fitting_struct.usage_vector))
    if(fitting_struct.usage_vector(i) == 0)
        m(i) = 0;
    end
end


k = m(1:4);
gamma = m(5:end);

y_fit =  five_state_on_off(t, fitting_struct.t0, fitting_struct.t_end, fitting_struct.t_on, fitting_struct.t_off, k, gamma);

score = nansum((fitting_struct.y - y_fit).^2) + 10000*(sum(isnan(y_fit))^2 );

return;
end


function [y_fit,A,B,C,D,E] =  five_state_on_off(t, t0, t_end, t_on, t_off,k,gamma)

k1 = k(1);
k2 = k(2);
k3 = k(3);
k4 = k(4);


tt = t;

idx0 = find(tt >= t0 & tt <= t_on); % before on
idx1 = find(tt >= t_on & tt <= t_off); % while stimulus on
idx2 = find(tt >= t_off & tt <= t_end); % after stimulus off


    if(k1~=0)
        A0=1; 
    else
        A0=0;
    end
    
    B0=0; 
    
    if(k1~=0)
        C0=0;
    else
        C0=1;
    end
    
    D0=0; E0=0;


A(idx0) = A0;
B(idx0) = B0;
C(idx0) = C0;
D(idx0) = D0;
E(idx0) = E0;

t = tt(idx1);
dt = t - t_on;

if(k1~=0)
    A(idx1) = A0*exp(-k1*dt);
else
    A(idx1) = 0;
end
if(k2>0)
    B(idx1) = k1*A0*(exp(-k1*dt) - exp(-k2*dt) )/(k2-k1);
else
    B(idx1)=0;
end
C(idx1) = 1 - (A(idx1) + B(idx1));
D(idx1)=0;
E(idx1)=0;

t = tt(idx2);
dt = t - t_off;
C1 = 1; % 1; % C(idx1(end));

C(idx2) = C1*exp(-k3*dt);
if(k4>0)
    D(idx2) = k3*C1*(exp(-k3*dt) - exp(-k4*dt) )/(k4-k3);
else
    D(idx2)=0;
end
A(idx2) = 0; % 0; % A(idx1(end));
B(idx2) = 0; % 0; % B(idx1(end));

E(idx2) = 1 - (C(idx2) + D(idx2) ); % + A(idx2) + B(idx2)

% multiply states by intrinsic levels gamma and sum to to get signals
y_fit = ...
    A*gamma(1) + ...
    B*gamma(2) + ...
    C*gamma(3) + ...
    D*gamma(4) + ...
    E*gamma(5);

return;
end


