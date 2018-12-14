A = A0*exp(-k1*t)
    
B = -((A0*(exp(-k1*t)-exp(-k2*t))*k1)/(k1-k2))

C = (A0*exp(-(k1+k2+k3)*t)*k1*k2*(exp((k1+k2)*t)*(k1-k2)+exp((k2+k3)*t)*(k2-k3)+exp((k1+k3)*t)*(-k1+k3)))/((k1-k2)*(k1-k3)*(k2-k3))

D = (A0*exp(-(k1+k2+k3+k4)*t)*k1*k2*k3*(exp((k1+k2+k3)*t)*(k1-k2)*(k1-k3)*(k2-k3)-exp((k1+k2+k4)*t)*(k1-k2)*(k1-k4)*(k2-k4)+exp((k1+k3+k4)*t)*(k1-k3)*(k1-k4)*(k3-k4)-exp((k2+k3+k4)*t)*(k2-k3)*(k2-k4)*(k3-k4)))/((k1-k2)*(k1-k3)*(k2-k3)*(k1-k4)*(k2-k4)*(k3-k4))


E = (A0*exp(-(k1+k2+k3+k4)*t)*(-exp((k1+k2+k3)*t)*k1*(k1-k2)*k2*(k1-k3)*(k2-k3)*k3+exp((k1+k2+k3+k4)*t)*(k1-k2)*(k1-k3)*(k2-k3)*(k1-k4)*(k2-k4)*(k3-k4)+exp((k1+k2+k4)*t)*k1*(k1-k2)*k2*(k1-k4)*(k2-k4)*k4-exp((k1+k3+k4)*t)*k1*(k1-k3)*k3*(k1-k4)*(k3-k4)*k4+exp((k2+k3+k4)*t)*k2*(k2-k3)*k3*(k2-k4)*(k3-k4)*k4))/((k1-k2)*(k1-k3)*(k2-k3)*(k1-k4)*(k2-k4)*(k3-k4))
