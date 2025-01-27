function [ge,gi,gl,re,VC,GT,Zt,cmm,ff,ff2,g1,g2,z1,z2] = find_gegi_optm(V,I,sf,reves,searchtime,varargin);
%simple way to find conductances.
%based on injection of TWO frequencies (for example 400 and 900 Hz).
% the lowest freq is used for calculation of Ge and Gi and the higher one
% to calculate the Rs as we assume shortcut of the cell at this frequency.
%cValue of <0  will caluclate c automatically
% dec 6 2020 adding solution for 4 different frequencies as a way to find also
%the capcitance of the electrode (i.e., re,ce, c_cell, g_cell).

% Optional Parameter defaults
c = 0;  % If 0, c is calculated later from recording
FILTP = [20 0.0001 3 0.92]; % Filter Parameters

% Parse Optional Inputs
p = inputParser;
addOptional(p,'c',c);
addOptional(p,'FILTP',FILTP);

parse(p,varargin{:});
p = p.Results;
modec = 1;
if p.c > 0
    modec=0;
end

cleannoise = 0;
sff = sf
global cmm
ge = 0;
gi = 0;
Rs_meas= 0;

%searching for the two frequencies:
MC = 1000000;
autofreq= 1;

dt = 1/sf;
sf11 = sf;

df = 1./(dt*length(V));
fv = abs(fft(V-mean(V)));

MPH = std(fv)*10;

[pl,lc] = findpeaks(fv(round(100/df):end/2.2),'MinPeakHeight',MPH);
[pl,lc] = findpeaks(fv(round(100/df):end-round(100/df)),'MinPeakHeight',MPH);
ff = lc(1)*df+99;
ff2 = lc(2)*df+99;

DFF = p.FILTP(1); %for bonn 22
dst = p.FILTP(2); %%for bonn 0.16
NC = p.FILTP(3); %2 for bonn 2
STF1 = p.FILTP(4); %larger value smeers the time course!!! for bonn 0.57;
STF2 = p.FILTP(4);

filyert = 'fir';
%filyert = 'iir';
A = 80; %attenutation of the filter.
VF1ALL = [];
NVF1ALL = [];
xxf = 0; % for testing only!!!! should be zero!
ff = ff-xxf;
ff2 = ff2-xxf;

ssff = STF1;
VF1 = bandpass(V,[ff-DFF ff+DFF],1/dt,'ImpulseResponse',filyert, 'Steepness',ssff,'StopbandAttenuation',A);
evf1 = envelope(VF1);
R = 'fir';


IF1 = bandpass(I,[ff-DFF ff+DFF],1/dt,'ImpulseResponse',filyert, 'Steepness',ssff,'StopbandAttenuation',A);

eif1 = envelope(IF1);

hilbVf1 = hilbert(VF1);
hilbIf1 = hilbert(IF1);

VF2 = bandpass(V,[ff2-DFF ff2+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF1,'StopbandAttenuation',A);
evf2 = envelope(VF2);

IF2 = bandpass(I,[ff2-DFF ff2+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF2,'StopbandAttenuation',A);

eif2 = envelope(IF2);

hilbVf2 = hilbert(VF2);
hilbIf2 = hilbert(IF2);

meif2 = mean(eif2(2000:end-2000));
meif1 = mean(eif1(2000:end-2000));

im2 = (evf2./(eif2)); % this is the impedance of the rs (at high freq), electrode resistance
%im2 = (evf2./(meif2));


global Zt;
Zt = evf1./eif1; % total impedance including electrode for the low freq
%Zt = evf1./meif1; % total impedance including electrode for the low freq


%Rs_meas = im2; % vector of the Re based on high freq (aug 2020)
w = 2*pi*ff;
if modec ==1;  %calculate the c from phase analysis, change to take it from the higher freq
    % the assumption here that the for the higher frequency, at resting
    % condition g of the cell is much smaller than w*c and thus we solve the
    % problem as if there is only the resistor of the electtode and the
    % capcitor of the cell.
    ccmode = 'autoCfinder'
    STF2 = 0.6;%0.6
    fcf = ff2;
    fi_2 = bandpass(I,[fcf-DFF fcf+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF2);
    fv2 = bandpass(V,[fcf-DFF fcf+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF2);
    
    
    
    %fi = fi';
    
    s_fv = size(fv2);
    s_fi = size(fi_2);
    if s_fv ~= s_fi;
        fi_2 = fi_2';
    end
    
    fii2 = fi_2(round(searchtime(1)/dt):round(searchtime(2)/dt));
    fvv2 = fv2(round(searchtime(1)/dt):round(searchtime(2)/dt));
    
    ang11 = median((angle(hilbert(fvv2))-angle(hilbert(fii2))));
    
    
    RRR = max(abs(fft(fvv2-mean(fvv2))))/max(abs(fft(fii2-mean(fii2))));
    %RRR = max(real(fft(fvv2-mean(fvv2))))/max(real(fft(fii2-mean(fii2))));
    %RRR = max(real(fft(V-mean(V))))/max(real(fft(I)-mean(I)));
    %RRR = max(real(fft(V-mean(V))))/max(real(fft(I-mean(I))));
    
    
    cmm = c;
    factorC = 1.0;
    RRRR = RRR/1e6
    cmm =  abs(1/(atan(ang11)*RRR*2*pi*ff2))*factorC;
    c = cmm*1.0;
    p.c = c
end

k = w*p.c;
Rsm = Rs_meas*1.0;
Zt = Zt*1;

NewExact3 = 1; %Dec 14 2020
if NewExact3% solving based on absolute value:
    %%Solve[Abs (r + 1/(g + I*w1*c)) == Abs (z1) && Abs (r + 1/(g + I*w2*c)) == Abs (z2), {r, g}]
    g1 = [];
    g2 = [];
    z1 = hilbVf1./hilbIf1;
    z2 = hilbVf2./hilbIf2;
    
    %z2 = z2*1.0;
    %z2 = z2-mean(z1);
    w1 = 2*pi*ff;
    w2 = 2*pi*ff2;
    z1a = (z1);
    z2a = (z2);
    Rs_meas = (1/(2*(1i*p.c*w1 - 1i*p.c*w2)))*(1i*p.c*w1*z1a - 1i*p.c*w2*z1a + 1i*p.c*w1*z2a -...
        1i*p.c*w2*z2a + ((-1i*p.c*w1*z1a + 1i*p.c*w2*z1a - 1i*p.c*w1*z2a + 1i*p.c*w2*z2a).^2 -...
        4*(1i*p.c*w1 - 1i*p.c*w2)*(z1a - z2a + 1i*p.c*w1*z1a.*z2a - 1i*p.c*w2*z1a.*z2a)).^0.5);
    Gtotal = 1./(z1-Rs_meas)-1i*p.c*w1;
    Gtotal = ((1i*(1i + p.c*Rs_meas*w1 - p.c*w1*z1a))./(Rs_meas - z1a));
end
re = Rs_meas;
%%% Dec 2020 4 components

%reconstruct Ge and Gi
DFF = 5;
%cleaning the voltage.
global VC
if 1
    filyert = 'fir';
    DFF = 30;
    %cleaning the voltage.
    %VV = bandstop(V,[ff-DFF ff+DFF],1/dt);
    %VC = bandstop(VV,[ff2-DFF ff2+DFF],1/dt);
    STF3 = 0.8;
    VV = bandstop(V,[ff-DFF ff+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF3);
    VC = bandstop(VV,[ff2-DFF ff2+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF3);
    forItoo = 1;
    if forItoo;
        global Iclean;
        II = bandstop(I,[ff-DFF ff+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF3);
        Iclean = bandstop(II,[ff2-DFF ff2+DFF],1/dt,'ImpulseResponse',filyert,  'Steepness',STF3);
    end
    
    
    Gtotal = real(Gtotal);
    B= 100;
    Gtotal = lowpass(Gtotal,ff-60,1/dt,'ImpulseResponse',filyert,'Steepness',0.993,'StopbandAttenuation',B);
end
sVV = size(V);
sVF1 = size(VF1);
size(VF2);

if sVV ~= sVF1;
    V = V';
end
%VC = V-(VF1+VF2);

% dvdt and c

svc = size(VC);

dv = diff(VC);
sdv = size(dv);
if sdv(1) >1;
    dv = dv';
    VC = VC';
end
cdvdt = p.c*[dv dv(end)]./dt;

%finding the resting potential and gleak:
t1points = round(searchtime(1)/dt);
t2points =round(searchtime(2)/dt);


Vwind = VC(t1points:t2points);
l5p = prctile(Vwind,5);

viniceslow5 = find(Vwind<=l5p)+t1points;
vr = mean(VC(viniceslow5));
g0 = mean(Gtotal(viniceslow5));
gl = g0;
%caluclating the ge and gi from clean v and from total g as in lampl
%2019 first figure and equations.


gsyn = Gtotal-g0;
GS = gsyn;
GT = Gtotal;

ve = reves(2);
vi = reves(3); %confusing that reves should have 3 entries (~DANIEL)
vl = vr; %which is also vleak.
VCn = VC;

cdvdtn = cdvdt*(1);
vll= VC-vl;
vll= VC-(vr);
vee = VC-ve;
vii = VC-vi;
TT2 = vii;

cableBoost = 1;
if cableBoost;
    global G0new g0old1;
    g0old1 = g0;
    g0old = g0;
    'cableeee'
    g0 = g0old*(1-exp(-1*(gsyn./g0old).^2));
    G0new = g0;
end

gi = (1.0*cdvdt+1*g0.*vll+gsyn.*vee-1*Iclean)./(vee-vii); %inhibition

ge = gsyn-gi;
ge = real(ge);
gi = real(gi);


gl = g0;
VC = VCn;