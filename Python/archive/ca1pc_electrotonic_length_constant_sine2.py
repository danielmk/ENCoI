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
from scipy.signal import periodogram, hilbert

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

"""HYPERPARAMETERS"""
seed = 0
n_syne = 50  # number of excitatory synapses
n_syni = 50  # number of inhibitory synapses
ei_delay = 10  # in ms
t_stim = 800  # time_point of the stimulation
gsyn_e = 300e-6  # maximum conductance of the excitatory synapses
gsyn_i = gsyn_e*1.5  # maximum conductance of the inhibitory synapses
jitter_std = 20  # jitter of stimulation in ms std
dt = 0.01  #  sampling interval 
tstop = 405  # duration of the simulation
vrest = -65.0  # reversal potential of leak and initialization voltage
ve = 0  # reversal potential of excitation
vi = -75.0  # reversal potential of inhibition
vrs = 10.0  # access resistance 50.0 for gm and 1.0 for voltage clamp
amp_curr = 1.0  # peak to peak amplitude of injected current (nA)
freq_curr_one = 410  # frequency of injected current
freq_curr_two = 587
cp = 0.0  # Pipette capacitance
g_leak_scale = 1
clamp = 'seci'  # measurement paradigm: 'sece', 'seci', 'gm'
# type of synaptic input:
# 'distal', 'proximal', 'somatic', 'bombardment'
inp = 'proximal'
dlambda = 'on'  # dlambda doesn't seem to be doing anything even for distal
dendrites = 'on'

voltage_list = []
current_list = []
dist_list = []

magee_file = "main.hoc"
h.load_file(magee_file) # Creates the cell

# Detach dendrites from soma if dendrites = 'off'
soma = h.s

for d in h.d:
    d(0.5).pas.g = d(0.5).pas.g * g_leak_scale
soma(0.5).pas.g = soma(0.5).pas.g * g_leak_scale

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

for dend_idx in np.arange(23,309, 5):
    h.distance(0,soma(0.5))
    dend_dist = h.distance(h.d[dend_idx](0.5))
    dend_voltage = h.Vector()
    dend_voltage.record(h.d[dend_idx](0.5)._ref_v)
    dend_current = h.Vector()
    dend_current.record(h.d[dend_idx](0.5).pas._ref_i)
    voltage_list.append(dend_voltage)
    current_list.append(dend_current)
    dist_list.append(dend_dist)



soma_current = h.Vector()
soma_current.record(soma(0.5).pas._ref_i)
soma_voltage = h.Vector()
soma_voltage.record(soma(0.5)._ref_v)

fs=np.round(1/(dt/1000))
T = np.arange(0, tstop/1000, dt/1000)
ac_one = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_one)*T)
ac_two = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_two)*T)
ac = (ac_one + ac_two) / 2.0

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

t = h.Vector()
t.record(h._ref_t)

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
"""
plt.figure()
plt.plot(np.array(t), dend_voltage)
plt.plot(np.array(t), soma_voltage)
plt.legend(("Dendritic Voltage", "Somatic Voltage"))
plt.ylabel("Voltage (mV)")
plt.xlabel("Time (ms)")
plt.ylim((-450, -50))
plt.title(f"Distance to soma: {dend_dist} um")
"""

#plt.scatter(dist_list, attenuation_list)

plt.figure()
f, Pxx_den = periodogram(soma_voltage, 1/(dt/1000))
plt.semilogy(f, Pxx_den)
f, Pxx_den = periodogram(voltage_list[48], 1/(dt/1000))
plt.semilogy(f, Pxx_den)






