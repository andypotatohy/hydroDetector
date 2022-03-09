#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
@author: Yu (Andy) Huang, Mar 2022
"""

import os
import numpy as np
wd = os.getcwd()

dataset = ''

############################## Load dataset #############################
 
    
TPM_channel = '/lib/multiPriors/CV_folds/tpm.txt'
    
segmentChannels =  ['/lib/multiPriors/CV_folds/testData.txt']
segmentLabels = ''

output_classes = 8


############################# MODEL PARAMETERS ###########################
model = 'MultiPriors_noDownsampling'
segmentation_dpatch = 51*3

path_to_model = 'lib/multiPriors/bestModel.h5'

############################ TEST PARAMETERS ##############################
quick_segmentation = True
softmax_output = False
OUTPUT_PATH = ''
test_subjects = 1
list_subjects_fullSegmentation = []
size_test_minibatches = 1
saveSegmentation = True

#session =  path_to_model.split('/')[-3]

penalty_MATRIX = np.eye(output_classes,output_classes,dtype='float32')

comments = ''
