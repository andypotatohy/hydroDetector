function feat = extractFeatures(pth,nam,ext)

disp(['extracting features for ' pth filesep nam ext ' ...']);
landmarkInTPM = [62 82 137; % central sag
    62 79 124; % third ventricle
    62 66 128; % posterior commissure
    62 77 140; % lateral ventricles
    84 80 111; % right temporal horn
    40 79 112; % left temporal horn
    62 66 138; % above posterior commissure
    62 81 134; % for getting front horns
    73 66 145; % right pt to connect PC
    51 66 144; % left pt to connect PC
    72 103 130; % right front horn
    52 103 130; % left front horn
    62 68 130]; % for getting collateral trigones

load([pth filesep nam '_seg8.mat'],'image','tpm','Affine');
tpm2mriAxl = inv(image(1).mat)*inv(Affine)*tpm(1).mat;

dataForVol = niftiread([pth filesep nam '_seg.nii.gz']);
dataForAxlFeat = dataForVol;

landmarksAxl = zeros(size(landmarkInTPM,1),size(landmarkInTPM,2));
for i=1:size(landmarkInTPM,1)
    temp = tpm2mriAxl * [landmarkInTPM(i,:) 1]';
    landmarksAxl(i,:) = round(temp(1:3)');
end

surfCSF = (dataForVol==4);
surfCSFvol = sum(surfCSF(:));

brain = (dataForVol==2 | dataForVol==3);
brainVol = sum(brain(:));

ven = (dataForVol==5);
venVol = sum(ven(:));

intraCranialVol = sum(brain(:))+sum(surfCSF(:))+sum(ven(:));
%         surfCSFvol = csfVol - venVol;

% make a sphere around the temporal horn (set sphere to be 10mm radius, ARBITRARY)
radius = 10;
ven = (dataForAxlFeat==5); 
[x,y,z] = ndgrid(1:size(ven,1),1:size(ven,2),1:size(ven,3));
m = sqrt((x-landmarksAxl(5,1)).^2+(y-landmarksAxl(5,2)).^2+(z-landmarksAxl(5,3)).^2)<=radius | sqrt((x-landmarksAxl(6,1)).^2+(y-landmarksAxl(6,2)).^2+(z-landmarksAxl(6,3)).^2)<=radius;
tHorn = m&ven;
tHornVol = sum(tHorn(:));

ven = (dataForAxlFeat==5); 
siz = sizeOfObject(ven);
ven = bwareaopen(ven,siz(2)+1);

% use max min, no sphere intersection
z0 = landmarksAxl(13,3);
z = z0-10:z0+10;
d1 = zeros(length(z),1);
for i=1:length(z)
    [r_c,c_c] = find(squeeze(ven(:,1:landmarksAxl(13,2),z(i)))==1);
    if ~isempty(r_c), d1(i) = max(r_c)-min(r_c); end
end
[d1,indM] = max(d1);
%         figure(1); clf; imagesc(squeeze(dataForAxlFeat(:,:,z(indM)))==5); title(mrSession{s}); pause
%         figure(1); clf; imagesc(squeeze(dataForAxlFeat(:,:,z(indM)))==6); title(mrSession{s}); pause
slice = squeeze(dataForAxlFeat(:,:,z(indM)));
bw_c = (slice==6); [r_c,c_c] = find(bw_c==1);
d2 = max(r_c)-min(r_c);
MRHI = d1/d2;

% 3D extent, done in axial slices using Matlab function
ven = (dataForAxlFeat==5); 
siz = sizeOfObject(ven);
ven = bwareaopen(ven,siz(2)+1);
z0 = landmarksAxl(4,3);
z = max(z0-5,1):min(z0+10,size(dataForAxlFeat,3)); % THIS IS ARBITRARY
stats = regionprops3(ven(:,:,z),'all');
extent3Daxl = stats.Extent(find(stats.Volume == max(stats.Volume)));

feat = [venVol./intraCranialVol venVol./surfCSFvol venVol./brainVol tHornVol./intraCranialVol MRHI extent3Daxl];
