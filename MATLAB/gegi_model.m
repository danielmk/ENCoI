function [V, Iinj, p] = gegi_model(ge,gi,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Constants
MOhm = 1e6

% Parameter Defaults
ce = 8e-12;
cm = 1.5*1e-10;
Rcell = 150;
gl = 1/(Rcell*MOhm);
vl = -0.07;
ve = 0.0;
vi = -0.08;
gscale = 1;  %Scaling factor for the conductances
re = 1*(50.00)*MOhm;
Rp = 22*MOhm;
Fss = [220 277];
sw = 1;
dt = 1e-4;
t_start = 0;
t_stop = 4;

% Parse the optional inputs
p = inputParser;
addOptional(p,'ce', ce);
addOptional(p,'cm', cm);
addOptional(p,'Rcell', Rcell);
addOptional(p,'vl', vl);
addOptional(p,'ve', ve);
addOptional(p,'vi', vi);
addOptional(p,'gscale', gscale);
addOptional(p,'re', re);
addOptional(p,'Rp', Rp);
addOptional(p,'Fss', Fss);
addOptional(p,'sw', sw);
addOptional(p,'dt', dt);
addOptional(p,'t_start', t_start);
addOptional(p,'t_stop', t_stop);

parse(p,varargin{:});
p = p.Results

outputArg1 = p;
outputArg2 = 30;

vm = vl;
V = [];
ii = 0;
    for tt = t_start:dt:t_stop;
        ii=ii+1;
        if sw == 1;
            Fss = [220 277]; % 701 when practicaal use 188 and 583 will work 701
            fsin1 = Fss(1);
            fsin2 = Fss(2);

            ampSin1 = 3*250*1*1e-12;
            SI1 = ampSin1*sin(tt*2*pi*fsin1);
            SI2 = ampSin1*sin(tt*2*pi*fsin2+0);
            SI = SI1+SI2;
 
        Im = SI;

        EC = 0; %with (1) or without electrode capacitance (0).

        %tauelect = 0.0001;
        if EC>0;
            Ic = Im-(Vp-vm)/Rp;
        else
            Ic = 0;
        end
        dvm = -p.dt*(1/p.cm)*(gl*(vm-vl)+ge(ii)*(vm-ve)+gi(ii)*(vm-vi)-(Im-EC*Ic));

        dVp = EC*Ic*(dt/(ce));

        %%

        vm = dvm+vm;

        if EC == 0 %if EC = 0 no capa
            Vp = vm+Im*Rp;
        else
            Vp = Vp+dVp;
        end

        RR = p.re;
        v = 1*Vp+1*Im*RR;

        Iinj(ii) = Im; %changed from SI Dec 2020
        V(ii) = v;
    end

end

