# -*- coding: utf-8 -*-
"""
Created on Mon Dec 14 10:12:56 2020

@author: Daniel
"""


import numpy as np
from scipy.io import loadmat, savemat
import matplotlib.pyplot as plt

# Import conductances
ge_gi_mat = loadmat("ge_gi_default.mat")
GE = ge_gi_mat['GE'][0,:]
GI = ge_gi_mat['GI'][0,:]
II = ge_gi_mat['Iinj'][0,:-1]

# Parameters
MC = 1e6
Cm = 1.5*1e-10  # Membrane Capacitance
Ce = 0  # Electrode Capacitance
Rcell = 150
gl = 1/(Rcell*MC)
vl = -0.07
ve = 0.0
vi = -0.08
scfacorG = 1
Re = 1*(50.00)*MC
Rp = 22*MC

# Hyperparameters
dt = 1e-4
t = np.arange(0,4, dt)

vm = vl
vp = vl
v = vl

vm_list = []
vp_list = []
v_list = []

for idx, x in enumerate(t):
    
    vm_list.append(vm)
    vp_list.append(vp)
    v_list.append(v)
    
    ge = GE[idx] * scfacorG
    gi = GI[idx] * scfacorG

    Im = II[idx]
    
    if Ce > 0:
        Ic = Im-(vp-vm)/Rp
    else:
        Ic = 0
    
    dvm = (gl*(vm-vl)+ge*(vm-ve)+gi*(vm-vi)-(Im-Ic))*(-dt)/Cm
    
    if Ce == 0:
        dvp = 0
    else:
        dvp = Ic*(dt/(Ce))
    
    
    vm = dvm + vm
    if Ce == 0:
        vp = vm+Im*Rp
    else:
        vp = vp+dvp

    v = 1*vp+1*Im*Re;

output = {'V': np.array(v_list),
          'I': np.array(II),
          'sf': 1/dt,
          'c': Cm,
          'reves': [vl, ve, vi],
          'searchtime': [0,100]}

savemat("gegi_point_output.mat", output)