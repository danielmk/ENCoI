%% LOADING
cd(fileparts(which(mfilename)));

bl = load('.\data\final_distances\corrcoef_batch_processed_baseline.mat')

%% PLOTTING PARAMETERS
xlim_all=[0.0, 1.5];
xstart = 0.7;
ylim_ge=[-1.0, 9.0];
ylim_gi=[-5.0, 35.0];
scatter_alpha = 0.7;
fontsize = 12;
nS_factor = 1e9;  % Convert S to nS
mV_factor = 1e3;  % Convert V to mV
nA_factor = 1e9;  %Convert nA to A
t = ((0:length(bl.gm_vc_proximal)-1)) * 0.01/1000;
t = t - xstart;
fig_rows = 3;
fig_cols = 2;

%% PLOTTING
figure('color', [1 1 1],...
       'renderer', 'painters',...
       'visible','on',...
       'Units','centimeters',...
       'position',[20 5 [29.7/sqrt(2) 29.7]],...
       'PaperUnits','centimeters',...
       'PaperSize',[29.7/sqrt(2) 29.7])
hold on;

subplot(fig_rows, fig_cols, 1);
hold on;
plot(t, bl.gm_ge_proximal*nS_factor,'linewidth',1)
plot(t, bl.total_ge(1,1:end-1)*nS_factor,'linewidth',1)
plot(t, (bl.sece_ge_proximal(1,1:end-1) - ... 
         mean(bl.sece_ge_proximal(1,1:1000)))*nS_factor, ...
         'linewidth',1)
legend("Measured ge", "True ge", "VC ge");
xlim(xlim_all);
ylim(ylim_ge);
ylabel("Conductance (nS)");
xlabel('Time (s)');
set(gca,'fontsize',fontsize);
title_txt = sprintf("Proximal ge: %.2f um from soma", bl.dist_proximal);
title(title_txt);
set(gca,'TickDir','out');

subplot(fig_rows, fig_cols, 2);
hold on;
plot(t, bl.gm_gi_proximal*nS_factor,'linewidth',1)
plot(t, bl.total_gi(1,1:end-1)*nS_factor,'linewidth',1)
plot(t, (bl.seci_gi_proximal(1,1:end-1) - ...
         mean(bl.seci_gi_proximal(1,1:1000)))*nS_factor, ...
         'linewidth',1)
legend("Measured gi", "True gi", "VC gi");
xlim(xlim_all);
ylim(ylim_gi);
ylabel("Conductance (nS)");
xlabel('Time (s)');
set(gca,'fontsize',fontsize);
title_txt = sprintf("Proximal gi: %.2f um from soma", bl.dist_proximal);
title(title_txt);
set(gca,'TickDir','out');

subplot(fig_rows, fig_cols, 3);
hold on;
plot(t, bl.gm_ge_distal*nS_factor,'linewidth',1)
plot(t, bl.total_ge(1,1:end-1)*nS_factor,'linewidth',1)
plot(t, (bl.sece_ge_distal(1,1:end-1) - ...
         mean(bl.sece_ge_distal(1,1:1000)))*nS_factor,...
         'linewidth',1)
legend("Measured ge", "True ge", "VC ge");
xlim(xlim_all);
ylim(ylim_ge);
ylabel("Conductance (nS)");
xlabel('Time (s)');
set(gca,'fontsize',fontsize);
title_txt = sprintf("Distal ge: %.2f um from soma", bl.dist_distal);
title(title_txt);
set(gca,'TickDir','out');

subplot(fig_rows, fig_cols, 4);
hold on;
plot(t, bl.gm_gi_distal*nS_factor,'linewidth',1)
plot(t, bl.total_gi(1,1:end-1)*nS_factor,'linewidth',1)
plot(t, (bl.seci_gi_distal(1,1:end-1) - ...
         mean(bl.seci_gi_distal(1,1:1000)))*nS_factor, ...
         'linewidth',1)
legend("Measured gi", "True gi", "VC gi");
xlim(xlim_all);
ylim(ylim_gi);
ylabel("Conductance (nS)");
xlabel('Time (s)');
set(gca,'fontsize',fontsize);
title_txt = sprintf("Distal ge: %.2f um from soma", bl.dist_distal);
title(title_txt);
colors = get(gca,'colororder')
set(gca,'TickDir','out');

subplot(fig_rows, fig_cols, 5);
hold on;
scatter(bl.syn_dists,bl.sece_ge_corr_arr,...
        'filled','MarkerFaceAlpha',scatter_alpha, ...
        'MarkerEdgeAlpha',scatter_alpha,...
        'MarkerEdgeColor',colors(3,:),...
        'MarkerFaceColor',colors(3,:))
scatter(bl.syn_dists,bl.gm_ge_corr_arr,...
        'x','o','MarkerFaceAlpha',scatter_alpha,...
        'MarkerEdgeAlpha',scatter_alpha, ...
        'MarkerEdgeColor',colors(1,:),...
        'MarkerFaceColor',colors(1,:))
set(gca,'fontsize',fontsize);
xlabel("Distance to Soma (um)")
ylabel("Corr. Coefficient")
legend("VC ge", "Measured ge")
set(gca,'TickDir','out');
ylim([0,1])

subplot(fig_rows, fig_cols, 6);
hold on;
scatter(bl.syn_dists,bl.seci_gi_corr_arr,...
        'filled','MarkerFaceAlpha',scatter_alpha,...
        'MarkerEdgeAlpha',scatter_alpha,...
        'MarkerEdgeColor',colors(3,:),...
        'MarkerFaceColor',colors(3,:))
scatter(bl.syn_dists,bl.gm_gi_corr_arr,...
        'x','MarkerFaceAlpha',scatter_alpha,...
        'MarkerEdgeAlpha',scatter_alpha,...
        'MarkerEdgeColor',colors(1,:),...
        'MarkerFaceColor',colors(1,:))
set(gca,'fontsize',fontsize);
xlabel("Distance to Soma (um)")
ylabel("Corr. Coefficient")
legend("VC gi", "Measured gi")
ylim([0,1])
set(gca,'TickDir','out');

%% PRINT FIGURE
print(gcf, '-dpdf', 'figure8_matlab_out.pdf')