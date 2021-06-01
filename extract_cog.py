#!/usr/bin/python

import os
import sys
import nibabel as nib
import numpy as np
import scipy.ndimage as ndimage

seg = str(sys.argv[1])
out = str(sys.argv[2])

seg_img = nib.load(seg).get_data()
aff = nib.load(seg).affine
seg_cc = ndimage.label(seg_img)[0]
labels = np.unique(seg_cc)

zero_vol = np.zeros((seg_img.shape[0],seg_img.shape[1],seg_img.shape[2]))
for j in range(len(labels)-1):
        idx_comp = np.where(seg_cc == labels[j+1])
        mx = np.round(np.mean(idx_comp[0])).astype('int')
        my = np.round(np.mean(idx_comp[1])).astype('int')
        mz = np.round(np.mean(idx_comp[2])).astype('int')
        zero_vol[mx,my,mz] = 1
        
img = nib.Nifti1Image(zero_vol.astype('float'), aff)
nib.save(img, os.path.join( out + "_centroids.nii.gz" ))


