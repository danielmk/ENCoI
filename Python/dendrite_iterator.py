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
import os

dirname = os.path.normpath(os.path.dirname(__file__))
filename = os.path.join(dirname, 'mechs', 'nrnmech.dll')
h.nrn_load_dll(filename)

"""PARAMETERS"""
seed = 10

t_stim = 800  # time_point of the stimulation
gsyn_e = 300e-4  # maximum conductance of the excitatory synapses
gsyn_i = gsyn_e*1.5  # maximum conductance of the inhibitory synapses
dt = 0.01  #  sampling interval 
tstop = 2500+t_stim  # duration of the simulation
vrest = -65.0  # reversal potential of leak and initialization voltage
vrs = 10.0  # access resistance 50.0 for gm and 1.0 for voltage clamp
amp_curr = 1.0  # peak to peak amplitude of injected current (nA)
freq_curr_one = 210  # frequency of injected current
freq_curr_two = 315
cp = 0.0  # Pipette capacitance
g_leak_scale = 1

"""SYNAPTIC PARAMETERS"""
ei_delay = 4  # in ms

gsyn_e = 300e-4  # maximum conductance of the excitatory synapses
tau_rise_e = 20  # Rise time of synaptic excitatory conductance
tau_decay_e = 50  # Decay time of synaptic excitatory conductance
tau_facil_e = 0  # Facilitation time constant of the tm process
tau_rec_e = 200  # Recovery time constant of the tm process
U_e = 0.2  # Utilization constant of synaptic efficacy
ve = 0  # reversal potential of excitation

gsyn_i = gsyn_e*1.5  # maximum conductance of the inhibitory synapses
tau_rise_i = 30  # Rise time of synaptic inhibitory conductance
tau_decay_i = 100  # Decay time of synaptic inhibitory conductance
tau_facil_i = 0  # Facilitation time constant of the tm process
tau_rec_i = 600  # Recovery time constant of the tm process
U_i = 0.4  # Utilization constant of synaptic efficacy
vi = -75.0  # reversal potential of inhibition

syn_ts = np.arange(t_stim, t_stim+1000, 100)


clamp = 'gm'  # measurement paradigm: 'sece', 'seci', 'gm'
# type of synaptic input:
# 'distal', 'intermediate', 'proximal', 'somatic', 'mixed'
dlambda = 'on'  # dlambda doesn't seem to be doing anything even for distal
dend_skip = 5

# Setup the sinusoidal current injection
fs=np.round(1/(dt/1000))
T = np.arange(0, tstop/1000, dt/1000)
ac_one = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_one)*T)
ac_two = (amp_curr/2.0) * np.sin((2*np.pi*freq_curr_two)*T)
ac = (ac_one + ac_two) / 2.0

recording_list = []
synaptic_distance_list = []
for dend_idx in range(23, 309, dend_skip):
    magee_file = "main.hoc"
    h.load_file(magee_file) # Creates the cell

    
    soma = h.s
    curr_syn = h.d[dend_idx]
    
    h.distance(0,soma(0.5)) # Initialize Origin
    curr_dist = h.distance(curr_syn(0.5))
    synaptic_distance_list.append(curr_dist)
    inp = str(dend_idx).zfill(3)
    
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

    syn_e = h.tmgexp2syn(curr_syn(0.5))
    syn_e.tau_1 = 20
    syn_e.tau_2 = 50
    syn_e.e=ve
    syn_e.tau_facil = 0
    syn_e.tau_rec = 200
    syn_e.U=0.2
    
    vecstim_e = h.VecStim()
    pattern_vec_e = h.Vector(syn_ts)
    vecstim_e.play(pattern_vec_e)
    netcon_e = h.NetCon(vecstim_e, syn_e)
    netcon_e.weight[0] = gsyn_e
    
    grec_e = h.Vector()
    grec_e.record(syn_e._ref_g)
    
    # Create the inhibitory synapses
    syn_i = h.tmgexp2syn(curr_syn(0.5))
    syn_i.tau_1=30
    syn_i.tau_2=100
    syn_i.e=vi
    syn_i.tau_facil = 0
    syn_i.tau_rec = 600
    syn_i.U=0.4
    
    vecstim_i = h.VecStim()
    pattern_vec_i = h.Vector(syn_ts+ei_delay)
    vecstim_i.play(pattern_vec_i)
    netcon_i = h.NetCon(vecstim_i, syn_i)
    netcon_i.weight[0] = gsyn_i
    
    grec_i = h.Vector()
    grec_i.record(syn_i._ref_g)

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
    if clamp=='sece':
        pi_rec = np.array(pi_rec)
        pg = pi_rec/(vi-ve)
        
    if clamp=='seci':
        pi_rec = np.array(pi_rec)
        pg = pi_rec/(ve-vi)
    
    if clamp=='gm':
        pi_rec = np.array(pi_rec)
        pg = pi_rec
    
    recording_list.append(pg)

fname = f"{clamp}_{inp}_{vrs}_{freq_curr_one}_{freq_curr_two}_{dlambda}_{seed}_{time.time()}"

if clamp=='gm':
    # Doing some SI conversion here
    mat_dict = {'fname': fname,
                'V': np.array(recording_list)/1000.0,
                'syn_dists': np.array(synaptic_distance_list),
                'dt': dt/1000.0,
                'reversals': [vrest/1000, ve/1000, vi/1000],
                'AmpCurr': amp_curr*1e-9,
                're': vrs*1000000,
                'freq_curr': [freq_curr_one, freq_curr_two],
                'ac': ac,
                'total_ge': np.array(grec_e)*1e-6,
                'total_gi': np.array(grec_i)*1e-6}
    scipy.io.savemat(fname+".mat", mat_dict)

if clamp=='sece' or clamp=='seci':
    mat_dict = {'fname': fname,
            'g': np.array(recording_list)*1e-6,  # Convert microsiemens to siemens
            'syn_dists': np.array(synaptic_distance_list),
            'dt': dt/1000.0,
            'reversals': [vrest/1000, ve/1000, vi/1000],
            'AmpCurr': amp_curr*1e-9,
            're': vrs*1000000,
            'freq_curr': [freq_curr_one, freq_curr_two],
            'ac': ac,
            'total_ge': np.array(grec_e)*1e-6,
            'total_gi': np.array(grec_i)*1e-6}
    scipy.io.savemat(fname+".mat", mat_dict)

