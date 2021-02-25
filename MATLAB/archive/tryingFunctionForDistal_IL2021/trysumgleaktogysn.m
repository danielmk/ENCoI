

figure
plot(gi_proximal+ge_proximal,'b','linewidth',2);
hold on;
gsproxim = gi_proximal+ge_proximal;
diffproximal = gsproxim-gl_proximal;  
%plot(gl_proximal,'b');
plot(gsproxim+diffproximal,'b');

plot(gi_intermediate+ge_intermediate,'r','linewidth',2);
hold on;
gsinterm = gi_intermediate+ge_intermediate;
diffinterm = gsinterm-gl_intermediate;
%plot(gl_intermediate,'r');
plot(diffinterm+gsinterm,'r');