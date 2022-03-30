function resampToOneMM(subj)

disp(['resampling ' subj '...']);
V = spm_vol(subj);
voxsiz = [1 1 1]; % new voxel size in mm
bb = spm_get_bbox(V);
VV(1:2) = V;
VV(1).mat = spm_matrix([bb(1,:) 0 0 0 voxsiz])*spm_matrix([-1 -1 -1]);
VV(1).dim = ceil(VV(1).mat \ [bb(2,:) 1]' - 0.1)';
VV(1).dim = VV(1).dim(1:3);
spm_reslice(VV,struct('mean',false,'which',1,'interp',1,'prefix','r'));