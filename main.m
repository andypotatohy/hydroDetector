clear

addpath(genpath([fileparts(which(mfilename)) filesep 'lib/']));

subjList = {'/PATH/TO/YOUR/MRI/SUBJ1/T1.nii';
            '/PATH/TO/YOUR/MRI/SUBJ2/T1.nii'};
% Please enter full path for the input MRI(s); you may enter as many MRI as
% you want

p_hydro = nan(length(subjList),1);
for indSub=1:length(subjList)
    
    subj = subjList{indSub};
    
    disp(['Working on ' subj ' ...']);
    [pth,nam,ext] = fileparts(subj);
    if isempty(pth), pth = pwd; end
    
    %% resampling to 1mm
    hdr = niftiinfo(subj);
    if any(hdr.PixelDimensions~=1)
        if ~exist([pth filesep 'r' nam ext],'file')
            resampToOneMM(subj);
        end
        nam = ['r' nam];
    end
    
    %% SPM unified seg
    if ~exist([pth filesep nam '_seg8.mat'],'file')
        start_seg([pth filesep nam ext]);
        for t=1:6, delete([pth filesep 'c' num2str(t) nam '.nii']); end
    end
    
    %% warp TPM to native space
    if ~exist([pth filesep nam '_indiTPM.nii.gz'],'file')
        warpTPM(pth,nam,ext);
    end
    
    %% prepare and run MultiPrior for segmentation
    if ~exist([pth filesep nam '_seg.nii.gz'],'file')
        fid = fopen('lib/multiPriors/CV_folds/testData.txt','w');
        fprintf(fid,'%s\n',[pth filesep nam ext]);
        fclose(fid);
        fid = fopen('lib/multiPriors/CV_folds/tpm.txt','w');
        fprintf(fid,'%s\n',[pth filesep nam '_indiTPM.nii.gz']);
        fclose(fid);
        
        % You may need to do "setenv('LD_LIBRARY_PATH', '')" before running MultiPrior from
        % Matlab, or simply just run below in the system terminal
        cmd = 'python lib/multiPriors/SEGMENT.py lib/multiPriors/configFiles/config.py';
        system(cmd);
    end
    
    %% extract features from segmentation
    feat = extractFeatures(pth,nam,ext);
    
    %% run regression classifier to dectect hydrocephalus requiring treatment
    p_hydro(indSub) = classify(feat);
    
end

%% output results
for indSub=1:length(subjList)
    disp(['Probability of hydrocephalus for ' subj ' is ' num2str(p_hydro(indSub)) '.']);
end