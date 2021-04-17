# -*- coding: utf-8 -*-
"""
Mechanism and many parameters from McCormick and Pape (1990)

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

dt = 0.01  #  sampling interval 
tstop = 1000  # duration of the simulation

comp = h.Section()
comp.insert("pas")
comp.insert("htc")
comp(0.5).htc.eh = -47
#comp(0.5).htc.ghbar = 0.0004
comp(0.5).htc.ghbar = 0.00005
comp(0.5).pas.g = 1/10000
comp.Ra = 150
comp.cm = 1
comp.diam = 20
comp.L = 20

p=h.IClamp(comp(0.5))
p.dur=500
p.amp=-0.1
p.delay=100

rec_v = h.Vector()
rec_v.record(comp(0.5)._ref_v)

h.steps_per_ms = 1.0/dt
h.finitialize(-70)
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
    
plt.plot(rec_v)

    
    
    
    
    