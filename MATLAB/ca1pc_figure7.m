cd(fileparts(which(mfilename)));

%% LOAD SIMULATION OF PROXIMAL SYNAPSES
% Proximal synapses 129.92um +- 47.83std
% gm: impedance technique; sece: ge vc technique; seci: gi vc technique
proximal_gm = load('.\data\final_dynamics\gm_proximal.mat');
proximal_sece = load('.\data\final_dynamics\sece_proximal.mat');
proximal_seci = load('.\data\final_dynamics\seci_proximal.mat');


%% LOAD SIMULATION OF INTERMEDIATE SYNAPSES
% Intermediate synapses 238.69um +- 39.71std
% gm: impedance technique; sece: ge vc technique; seci: gi vc technique
intermediate_gm = load('.\data\final_dynamics\gm_intermediate.mat');
intermediate_sece = load('.\data\final_dynamics\sece_intermediate.mat');
intermediate_seci = load('.\data\final_dynamics\seci_intermediate.mat');

%% LOAD SIMULATION OF MIXED SYNAPSES
% Distal synapses 309.93um +- 164.47std
% gm: impedance technique; sece: ge vc technique; seci: gi vc technique
mixed_gm = load('.\data\final_dynamics\gm_mixed.mat');
mixed_sece = load('.\data\final_dynamics\sece_mixed.mat');
mixed_seci = load('.\data\final_dynamics\seci_mixed.mat');

%% ISOLATE CONDUCTANCES 
FILTP = [20 0.0001 3 0.92];
searchtime = [0.3 0.6];
[ge_proximal,gi_proximal,VC_proximal,~] = ...
                                      find_gegi(proximal_gm.V(1:end-1),...
                                      proximal_gm.ac*1e-9,...
                                      1/proximal_gm.dt,...
                                      proximal_gm.reversals,...
                                      searchtime,...
                                      'FILTP', FILTP);
[ge_intermediate,gi_intermediate,VC_intermediate,~] = ...
                                      find_gegi(...
                                      intermediate_gm.V(1:end-1),...
                                      intermediate_gm.ac*1e-9,...
                                      1/intermediate_gm.dt,...
                                      intermediate_gm.reversals,...
                                      searchtime,...
                                      'FILTP', FILTP);
[ge_mixed,gi_mixed,VC_mixed,~] = ...
                                      find_gegi(mixed_gm.V(1:end-1),...
                                      mixed_gm.ac*1e-9,...
                                      1/mixed_gm.dt,...
                                      mixed_gm.reversals,...
                                      searchtime,...
                                      'FILTP', FILTP);

%% PLOTTING
%Plotting parameters
ylim_voltage = [-80.0, -45.0];
ylim_ge = [-1, 3];
ylim_gi = [-5, 20];
xlim_all = [0.7, 1.9];
fontsize = 12;
nS_factor = 1e9;  % Convert S to nS
mV_factor = 1e3;  % Convert V to mV
nA_factor = 1e9;  %Convert nA to A
fig_rows = 3;
fig_cols = 3;
t = ((0:length(proximal_gm.V)-2)) * proximal_gm.dt;

% Figure header. Thanks to Martin Pofahl.
figure('color', [1 1 1],...
       'renderer', 'painters',...
       'visible','on',...
       'Units','centimeters',...
       'position',[20 5 [29.7/sqrt(2) 29.7]],...
       'PaperUnits','centimeters',...
       'PaperSize',[29.7/sqrt(2) 29.7])
hold on;
%% PLOT PROXIMAL RESULTS
subplot(fig_rows, fig_cols, 1);
hold on;
plot(t, proximal_gm.V(1:end-1)*mV_factor,'linewidth',1);
plot(t, VC_proximal*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Proximal Inputs');
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 2);
hold on;
plot(t, ge_proximal*nS_factor, 'linewidth',1);
plot(t, proximal_gm.total_ge(1:end-1)*nS_factor,'linewidth',1);
plot(t, (proximal_sece.g(1:end-1)-mean(proximal_sece.g(1:1000)))*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 3);
hold on;
plot(t, gi_proximal*nS_factor, 'linewidth',1);
plot(t, proximal_gm.total_gi(1:end-1)*nS_factor,'linewidth',1);
plot(t, (proximal_seci.g(1:end-1)-mean(proximal_seci.g(1:1000)))*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_gi);
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

%% PLOT INTERMEDIATE RESULTS
subplot(fig_rows, fig_cols, 4);
hold on;
plot(t, intermediate_gm.V(1:end-1)*mV_factor, 'linewidth',1);
plot(t, VC_intermediate*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Intermediate Inputs');
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 5);
hold on;
plot(t, ge_intermediate*nS_factor, 'linewidth',1);
plot(t, intermediate_gm.total_ge(1:end-1)*nS_factor, 'linewidth',1);
plot(t, ...
(intermediate_sece.g(1:end-1)-mean(intermediate_sece.g(1:1000)))*nS_factor,...
'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 6);
hold on;
plot(t, gi_intermediate*nS_factor, 'linewidth',1);
plot(t, intermediate_gm.total_gi(1:end-1)*nS_factor,'linewidth',1);
plot(t, ...
(intermediate_seci.g(1:end-1)-mean(intermediate_seci.g(1:1000)))*nS_factor,...
'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_gi);
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

%% PLOT MIXED RESULTS
subplot(fig_rows, fig_cols, 7);
hold on;
plot(t, mixed_gm.V(1:end-1)*mV_factor, 'linewidth',1);
plot(t, VC_mixed*mV_factor, 'linewidth',1);
legend('Unfiltered', 'Filtered');
xlim(xlim_all);
ylim(ylim_voltage);
xlabel('time (s)');
ylabel('Voltage (mV)');
title('Voltage Distal Inputs');
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 8);
hold on;
plot(t, ge_mixed*nS_factor, 'linewidth',1);
plot(t,mixed_gm.total_ge(1:end-1)*nS_factor,'linewidth',1);
plot(t, (mixed_sece.g(1:end-1)-mean(mixed_sece.g(1:1000)))*nS_factor, 'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge", "Voltage Clamped ge");
set(gca,'fontsize',fontsize);

subplot(fig_rows, fig_cols, 9);
hold on;
plot(t, gi_mixed*nS_factor, 'linewidth',1);
plot(t,mixed_gm.total_gi(1:end-1)*nS_factor,'linewidth',1);
plot(t, (mixed_seci.g(1:end-1)-mean(mixed_seci.g(1:1000)))*nS_factor, 'linewidth',1);
ylim(ylim_gi);
ylabel("Conductance (nS)");
xlim(xlim_all);
legend("Measured gi", "Actual gi", "Voltage Clamped gi");
set(gca,'fontsize',fontsize);

%% PRINT FIGURE
print(gcf, '-dpdf', 'figure7_matlab_out.pdf')