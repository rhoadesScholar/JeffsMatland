%recurrently connected network of 2 neurons
%Note on notation: code below uses v for firing rates, M for recurrent
%weight matrix (rather than r and W) as in Dayan & Abbott text

clear all;
close all;

%PARAMETERS
dt = 0.1; %[ms]
t_max = 500; %[ms] %1000
tau = 20; %[ms]

%RECURRENT MATRIX AND EIGENVECTS/VALS OF IT
W_mat = [0.0 0.5; 0.5 0.0]; %[0.8 0; 0 -.6] good for cartesian; [0 0.7; 0.7 0] or [0 0.5;0.5 0] good for exc. pos fdbk 
[Eigenvects,Eigenvals] = eig(W_mat)
AmplifyFactors = 1./(1 - diag(Eigenvals))
eigvect1 = Eigenvects(:,1)
eigvect2 = Eigenvects(:,2)

%ASSIGN I VALUES HERE
I = 1*(-0.5*Eigenvects(:,1)+ 0.5*Eigenvects(:,2)); %assign I in terms of components along each eigenvector
I_InNewBasis = inv(Eigenvects)*I;  %inverse of Eigenvector matrix is change of basis matrix
I_e1_vect = I_InNewBasis(1)*eigvect1; %component of I along 1st eigenvector, for plots
I_e2_vect = I_InNewBasis(2)*eigvect2; %component of I along 2nd eigenvector, for plots

%INITIALIZATIONS
t_vect = 0:dt:t_max;
v1_vect = zeros(1,length(t_vect)); %firing rate of first neuron over time
v2_vect = zeros(1,length(t_vect)); %firing rate of 2nd neuron over time

i=1;
v1_vect(1) = 1.3*I(1); %initial value of 1st neuron's firing rate
v2_vect(1) = 1.3*I(2); %initial value of 2nd neuron's firing rate
for t=dt:dt:t_max
   i = i+1;
   v1_inf = I(1) + W_mat(1,1)*v1_vect(i-1) + W_mat(1,2)*v2_vect(i-1); 
   v2_inf = I(2) + W_mat(2,1)*v1_vect(i-1) + W_mat(2,2)*v2_vect(i-1); 
   v1_vect(i) = v1_inf + (v1_vect(i-1) - v1_inf)*exp(-dt/tau);
   v2_vect(i) = v2_inf + (v2_vect(i-1) - v2_inf)*exp(-dt/tau);
end

figure(1)
%subplot(2,1,1)
plot(t_vect,[v1_vect; v2_vect])
%hold on
%plot(t_vect,[I(1)*ones(1,length(t_vect)); I(2)*ones(1,length(t_vect))],'--')
xlabel('Time','fontsize',12)
%ylabel('Dashed: I_1(blue), I_2(green); Solid: v_1(blue), v_2(green)','fontsize',12)
ylabel('r_1(blue), r_2(green)','fontsize',12)

figure(2)
NumPanels = 4
for i=1:NumPanels
    subplot(NumPanels,1,i)
    if (i==NumPanels)
        xlabel('First component of vector')
    end
    ylabel('2nd component')
end
subplot(4,1,1)
line([0 eigvect1(1)], [0 eigvect1(2)],'linewidth',6,'Color',[1 0 0])
line([0 eigvect2(1)], [0 eigvect2(2)],'linewidth',6,'Color',[1 0 0])
title('Step 1: Find eigenvectors of W','FontSize',12)
legend('eigenvect1','eigenvect2',-1)
set(gca,'XTick',-1:1:1)
axis equal
subplot(4,1,2)
line([0 eigvect1(1)], [0 eigvect1(2)],'linewidth',6,'Color',[1 0 0])
line([0 eigvect2(1)], [0 eigvect2(2)],'linewidth',6,'Color',[1 0 0])
line([0 I(1)],[0 I(2)],'linewidth',3,'LineStyle','-','Color',[0 1 1])
line([0 I_e1_vect(1)],[0 I_e1_vect(2)],'linewidth',3,'LineStyle',':','Color',[0 1 1])
line([0 I_e2_vect(1)],[0 I_e2_vect(2)],'linewidth',3,'LineStyle',':','Color',[0 1 1])
title('Step 2: Decompose I into its components along eigenvectors','FontSize',12)
legend('eigenvect1','eigenvect2','Input vector I','Components of I',-1)
set(gca,'XTick',-1:1:1)
axis equal
subplot(4,1,3)
line([0 eigvect1(1)], [0 eigvect1(2)],'linewidth',6,'Color',[1 0 0])
line([0 eigvect2(1)], [0 eigvect2(2)],'linewidth',6,'Color',[1 0 0])
line([0 I(1)],[0 I(2)],'linewidth',3,'LineStyle','-','Color',[0 1 1])
line([0 AmplifyFactors(1)*I_e1_vect(1)],[0 AmplifyFactors(1)*I_e1_vect(2)],'linewidth',3,'LineStyle',':')%,'Color',[0 1 1])
line([0 AmplifyFactors(2)*I_e2_vect(1)],[0 AmplifyFactors(2)*I_e2_vect(2)],'linewidth',3,'LineStyle',':')%,'Color',[0 1 1])
title('Step 3: Stretch components of I to get components of r_{inf}','FontSize',12)
legend('eigenvect1','eigenvect2','Input vector I','Components of r_{inf}',-1)
set(gca,'XTick',-1:1:1)
axis equal
subplot(4,1,4)
h(1)=line([0 eigvect1(1)], [0 eigvect1(2)],'linewidth',6,'Color',[1 0 0])
h(2)=line([0 eigvect2(1)], [0 eigvect2(2)],'linewidth',6,'Color',[1 0 0])
h(3)=line([0 I(1)],[0 I(2)],'linewidth',3,'LineStyle','-','Color',[0 1 1])
h(4)=line([0 AmplifyFactors(1)*I_e1_vect(1)],[0 AmplifyFactors(1)*I_e1_vect(2)],'linewidth',3,'LineStyle',':');% 1st comp.
line([0 AmplifyFactors(2)*I_e2_vect(1)],[0 AmplifyFactors(2)*I_e2_vect(2)],'linewidth',3,'LineStyle',':');% 2nd comp.
h(5)=line([0 AmplifyFactors(1)*I_e1_vect(1)+AmplifyFactors(2)*I_e2_vect(1)],...
       [0 AmplifyFactors(1)*I_e1_vect(2)+AmplifyFactors(2)*I_e2_vect(2)],'linewidth',3,'LineStyle','-');% total response
title('Step 4: Sum back together components of r_{inf}','FontSize',12)
legend(h,'eigenvect1','eigenvect2','Input vector I','Components of r_{inf}','r_{inf} vector','Response vect',-1)
axis equal

figure(3)
g(1)=line([0 eigvect1(1)], [0 eigvect1(2)],'linewidth',6,'Color',[1 0 0])
g(2)=line([0 eigvect2(1)], [0 eigvect2(2)],'linewidth',6,'Color',[1 0 0])
g(3)=line([0 I(1)],[0 I(2)],'linewidth',3,'LineStyle','-','Color',[0 1 1])
g(4)=line([0 AmplifyFactors(1)*I_e1_vect(1)],[0 AmplifyFactors(1)*I_e1_vect(2)],'linewidth',3,'LineStyle',':');%,'Color',[1 0 1])
line([0 AmplifyFactors(2)*I_e2_vect(1)],[0 AmplifyFactors(2)*I_e2_vect(2)],'linewidth',3,'LineStyle',':');%,'Color',[1 0 1])
g(5)=line([0 AmplifyFactors(1)*I_e1_vect(1)+AmplifyFactors(2)*I_e2_vect(1)],...
       [0 AmplifyFactors(1)*I_e1_vect(2)+AmplifyFactors(2)*I_e2_vect(2)],'linewidth',3,'LineStyle','-');%,'Color',[1 0 1])
hold on
g(6)=plot(v1_vect,v2_vect,'g','linewidth',2) %trajectory plot
title('Step 5: Firing rate trajectories: fast attenuation, slow amplification','FontSize',12)
xlabel('First component of vector')
ylabel('2nd component of vector')
legend(g,'eigenvect1','eigenvect2','Input vector I','Components of r_{inf}','r_{inf} vector','Response vect','firing rates trajectory',-1)
axis equal

figure(2)

