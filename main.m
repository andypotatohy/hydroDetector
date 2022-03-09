clear

addpath(genpath([fileparts(which(mfilename)) filesep 'lib/']));

subjList = {'/home/andy/Desktop/test/T1_post.nii'};
% Please enter full path for the input MRI(s)

for indSub=1:length(subjList)
    
    subj = subjList{indSub};
    
    disp(['Working on ' subj ' ...']);
    [pth,nam,ext] = fileparts(subj);
    if isempty(pth), pth = pwd; end
    
    %% resampling to 1mm
    hdr = niftiinfo(subj);
    if any(hdr.PixelDimensions~=1)
        disp(['resampling ' subj '...']);
        V = spm_vol(subj);
        voxsiz = [1 1 1]; % new voxel size in mm
        bb = spm_get_bbox(V);
        VV(1:2) = V;
        VV(1).mat = spm_matrix([bb(1,:) 0 0 0 voxsiz])*spm_matrix([-1 -1 -1]);
        VV(1).dim = ceil(VV(1).mat \ [bb(2,:) 1]' - 0.1)';
        VV(1).dim = VV(1).dim(1:3);
        spm_reslice(VV,struct('mean',false,'which',1,'interp',1,'prefix','r'));
        
        nam = ['r' nam];
    end
    
    %% SPM unified seg
    start_seg([pth filesep nam ext]);
    for t=1:6, delete([pth filesep 'c' num2str(t) nam '.nii']); end
    
    %% warp TPM to native space
    load([pth filesep nam '_seg8.mat']);
    tpm = spm_load_priors8(tpm);
    
    d1        = size(tpm.dat{1});
    d1        = d1(1:3);
    M1        = tpm.M;
    
    Kb  = max(lkp);
    d    = image(1).dim(1:3);
    
    [x1,x2,o] = ndgrid(1:d(1),1:d(2),1);
    x3  = 1:d(3);
    
    prm     = [3 3 3 0 0 0];
    Coef    = cell(1,3);
    Coef{1} = spm_bsplinc(Twarp(:,:,:,1),prm);
    Coef{2} = spm_bsplinc(Twarp(:,:,:,2),prm);
    Coef{3} = spm_bsplinc(Twarp(:,:,:,3),prm);
    
    M = M1\Affine*image(1).mat;
    
    QQ = zeros([d(1:3),Kb],'single');
    
    
    for z=1:length(x3),
        
        
        [t1,t2,t3] = defs(Coef,z,MT,prm,x1,x2,x3,M);
        
        qq   = zeros([d(1:2) Kb]);
        b   = spm_sample_priors8(tpm,t1,t2,t3);
        
        for k1=1:Kb,
            %                     q(:,:,k1) = sum(q1(:,:,lkp==k1),3).*b{k1};
            qq(:,:,k1) = b{k1};
        end
        
        QQ(:,:,z,:) = reshape(qq,[d(1:2),1,Kb]); % tpm in mri space not normalized
        
    end
    
    sQQ = sum(QQ,4);
    for k1=1:Kb
        QQ(:,:,:,k1) = QQ(:,:,:,k1)./sQQ; % nomalized tpm in mri space
    end
    
    % tpmFile={res.tpm.fname}';
    hdr = niftiinfo([pth filesep nam ext]);
    hdr.ImageSize = cat(2,hdr.ImageSize,6);
    hdr.PixelDimensions = cat(2,hdr.PixelDimensions,0);
    hdr.Datatype = 'single'; hdr.BitsPerPixel = 32;
    niftiwrite(QQ,[pth filesep nam '_indiTPM.nii'],hdr,'compressed',1);
    
    %% prepare for MultiPrior
    fid = fopen('lib/multiPriors/CV_folds/testData.txt','w');
    fprintf(fid,'%s\n',[pth filesep nam ext]);
    fclose(fid);
    fid = fopen('lib/multiPriors/CV_folds/tpm.txt','w');
    fprintf(fid,'%s\n',[pth filesep nam '_indiTPM.nii.gz']);
    fclose(fid);
    
    %% run MultiPrior for segmentation
    % You may need to do "setenv('LD_LIBRARY_PATH', '')" before running MultiPrior from
    % Matlab, or simply just run below in the system terminal
    cmd = 'python lib/multiPriors/SEGMENT.py lib/multiPriors/configFiles/config.py';
    system(cmd);
    
end