function fitting_struct =  fitting_struct_to_five_state_on_off_model(fitting_struct)

% the actual kinetics
% assume A0 =1 and everything else n has n0=0


k1 = fitting_struct.k(1);
k2 = fitting_struct.k(2);
k3 = fitting_struct.k(3);
k4 = fitting_struct.k(4);

t0 = fitting_struct.t0;
t_end = fitting_struct.t_end;
t_on = fitting_struct.t_on;
t_off = fitting_struct.t_off;

for(f=1:2)
    
    if(f==1)    % continuous
        tt = fitting_struct.t;
    else  % freqs
        tt = fitting_struct.t_freq;
    end
    
    idx0 = find(tt >= t0 & tt < t_on); % before on
    idx1 = find(tt >= t_on & tt <= t_off); % while stimulus on
    idx2 = find(tt > t_off & tt <= t_end); % after stimulus off
    
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
    if(k2~=0)
        B(idx1) = k1*A0*(exp(-k1*dt) - exp(-k2*dt) )/(k2-k1);
    else
        B(idx1)=0;
    end
    C(idx1) = 1 - (A(idx1) + B(idx1));
    D(idx1)=0;
    E(idx1)=0;

    
    t = tt(idx2);
    dt = t - t_off;
    C1 = 1; % C(idx1(end));
    
    if(k3~=0)
        C(idx2) = C1*exp(-k3*dt);
    else
        C(idx2) = 1;
    end
    if(k4~=0)
        D(idx2) = k3*C1*(exp(-k3*dt) - exp(-k4*dt) )/(k4-k3);
    else
        D(idx2)=0;
    end
    A(idx2) = 0; % A(idx1(end));
    B(idx2) = 0; % B(idx1(end));
    E(idx2) = 1 - (C(idx2) + D(idx2)); % (C(idx2) + D(idx2)); % + A(idx2) + B(idx2)

   
    if(f==1)    % continuous
        fitting_struct.A = A;
        fitting_struct.B = B;
        fitting_struct.C = C;
        fitting_struct.D = D;
        fitting_struct.E = E;
    else  % freqs
        fitting_struct.A_freq = A;
        fitting_struct.B_freq = B;
        fitting_struct.C_freq = C;
        fitting_struct.D_freq = D;
        fitting_struct.E_freq = E;
    end
    
    clear('A');
    clear('B');
    clear('C');
    clear('D');
    clear('E');
    
end

y_fit = []; un_norm_y_fit = [];
for(dd=1:length(fitting_struct.data))
    
    if(fitting_struct.data(dd).inst_freq_code == 1) % instantaneaous
        A = fitting_struct.A;
        B = fitting_struct.B;
        C = fitting_struct.C;
        D = fitting_struct.D;
        E = fitting_struct.E;
    else % freq
        A = fitting_struct.A_freq;
        B = fitting_struct.B_freq;
        C = fitting_struct.C_freq;
        D = fitting_struct.D_freq;
        E = fitting_struct.E_freq;
    end
    
    
    % multiply states by intrinsic levels gamma and sum to to get signals
    fitting_struct.data(dd).y_fit = ...
        A*fitting_struct.data(dd).gamma(1) + ...
        B*fitting_struct.data(dd).gamma(2) + ...
        C*fitting_struct.data(dd).gamma(3) + ...
        D*fitting_struct.data(dd).gamma(4) + ...
        E*fitting_struct.data(dd).gamma(5);
    
    fitting_struct.data(dd).un_norm_y_fit = ...
        A*fitting_struct.data(dd).un_norm_gamma(1) + ...
        B*fitting_struct.data(dd).un_norm_gamma(2) + ...
        C*fitting_struct.data(dd).un_norm_gamma(3) + ...
        D*fitting_struct.data(dd).un_norm_gamma(4) + ...
        E*fitting_struct.data(dd).un_norm_gamma(5);
    
    y_fit = [y_fit fitting_struct.data(dd).y_fit];
    un_norm_y_fit = [un_norm_y_fit fitting_struct.data(dd).un_norm_y_fit];
end


fitting_struct.y_fit = y_fit;
fitting_struct.un_norm_y_fit = un_norm_y_fit;

return;
end
