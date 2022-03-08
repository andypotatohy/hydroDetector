# hydroDetector
An automated pipeline to detect hydrocephalus from brain MRIs

## Pre-requisite

You will need Matlab R2017b or newer, Python 2.7, Tensorflow 2.1.0, and Keras 2.2.4.

## Getting started

After you download the zip file, unzip it, launch your Matlab, make sure you are under the root directory (i.e., you can see `lib/`, and the `main.m` file). Open the `main.m`, and enter the MRI to your subjects in the subjList variable at 5th line, then run the `main.m`.

You will get the segmentation of the input head MRIs in the same folder of the MRIs.

## Acknowledgements

If you use this code in your research, please cite:

Huang, Y., Moreno, R., Malani, R., Meng, A., Swinburne, N., Holodny, A.I., Choi, Y., Parra, L.C.,
Young, R.J., 2021, Deep Learning Achieves Neuroradiologist-Level Performance in Detecting Hydro-
cephalus Requiring Treatment, doi.org/10.1101/2021.01.19.427328

This work was supported in part through the NIH grants P30CA008748, R01NS095123, R01CA247910, R01MH111896, R21NS115018, R01CA247910, R21NS115018, R01DC018589, R01MH111439. Support was also provided by the Memorial Sloan Kettering Cancer Center Department of Radiology.

## License

General Public License version 3 or later. See LICENSE.md for details.

This software uses free packages from the Internet, except Matlab, which is a proprietary software by the MathWorks. You need a valid Matlab license to run this software.

The license only applies to the scripts and documentations in the root directory in this package and excludes those programs stored in the `lib/` directory. The software under `lib/` follow their respective licenses. This software is only intended for non-commercial use.

(c) Yu (Andy) Huang, Department of Radiology, Memorial Sloan Kettering Cancer Center

huangy7@mskcc.org

March 2022