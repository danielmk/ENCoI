load('gm_somatic_nodendrites.mat');

%reversals =[-0.065 0.00 -0.08];
FILTP = [20 0.0001 3 0.92]; % [DFF, dst, NC, STF1]
%reversals(3) = -0.09
[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
voltage_cleaned_nodendrites = VC
current = ac*1e-9;

load('sece_somatic_nodendrites.mat')
ge_vclamp = g - mean(g(1:1000));
load('seci_somatic_nodendrites.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
fig_rows = 2
fig_cols = 3
subplot(fig_rows, fig_cols, 1)
hold on;
plot(t, voltage, 'linewidth',1)
plot(t, VC, 'linewidth',1)
legend('Unfiltered', 'Filtered')
xlim([0.7, 1.5])
ylim([-0.25 0.12])
xlabel('time (s)')
ylabel('Voltage (V)')
title('Voltage No Dendrites Somatic Inputs')
subplot(fig_rows, fig_cols, 2)
hold on;
plot(t, ge_measured, 'linewidth',1)
plot(t, ge_actual(1:end-1), 'linewidth',1)
plot(t, ge_vclamp(1:end-1), 'linewidth',1)
xlim([0.7, 1.5])
legend("Measured ge", "Actual ge", "Voltage Clamped ge")
subplot(fig_rows, fig_cols, 3)
hold on;
plot(t, gi_measured, 'linewidth',1)
plot(t, gi_actual(1:end-1), 'linewidth',1)
plot(t, gi_vclamp(1:end-1), 'linewidth',1)
xlim([0.7, 1.5])
legend("Measured gi", "Actual gi", "Voltage Clamped gi")

load('gm_somatic_withdendrites.mat');

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi(V(1:end-1),ac*1e-9,1/dt,[0 reversals(2) reversals(3)],[0.3 0.6], 'FILTP', FILTP);

voltage_cleaned_withdendrites = VC

t = ((0:length(V)-2)) * dt;
ge_actual = total_ge;
gi_actual = total_gi;
ge_measured = ge;
gi_measured = gi;
voltage = V(1:end-1);
current = ac*1e-9;

load('sece_somatic_withdendrites.mat')
ge_vclamp = g - mean(g(1:1000));
load('seci_somatic_withdendrites.mat')
gi_vclamp = g - mean(g(1:1000));

% total_ge and total_gi are NOT the voltage clamped conductances
% I'll need to run separate simulations to get those
subplot(fig_rows, fig_cols, 4)
hold on;
plot(t, voltage, 'linewidth',1)
plot(t, VC, 'linewidth',1)
legend('Unfiltered', 'Filtered')
xlim([0.7, 1.5])
ylim([-0.25 0.12])
xlabel('time (s)')
ylabel('Voltage (V)')
title('Voltage With Dendrites Somatic Inputs')
subplot(fig_rows, fig_cols, 5)
hold on;
plot(t, ge_measured, 'linewidth',1)
plot(t, ge_actual(1:end-1), 'linewidth',1)
plot(t, ge_vclamp(1:end-1), 'linewidth',1)
xlim([0.7, 1.5])
legend("Measured ge", "Actual ge", "Voltage Clamped ge")
subplot(fig_rows, fig_cols, 6)
hold on;
plot(t, gi_measured, 'linewidth',1)
plot(t, gi_actual(1:end-1), 'linewidth',1)
plot(t, gi_vclamp(1:end-1), 'linewidth',1)
xlim([0.7, 1.5])
legend("Measured gi", "Actual gi", "Voltage Clamped gi")