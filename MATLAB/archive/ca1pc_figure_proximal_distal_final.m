cd(fileparts(which(mfilename)));

% Proximal synapses 129.63um +- 48.20std
% Intermediate synapses 160.79um +- 37.77std
% Distal synapses 497.23um +- 100.45std

%Plotting parameters
ylim_voltage = [-0.08, -0.035]
ylim_ge = [-2e-9, 7e-9]
ylim_gi = [-5e-9, 20e-9]
xlim_all = [0.7, 1.5]

% Intermediate
load('.\data\final\gm_proximal.mat');

FILTP = [20 0.0001 3 0.92]; % [DFF, dst, NC, STF1]
%reversals(3) = -0.09
[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi_experimental_DMK(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
voltage_cleaned_nodendrites = VC;
current = ac*1e-9;

load('.\data\final\sece_proximal.mat')
ge_vclamp = g - mean(g(1:1000));
load('.\data\final\seci_proximal.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
fig_rows = 3
fig_cols = 3
subplot(fig_rows, fig_cols, 1)
hold on;
plot(t, voltage, 'linewidth',1)
plot(t, VC, 'linewidth',1)
legend('Unfiltered', 'Filtered')
xlim(xlim_all)
ylim(ylim_voltage)
xlabel('time (s)')
ylabel('Voltage (V)')
title('Voltage Proximal Inputs')
subplot(fig_rows, fig_cols, 2)
hold on;
plot(t, ge_measured, 'linewidth',1)
plot(t, ge_actual(1:end-1), 'linewidth',1)
plot(t, ge_vclamp(1:end-1), 'linewidth',1)
ylabel("Conductance (S)")
ylim(ylim_ge)
xlim(xlim_all)
legend("Measured ge", "Actual ge", "Voltage Clamped ge")
subplot(fig_rows, fig_cols, 3)
hold on;
plot(t, gi_measured, 'linewidth',1)
plot(t, gi_actual(1:end-1), 'linewidth',1)
plot(t, gi_vclamp(1:end-1), 'linewidth',1)
ylabel("Conductance (S)")
ylim(ylim_gi)
xlim(xlim_all)
legend("Measured gi", "Actual gi", "Voltage Clamped gi")

%%
load('.\data\final\gm_intermediate.mat');

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi_experimental_DMK(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

voltage_cleaned_withdendrites = VC;

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
current = ac*1e-9;

load('.\data\final\sece_intermediate.mat')
ge_vclamp = g - mean(g(1:1000));

load('.\data\final\seci_intermediate.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
subplot(fig_rows, fig_cols, 4)
hold on;
plot(t, voltage, 'linewidth',1)
plot(t, VC, 'linewidth',1)
legend('Unfiltered', 'Filtered')
xlim(xlim_all)
ylim(ylim_voltage)
xlabel('time (s)')
ylabel('Voltage (V)')
title('Voltage Intermediate Inputs')
subplot(fig_rows, fig_cols, 5)
hold on;
plot(t, ge_measured, 'linewidth',1)
plot(t, ge_actual(1:end-1), 'linewidth',1)
plot(t, ge_vclamp(1:end-1), 'linewidth',1)
ylabel("Conductance (S)")
ylim(ylim_ge)
xlim(xlim_all)
legend("Measured ge", "Actual ge", "Voltage Clamped ge")
subplot(fig_rows, fig_cols, 6)
hold on;
plot(t, gi_measured, 'linewidth',1)
plot(t, gi_actual(1:end-1), 'linewidth',1)
plot(t, gi_vclamp(1:end-1), 'linewidth',1)
ylabel("Conductance (S)")
ylim(ylim_gi)
xlim(xlim_all)
legend("Measured gi", "Actual gi", "Voltage Clamped gi")

%%
load('.\data\final\gm_distal.mat');

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi_experimental_DMK(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

voltage_cleaned_withdendrites = VC;

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
current = ac*1e-9;

load('.\data\final\sece_distal.mat')
ge_vclamp = g - mean(g(1:1000));

load('.\data\final\seci_distal.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
subplot(fig_rows, fig_cols, 7)
hold on;
plot(t, voltage, 'linewidth',1)
plot(t, VC, 'linewidth',1)
legend('Unfiltered', 'Filtered')
xlim(xlim_all)
ylim(ylim_voltage)
xlabel('time (s)')
ylabel('Voltage (V)')
title('Voltage Distal Inputs')
subplot(fig_rows, fig_cols, 8)
hold on;
plot(t, ge_measured, 'linewidth',1)
plot(t, ge_actual(1:end-1), 'linewidth',1)
plot(t, ge_vclamp(1:end-1), 'linewidth',1)
ylabel("Conductance (S)")
ylim(ylim_ge)
xlim(xlim_all)
legend("Measured ge", "Actual ge", "Voltage Clamped ge")
subplot(fig_rows, fig_cols, 9)
hold on;
plot(t, gi_measured, 'linewidth',1)
plot(t, gi_actual(1:end-1), 'linewidth',1)
plot(t, gi_vclamp(1:end-1), 'linewidth',1)
ylim(ylim_gi)
ylabel("Conductance (S)")
xlim(xlim_all)
legend("Measured gi", "Actual gi", "Voltage Clamped gi")