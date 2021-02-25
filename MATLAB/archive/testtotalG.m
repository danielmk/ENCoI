
figure
hold on;
plot(gl+ge_measured+gi_measured)
plot(mean(g(1:1000))+ge_vclamp+gi_vclamp,'r')
plot(4*1e-09 + ge_actual+gi_actual,'k')

