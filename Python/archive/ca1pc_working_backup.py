# -*- coding: utf-8 -*-
"""
Created on Mon Sep 16 18:42:30 2019

@author: Daniel
"""

from neuron import h, gui
import numpy as np
import matplotlib.pyplot as plt
import time
import scipy.io
import scipy.signal

"""SOME NOTES"""
"""
h.s is the soma
h.d contains the dendrites
h.s1 contains an alpha synapse
default color idc:
0 white
1 black
2 red
3 blue
4 green
5 orange
6 brown
7 violet
8 yellow
9 gray

primary branches:
	s connect d[0](0), .5
	s connect d[22](0), .5
	s connect d[23](0), .5 // (Apical)
	s connect d[309](0), .5
	s connect d[320](0), .5
	s connect d[363](0), .5

for x in range(0,22):
    test.color(2, sec=h.d[x])
for x in range(22,23):
    test.color(3, sec=h.d[x])
for x in range(23,309):
    test.color(4, sec=h.d[x])
for x in range(309,320):
    test.color(5, sec=h.d[x])
for x in range(320,363):
    test.color(6, sec=h.d[x])
for x in range(363,412):
    test.color(7, sec=h.d[x])
"""

magee_file = "main.hoc"
h.load_file(magee_file) # Creates the cell

"""HYPERPARAMETERS"""
seed = 0
n_syne = 50  # number of excitatory synapses
n_syni = 50  # number of inhibitory synapses
ei_delay = 3  # in ms
t_stim = 800  # time_point of the stimulation
gsyn_e = 300e-6  # maximum conductance of the excitatory synapses
gsyn_i = gsyn_e*1.5  # maximum conductance of the inhibitory synapses
gsyn_e = 0.0
jitter_std = 20  # jitter of stimulation in ms std
dt = 0.01  #  sampling interval 
tstop = 2000+t_stim  # duration of the simulation
vrest = -65.0  # reversal potential of leak and initialization voltage
ve = 0  # reversal potential of excitation
vi = -75.0  # reversal potential of inhibition
# vi = - 130
vrs = 10.0  # access resistance 50.0 for gm and 1.0 for voltage clamp
amp_curr = 1.0  # peak to peak amplitude of injected current (nA)
freq_curr_one = 420  # frequency of injected current
freq_curr_two = 477
cp = 0.0  # Pipette capacitance
clamp = 'gm'  # measurement paradigm: 'sece', 'seci', 'gm'
# type of synaptic input:
# 'distal', 'proximal', 'somatic', 'bombardment'
inp = 'somatic'
dlambda = 'on'  # dlambda doesn't seem to be doing anything even for distal
dendrites = 'off'

# Detach dendrites from soma if dendrites = 'off'
if dendrites == 'off':
    new_s = h.Section()
    new_s.cm, new_s.L, new_s.Ra = h.s.cm, h.s.L, h.s.Ra
    new_s.insert('pas')
    new_s(0.5).pas.e = h.s(0.5).pas.e
    new_s(0.5).pas.g = h.s(0.5).pas.g
    soma = new_s
else:
    soma = h.s
        

# Setup the sinusoidal current injection
fs=np.round(1/(dt/1000))
T = np.arange(0, tstop/1000, dt/1000)
ac_one = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_one)*T)
ac_two = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_two)*T)
ac = (ac_one + ac_two) / 2.0

# Apply the d_lambda rule of dlambda == *on*
if dlambda=='on':
    d_lambda=0.1
    freq=100000
    for x in h.d:
        lambda_f = 1e5*np.sqrt(x.diam/(4*np.pi*freq*x.Ra*x.cm))
        n_seg = int((x.L/(d_lambda*lambda_f)+0.9)/2.0)*2+1
        x.nseg = n_seg
    lambda_f = 1e5*np.sqrt(soma.diam/(4*np.pi*freq*soma.Ra*soma.cm))
    n_seg = int((soma.L/(d_lambda*lambda_f)+0.9)/2.0)*2+1
    soma.nseg = n_seg

# Get the distance matrix the apical dendrite
h.distance(0,soma(0.5)) # Initialize Origin
dist_idc = []
dist_values = []
for x in range(23,309):
    dist_idc.append(x)
    h.distance(0,soma(0.5))
    dist_values.append(h.distance(h.d[x](0.5)))

dist_idc = np.array(dist_idc)
dist_values = np.array(dist_values)

dist_idc_sorted = dist_idc[np.argsort(dist_values)]

# Randomly choose 50 of the most distal dendrites
np.random.seed(seed)
if inp=='distal':
    inputs_e = np.random.choice(dist_idc_sorted[-100:], size=n_syne, replace=False)
    inputs_i = np.random.choice(dist_idc_sorted[-100:], size=n_syni, replace=False)
elif inp=='proximal':
    inputs_e = np.random.choice(dist_idc_sorted[:100], size=n_syne, replace=False)
    inputs_i = np.random.choice(dist_idc_sorted[:100], size=n_syni, replace=False)
elif inp=='somatic':
    inputs_e = np.random.choice(dist_idc_sorted[:100], size=n_syne, replace=False)
    inputs_i = np.random.choice(dist_idc_sorted[:100], size=n_syni, replace=False)
elif inp=='bombardment':
    inputs_e = np.arange(0,412)
    inputs_i = np.arange(0,412)

# Do some pretty shape plotting
shape_plot1 = h.PlotShape()

inputs_e_i = np.intersect1d(inputs_e,inputs_i)
for x in inputs_e:
    shape_plot1.color(4, sec=h.d[x])  # excitation green
for x in inputs_i:
    shape_plot1.color(2, sec=h.d[x])  # inhibition red
for x in inputs_e_i:
    shape_plot1.color(8, sec=h.d[x])  # inhibition yellow

# Create the excitatory synapses
syns_e=[]
netcons_e=[]
netstims_e=[]
ge_recs=[]

for x in inputs_e:
    if inp=='somatic':
        syn = h.Exp2Syn(soma(0.5))
    else:
        syn = h.Exp2Syn(h.d[x](0.5))
    syn.tau1 = 1
    syn.tau2 = 20
    
    syn.e=ve
    if inp=='bombardment':
        netstim = h.NetStim()
        freq = np.random.normal(3,2)
        netstim.interval=(1 / freq)*1000
        netstim.number=100
        netstim.start=t_stim
        netstim.noise=1
    else:
        netstim = h.NetStim()
        netstim.interval=0
        netstim.number=1
        netstim.start=t_stim+np.random.normal(0.0,jitter_std)
        netstim.noise=0
    netcon=h.NetCon(netstim, syn)
    netcon.weight[0]=gsyn_e
    netcon.delay=0
    syns_e.append(syn)
    netcons_e.append(netcon)
    netstims_e.append(netstim)
    grec = h.Vector()
    grec.record(syn._ref_g)
    ge_recs.append(grec)

# Create the inhibitory synapses
syns_i=[]
netcons_i=[]
netstims_i=[]
gi_recs=[]
for x in inputs_i:
    if inp=='somatic':
        syn = h.Exp2Syn(soma(0.5))
    else:
        syn = h.Exp2Syn(h.d[x](0.5))
    #syn.tau1=1.2
    #syn.tau2=50
    syn.tau1=1.2
    syn.tau2=100
    
    syn.e=vi
    if inp=='bombardment':
        netstim = h.NetStim()
        freq = np.random.normal(3,2)
        netstim.interval=(1 / freq)*1000
        netstim.number=100
        netstim.start=t_stim
        netstim.noise=1
    else:
        netstim = h.NetStim()
        netstim.interval=0
        netstim.number=1
        netstim.start=t_stim+np.random.normal(0.0,jitter_std)+ei_delay
        netstim.noise=0
    netcon=h.NetCon(netstim, syn)
    netcon.weight[0]=gsyn_i
    netcon.delay=0
    syns_i.append(syn)
    netcons_i.append(netcon)
    netstims_i.append(netstim)
    grec = h.Vector()
    grec.record(syn._ref_g)
    gi_recs.append(grec)

"""
# Setup Recordings
vvec = h.Vector()
vvec.record(soma(0.5)._ref_v)
"""

# Setup clamping mechanism
if clamp == 'sece':
    p=h.SEClamp(soma(0.5))
    p.dur1=tstop
    p.amp1=vi
    p.rs = vrs
    pi_rec = h.Vector()
    pi_rec.record(p._ref_i)
elif clamp == 'seci':
    p=h.SEClamp(soma(0.5))
    p.dur1=tstop
    p.amp1=ve
    p.rs = vrs
    pi_rec = h.Vector()
    pi_rec.record(p._ref_i)
elif clamp == 'gm':
    acc_r = h.Section()
    acc_r.L = 1
    acc_r.diam = 1.128379167
    acc_r.Ra = vrs * acc_r.diam
    #acc_r.Ra = vrs
    acc_r.cm = cp
    acc_r.connect(soma, 0.0)
    acc_r_total_area=0
    for x in acc_r:
        acc_r_total_area+=x.area()
    specific_c = (cp*10e-5)/(acc_r_total_area*10e-7)
    acc_r.cm = specific_c
    p = h.IClamp(acc_r(1.0))
    p.delay = 0
    p.dur = 1e9
    pi_vec = h.Vector(ac)
    pi_vec.play(p._ref_amp, dt)
    pi_rec = h.Vector()
    pi_rec.record(acc_r(1.0)._ref_v)
    cv_rec = h.Vector()
    cv_rec.record(acc_r(0.0)._ref_v)

# Setup additional voltage recordings in the dendrites
h.distance(0,soma(0.5)) # Initialize Origin
dist_values_all = []
v_dends = []
for x in range(0,412):
    h.distance(0,soma(0.5))
    dist_values_all.append(h.distance(h.d[x](0.5)))
    rec = h.Vector()
    rec.record(h.d[x](0.5)._ref_v)
    v_dends.append(rec)
dist_values_all = np.array(dist_values_all)

h.steps_per_ms = 1.0/dt
h.finitialize(vrest)
h.secondorder = 0
h.t = -2000
h.secondorder = 0
h.dt = 10

while h.t < -100:
    h.fadvance()
h.t=0
h.dt=dt

h.frecord_init()  # Necessary after changing t to restart the vectors
while h.t < tstop:
    h.fadvance()

# Now we calculate the output
# For voltage clamp the conductance is calculated from current and reversal
# For the g measurement technique a mat file is written with all necessary
# Information for further processing
if clamp=='sece':
    pi_rec = np.array(pi_rec)
    pg = pi_rec/(vi-ve)
    
if clamp=='seci':
    pi_rec = np.array(pi_rec)
    pg = pi_rec/(ve-vi)

if clamp=='gm':
    pi_rec = np.array(pi_rec)
    pg = pi_rec

#pi_rec=np.array(pi_rec)
#plt.plot(np.arange(pi_rec.shape[0])*dt, pi_rec)
if clamp == 'sece':
    #plt.plot(np.arange(pg.shape[0])*dt, np.array(ge_recs).sum(axis=0)*1e-9, color='k')
    plt.plot(np.arange(pg.shape[0])*dt, pg*1e-9, color='green')
    plt.legend(("Total known conductance", "Measured conductance"))
    plt.title(f"Clamp: {clamp}; Input: {inp}; dlambda: {dlambda}; vrs: {vrs}")
    plt.ylabel("conductance (S)")
    plt.xlabel("time (ms)")
    plt.xlim((380,580))
    plt.ylim((-0.001*1e-9,0.02*1e-9)) 

elif clamp == 'seci':
    #plt.plot(np.arange(pg.shape[0])*dt, np.array(gi_recs).sum(axis=0)*1e-9, color='k')
    plt.plot(np.arange(pg.shape[0])*dt, (pg*1e-9) - (pg*1e-9)[0:10].mean(), color='red')
    plt.legend(("Total known conductance", "Measured conductance"))
    plt.title(f"Clamp: {clamp}; Input: {inp}; dlambda: {dlambda}; vrs: {vrs}")
    plt.ylabel("conductance (S)")
    plt.xlabel("time (ms)")
    plt.xlim((380,580))
    plt.ylim((-0.001*1e-9,0.02*1e-9)) 

elif clamp == 'gm':
    plt.plot(np.arange(pg.shape[0])*dt, pg/1000, color='k')
    plt.xlabel("time (ms)")
    plt.ylabel("voltage (V)")
    plt.xlim((380,580))

hyperparams = dict([('seed', seed),
                    ('n_syne', n_syne),
                    ('n_syni', n_syni),
                    ('ei_delay', ei_delay),
                    ('t_stim', t_stim),
                    ('gsyn_e', gsyn_e),
                    ('gsyn_i', gsyn_i),
                    ('jitter_std', jitter_std),
                    ('dt', n_syni),
                    ('vrest', vrest),
                    ('ve', ve),
                    ('vi', vi),
                    ('vrs', vrs),
                    ('amp_curr', amp_curr),
                    ('freq_curr', [freq_curr_one, freq_curr_two]),
                    ('cp', cp),
                    ('clamp', clamp),
                    ('inp', inp),
                    ('dlambda', dlambda)])

fname = f"{clamp}_{inp}_{vrs}_{freq_curr_one}_{freq_curr_two}_{dlambda}_{seed}_{time.time()}"

np.savez(fname, pg=pg,
         ge_recs=np.array(ge_recs),
         gi_recs=np.array(gi_recs),
         hyperparams=np.array(hyperparams,dtype=np.object))

if clamp=='gm':
    # Doing some SI conversion here
    mat_dict = {'fname': fname,
                'V': pg/1000.0,
                'dt': dt/1000.0,
                'reversals': [vrest/1000, ve/1000, vi/1000],
                'AmpCurr': amp_curr*1e-9,
                're': vrs*1000000,
                'freq_curr': [freq_curr_one, freq_curr_two],
                'ac': ac,
                'hyperparams': hyperparams,
                'total_ge': np.array(ge_recs).sum(axis=0)*1e-6,
                'total_gi': np.array(gi_recs).sum(axis=0)*1e-6}
    scipy.io.savemat(fname+".mat", mat_dict)

"""
n_syne = 50
n_syni = 50
ei_delay = 2  # in ms
t_stim=50
gsyn_e=600e-6
gsyn_i=gsyn_e*1.5
jitter_std = 2
dt=0.05
tstop=1000+t_stim
vrest=-65
ve=0
vi=-65
vrs=60.0  # 60.0 for gm and 1.0 for voltage clamp
capacitance=1.0  # Measured externally
amp_curr=0.5  # nA
freq_curr=500  # Hzs
cp = 0.0
clamp='gm'  # 'sece', 'seci', ve, vi, 'gm'
inp='somatic'  # 'distal', 'proximal', 'basal'
dlambda='on'  # dlambda doesn't seem to be doing anything even for distal
"""