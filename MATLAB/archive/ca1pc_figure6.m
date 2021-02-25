cd(fileparts(which(mfilename)));

% Proximal synapses 129.92um +- 47.83std
% Intermediate synapses 238.69um +- 39.71std
% Distal synapses 497.79um +- 96.15std

%Plotting parameters
ylim_voltage = [-80.0, -45.0];
ylim_ge = [-1, 3];
ylim_gi = [-5, 20];
xlim_all = [0.7, 1.9];
fontsize = 12;
nS_factor = 1e9
mV_factor = 1e3

% Intermediate
load('.\data\final_dynamics\gm_proximal.mat');

FILTP = [20 0.0001 3 0.92]; % [DFF, dst, NC, STF1]
[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
voltage_cleaned_nodendrites = VC;
current = ac*1e-9;

load('.\data\final_dynamics\sece_proximal.mat')
ge_vclamp = g - mean(g(1:1000));
load('.\data\final_dynamics\seci_proximal.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
fig_rows = 3;
fig_cols = 3;
% Martin figure header
figure('color', [1 1 1],...
       'renderer', 'painters',...
       'visible','on',...
       'Units','centimeters',...
       'position',[20 5 [29.7/sqrt(2) 29.7]],...
       'PaperUnits','centimeters',...
       'PaperSize',[29.7/sqrt(2) 29.7])
%figure;
hold on;
subplot(fig_rows, fig_cols, 1);
hold on;
plot(t, voltage*mV_factor, 'linewidth',1);
plot(t, VC*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Proximal Inputs');
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 2);
hold on;
plot(t, ge_measured*nS_factor, 'linewidth',1);
plot(t, ge_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, ge_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 3);
hold on;
plot(t, gi_measured*nS_factor, 'linewidth',1);
plot(t, gi_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, gi_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_gi);
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

%%
load('.\data\final_dynamics\gm_intermediate.mat');

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

voltage_cleaned_withdendrites = VC;

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
current = ac*1e-9;

load('.\data\final_dynamics\sece_intermediate.mat');
ge_vclamp = g - mean(g(1:1000));

load('.\data\final_dynamics\seci_intermediate.mat');
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
subplot(fig_rows, fig_cols, 4);
hold on;
plot(t, voltage*mV_factor, 'linewidth',1);
plot(t, VC*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Intermediate Inputs');
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 5);
hold on;
plot(t, ge_measured*nS_factor, 'linewidth',1);
plot(t, ge_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, ge_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 6);
hold on;
plot(t, gi_measured*nS_factor, 'linewidth',1);
plot(t, gi_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, gi_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_gi);
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

%%
load('.\data\final_dynamics\gm_distal.mat');

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

voltage_cleaned_withdendrites = VC;

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
current = ac*1e-9;

load('.\data\final_dynamics\sece_distal.mat');
ge_vclamp = g - mean(g(1:1000));

load('.\data\final_dynamics\seci_distal.mat');
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
subplot(fig_rows, fig_cols, 7);
hold on;
plot(t, voltage*mV_factor, 'linewidth',1);
plot(t, VC*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Distal Inputs');
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 8);
hold on;
plot(t, ge_measured*nS_factor, 'linewidth',1);
plot(t, ge_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, ge_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);
subplot(fig_rows, fig_cols, 9);
hold on;
plot(t, gi_measured*nS_factor, 'linewidth',1);
plot(t, gi_actual(1:end-1)*nS_factor, 'linewidth',1);
plot(t, gi_vclamp(1:end-1)*nS_factor, 'linewidth',1);
ylim(ylim_gi);
ylabel("Conductance (nS)");
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

print(gcf, '-dpdf', 'figure6.pdf')