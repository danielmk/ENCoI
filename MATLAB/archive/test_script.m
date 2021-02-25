cd(fileparts(which(mfilename)));
load('.\data\conductances.mat');
mfilename
[V, IInj, p] = gegi_model(GE, GI);

[ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi_experimental_DMK(V,IInj,1/p.dt,[p.vl p.ve p.vi],[0.3 0.6]);

plot(ge)
hold on
plot(gi)

