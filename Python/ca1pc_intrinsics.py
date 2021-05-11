# -*- coding: utf-8 -*-
"""
Measure the intrinsic properties of the CA1 PC with a step current
injection or the sine wave injection.
"""

from neuron import h, gui
import numpy as np
import matplotlib.pyplot as plt
import time
import scipy.io
import scipy.signal
import os

magee_file = "main.hoc"
h.load_file(magee_file) # Creates the cell
dirname = os.path.normpath(os.path.dirname(__file__))
filename = os.path.join(dirname, 'mechs', 'nrnmech.dll')
h.nrn_load_dll(filename)

"""PARAMETERS"""
seed = 10
t_stim = 800  # time_point of the stimulation
jitter_std = 10  # jitter of stimulation in ms std
vrest = -65.0  # reversal potential of leak and initialization voltage
vrs = 10.0  # access resistance 50.0 for gm and 1.0 for voltage clamp
amp_curr = 1.0  # peak to peak amplitude of injected current (nA)
freq_curr_one = 210  # frequency of injected current
freq_curr_two = 315
cp = 0.0  # Pipette capacitance
g_leak_scale = 1

"""SIMULATION PARAMETERS"""
dt = 0.01  #  sampling interval 
tstop = 2000+t_stim  # duration of the simulation
clamp = 'cc'  # measurement paradigm: 'gm', 'cc'
# type of synaptic input:
# 'distal', 'intermediate', 'proximal', 'somatic', 'mixed'
dlambda = 'on'  # dlambda doesn't seem to be doing anything even for distal
dendrites = 'off'

# Detach dendrites from soma if dendrites = 'off'
if dendrites == 'off':
    new_s = h.Section()
    new_s.cm, new_s.L, new_s.Ra, new_s.diam = h.s.cm, h.s.L, h.s.Ra, h.s.diam
    new_s.insert('pas')
    new_s(0.5).pas.e = h.s(0.5).pas.e
    new_s(0.5).pas.g = h.s(0.5).pas.g
    soma = new_s
else:
    soma = h.s

for d in h.d:
    d(0.5).pas.g = d(0.5).pas.g * g_leak_scale
soma(0.5).pas.g = soma(0.5).pas.g * g_leak_scale

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

# Setup clamping mechanism
if clamp == 'cc':
    acc_r = h.Section()
    acc_r.L = 1
    acc_r.diam = 1.128379167
    acc_r.Ra = vrs * 100
    #acc_r.Ra = vrs
    acc_r.cm = cp
    acc_r.connect(soma, 0.0)
    acc_r_total_area=0
    for x in acc_r:
        acc_r_total_area+=x.area()
    specific_c = (cp*10e-5)/(acc_r_total_area*10e-7)
    acc_r.cm = specific_c
    p = h.IClamp(acc_r(1.0))
    p.delay=100
    p.dur = 500
    p.amp = -1
    pi_rec = h.Vector()
    pi_rec.record(acc_r(1.0)._ref_v)
elif clamp == 'gm':
    acc_r = h.Section()
    acc_r.L = 1
    acc_r.diam = 1.128379167
    acc_r.Ra = vrs * 100
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
if clamp=='cc':
    pi_rec = np.array(pi_rec)
    pg = pi_rec
elif clamp=='gm':
    pi_rec = np.array(pi_rec)
    pg = pi_rec
    

hyperparams = dict([('seed', seed),
                    ('jitter_std', jitter_std),
                    ('dt', dt),
                    ('vrest', vrest),
                    ('vrs', vrs),
                    ('amp_curr', amp_curr),
                    ('freq_curr', [freq_curr_one, freq_curr_two]),
                    ('cp', cp),
                    ('clamp', clamp),
                    ('dlambda', dlambda)])

fname = f"{clamp}_{vrs}_{freq_curr_one}_{freq_curr_two}_{dlambda}_{seed}_{time.time()}"


# Doing some SI conversion here
mat_dict = {'fname': fname,
            'V': pg/1000.0,
            'dt': dt/1000.0,
            'AmpCurr': amp_curr*1e-9,
            're': vrs*1000000,
            'freq_curr': [freq_curr_one, freq_curr_two],
            'ac': ac,
            'hyperparams': hyperparams}
scipy.io.savemat(fname+".mat", mat_dict)

