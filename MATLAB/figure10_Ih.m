cd(fileparts(which(mfilename)));

%% LOAD SIMULATION OF PROXIMAL SYNAPSES
gm_Ih = load('.\data\active_currents\gm_proximal_Ih.mat');
gm_noIh = load('.\data\active_currents\gm_proximal_noIh.mat');

%% ISOLATE CONDUCTANCES 
FILTP = [20 0.0001 3 0.92];
searchtime = [0.3 0.6];
[ge_Ih,gi_Ih,VC_Ih,~] = ...
                                      find_gegi(gm_Ih.V(1:end-1),...
                                      gm_Ih.ac*1e-9,...
                                      1/gm_Ih.dt,...
                                      gm_Ih.reversals,...
                                      searchtime,...
                                      'FILTP', FILTP);
                                  
[ge_noIh,gi_noIh,VC_noIh,~] = ...
                                      find_gegi(gm_noIh.V(1:end-1),...
                                      gm_noIh.ac*1e-9,...
                                      1/gm_noIh.dt,...
                                      gm_noIh.reversals,...
                                      searchtime,...
                                      'FILTP', FILTP);

%% PLOTTING
%Plotting parameters
ylim_voltage = [-80.0, -45.0];
ylim_ge = [-1, 3];
ylim_gi = [-5, 20];
xlim_all = [0.0, 1.2];
t_start = 0.7;
fontsize = 12;
nS_factor = 1e9;  % Convert S to nS
mV_factor = 1e3;  % Convert V to mV
nA_factor = 1e9;  %Convert nA to A
fig_rows = 3;
fig_cols = 3;
t = ((0:length(gm_Ih.V)-2)) * gm_Ih.dt;
t = t - t_start;

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
subplot(2,1,1);
hold on;
plot(t, ge_noIh*nS_factor, 'linewidth',1);
plot(t, gm_noIh.total_ge(1:end-1)*nS_factor,'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge");
set(gca,'fontsize',fontsize);
set(gca,'TickDir','out');
set(gca,'XTick', xlim_all(1):0.4:xlim_all(2));
xtickformat('%.1f');

subplot(2,1,2);
hold on;
plot(t, ge_Ih*nS_factor, 'linewidth',1);
plot(t, gm_Ih.total_ge(1:end-1)*nS_factor,'linewidth',1);
ylabel("Conductance (nS)");
ylim(ylim_ge);
xlim(xlim_all);
legend("Measured ge", "Actual ge");
set(gca,'fontsize',fontsize);
set(gca,'TickDir','out');
set(gca,'XTick', xlim_all(1):0.4:xlim_all(2));
xtickformat('%.1f');
%% PRINT FIGURE
print(gcf, '-dpdf', 'figure7_matlab_out.pdf')