%%
% ISOLATE ge AND gi FROM MULTIPLE DENDRITIC DISTANCES
cd(fileparts(which(mfilename)));

gm = load('data\final_distances\gm_baseline.mat');
sece = load('data\final_distances\sece_baseline.mat');
seci = load('data\final_distances\seci_baseline.mat');

FILTP = [20 0.0001 3 0.92];
searchtime = [0.3 0.6];
gm_ge_corr_arr = zeros(1, size(gm.V, 1));
gm_gi_corr_arr = zeros(1, size(gm.V, 1));
sece_ge_corr_arr = zeros(1, size(gm.V, 1));
seci_gi_corr_arr = zeros(1, size(gm.V, 1));
gm_ge_norm_arr = zeros(1, size(gm.V, 1));
gm_gi_norm_arr = zeros(1, size(gm.V, 1));
sece_ge_norm_arr = zeros(1, size(gm.V, 1));
seci_gi_norm_arr = zeros(1, size(gm.V, 1))

start_idx = 80000
end_idx = 220000

distal_idx = 42;
proximal_idx = 4;

[ge_prox,gi_prox,VC_prox,gl_prox,re_prox,GT_prox,...
 Zt_prox,cmm_prox,ff_prox,ff2_prox,g1_prox,g2_prox,z1_prox,z2_prox, re_prox] = ...
              find_gegi_parameter_explorer(gm.V(proximal_idx,1:end-1),...
              gm.ac*1e-9,...
              1/gm.dt,...
              gm.reversals,...
              searchtime,...
              'FILTP', FILTP);

[ge_dist,gi_dist,VC_dist,gl_dist,re_dist,GT_dist,...
 Zt_dist,cmm_dist,ff_dist,ff2_dist,g1_dist,g2_dist,z1_dist,z2_dist, re_dist] = ...
              find_gegi_parameter_explorer(gm.V(distal_idx,1:end-1),...
              gm.ac*1e-9,...
              1/gm.dt,...
              gm.reversals,...
              searchtime,...
              'FILTP', FILTP);
