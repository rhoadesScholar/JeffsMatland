%%%%%% Inputs to this function are Inp, which is a vector of length x,
%%%%%% where x is the length of Ie in milliseconds, and the intensity of
%%%%%% the current is the value at Inp(x).
%%%%%% Since it's desirable to try different deltat's in the Euler method,
%%%%%% deltat is also give as input.  The units of deltat is seconds,
%%%%%% though, to be consistent with other units below.

function [rate_IandF rate_Quad_IandF rate_Exp_IandF] = calculateRates(Inp,deltat)

E = -0.065; %V
Vreset = -0.065; %V
Vth = -0.050; %V
tc = .010; %sec
Rm = 10000000; %ohms
deltaq = .0025; %V
deltae = .005; %V
Vt = -.055; %V
Vmax = .030; %V


deltat_In_milliseconds = deltat*1000; %%%%deltat is in seconds, but input is in milliseconds, so convert for ease
nBins = length(Inp)/deltat_In_milliseconds;   

%%%%%Implement IandF model
spikes_IandF = 0; %%%Spike Counter for IandF model
Vorig = E;
F = 0;

for(i=deltat_In_milliseconds:deltat_In_milliseconds:(deltat_In_milliseconds*nBins))
    Current = Inp(round(i));  %%%Get current at this time bin
    Vnew = Vorig + (E-Vorig+F+(Rm*Current))*(deltat/tc); 
    if(Vnew>=Vth)
        Vorig = E;
        spikes_IandF = spikes_IandF + 1;
    else
    Vorig=Vnew;
    end
end


%%%%Implement Quadratic IandF

spikes_Quad_IandF = 0;
Vorig = E;


for(i=deltat_In_milliseconds:deltat_In_milliseconds:(deltat_In_milliseconds*nBins))
    Current = Inp(round(i));
    F = ((Vorig-E)^2)/deltaq;
    Vnew = Vorig + (E-Vorig+F+(Rm*Current))*(deltat/tc);
    if(Vnew>=Vmax)
        Vorig = E;
        spikes_Quad_IandF = spikes_Quad_IandF+1;
    else
        Vorig=Vnew;
    end
end

%%%%Implement Exponential IandF

spikes_Exp_IandF = 0;
Vorig = E;

for(i=deltat_In_milliseconds:deltat_In_milliseconds:(deltat_In_milliseconds*nBins))
    Current = Inp(round(i));
    F = deltae*(exp((Vorig-Vt)/deltae));
    Vnew = Vorig + (E-Vorig+F+(Rm*Current))*(deltat/tc);
    if(Vnew>=Vmax)
        Vorig = E;
        spikes_Exp_IandF = spikes_Exp_IandF+1;
    else
    Vorig=Vnew;
    end
end

%%%%Calculate rates, in Hz
rate_IandF = (spikes_IandF/length(Inp))/1000;  
rate_Quad_IandF = (spikes_Quad_IandF/length(Inp))/1000;
rate_Exp_IandF = (spikes_Exp_IandF/length(Inp))/1000;

end

%%%%%%%%To use this function to investigate firing rates provided by the
%%%%%%%%three models, I'm giving inputs 1 second current pulses ranging
%%%%%%%%from 0.5 to 10 nA below and calculating the different rates
% x = [.0000000005 .000000001 .000000002 .000000003 .000000004 .000000005 .000000006 .000000007 .000000008 .000000009]
% for(j=1:10)
%     Inp(1:1000) = x(j);
%     [rate_IandF(j) rate_Quad_IandF(j) rate_Exp_IandF(j)] = calculateRates(Inp,.001)
% end
%plot(x,rate_IandF); hold on; plot(x,rate_Quad_IandF); hold on;
%plot(x,rate_Exp_IandF); %%%%Then would need to change the colors, etc etc

 


