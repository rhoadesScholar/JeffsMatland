function fitting_struct = calc_deg_freedom_fitting_struct(fitting_struct)

fitting_struct.k_df = zeros(1,length(fitting_struct.k));

fitting_struct.k_df(1) = length( find(fitting_struct.t_v >= fitting_struct.t_on & fitting_struct.t_v <= fitting_struct.t_off) ) -1;
fitting_struct.k_df(2) = length( find(fitting_struct.t_v >= fitting_struct.t_on & fitting_struct.t_v <= fitting_struct.t_off) ) -1;
fitting_struct.k_df(3) = length( find(fitting_struct.t_v >= fitting_struct.t_off & fitting_struct.t_v <= fitting_struct.t_end) ) -1;
fitting_struct.k_df(4) = length( find(fitting_struct.t_v >= fitting_struct.t_off & fitting_struct.t_v <= fitting_struct.t_end) ) -1;

fitting_struct.df = fitting_struct.k_df;
fitting_struct.real_df = [];

for(d=1:length(fitting_struct.data))
    fitting_struct.data(d).gamma_df = zeros(1,length(fitting_struct.data(d).gamma0));
    
    if(fitting_struct.data(d).inst_freq_code == 1) % instantaneous
        t = fitting_struct.t;
    else
        t = fitting_struct.t_freq;
    end
    
    fitting_struct.data(d).gamma_df(1) = length( find(t >= fitting_struct.t0 & t <= fitting_struct.t_off) ) -1;
    fitting_struct.data(d).gamma_df(2) = length( find(t >= fitting_struct.t_on & t <= fitting_struct.t_off) ) -1;
    fitting_struct.data(d).gamma_df(3) = length( find(t >= fitting_struct.t_on & t <= fitting_struct.t_end) ) -1;
    fitting_struct.data(d).gamma_df(4) = length( find(t >= fitting_struct.t_off & t <= fitting_struct.t_end) ) -1;
    fitting_struct.data(d).gamma_df(5) = length( find(t >= fitting_struct.t_off & t <= fitting_struct.t_end) ) -1;
    
    for(j=1:length(fitting_struct.data(d).gamma_df))
        fitting_struct.df = [fitting_struct.df fitting_struct.data(d).gamma_df(j)];
    end
end


return;
end
