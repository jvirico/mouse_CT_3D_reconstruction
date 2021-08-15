Nx =   259;                       %   number   of   grid points in x
Ny =   100;                       %   number   of   grid points in y
Nr =   279;                       %   number   of   detector elements
Nphi   = 180;                     %   number   of   projection angles

muest = 200;

xLen = Nx * muest;                 %   side of reconstructed rectangle
yLen = Ny * muest;                 %   side of reconstructed rectangle
phiLen   = pi;                     %   angular interval
rLen = Nr * muest;                 %   length of detector

phiVec   = (0   :   Nphi   - 1)   *    phiLen   / Nphi;
rVec =   (0.5   :   Nr -   0.5)   *    rLen /   Nr - rLen / 2;
xVec =   (0.5   :   Nx -   0.5)   *    xLen /   Nx - xLen / 2;
yVec =   (0.5   :   Ny -   0.5)   *    yLen /   Ny - yLen / 2;


figure(1); colormap gray;
Nslices = 496;
Nproj = 180;
m = zeros(496,290,180);
mouse3D = zeros(Ny,Nx,Nslices);
p = zeros(290,180);
k = 1;

% Loading multiimage into memory
for i = 1:Nproj
    mouse = imread('./data/mouse.tif',i);
    m(:,:,i) = mouse(:,:);
end

for i = 201:201
    % Resampling to create Sinograms
    p(:,:) = m(i,:,:);
    
    % Filtered Backprojecting Sinograms
    q = rampfilter(p, rVec, 'signal');
    f = backproject_linear(q, rVec, phiVec, xVec, yVec, 'linear');

    subplot(1,2,1);imagesc(p); title(['Sinogram (slice ', int2str(i),')']);pause(0);
    subplot(1,2,2);imagesc(yVec, xVec, f);title(['Reconstruction (Sinogram ', int2str(i),')'])
    pause(0);
    
    % Stacking 2Ds to build the 3D reconstruction
    mouse3D(:,:,k) = f;
       
    % Saving subplot(1,2,2) for video generation
    M(k) = getframe;
    k = k+1;
end

% Visualizing 3D reconstruction
%load mri;
%img = squeeze(mouse3D);
%figure(2);
%imshow3D(img, [], 1);
%pause(0);

% Saving video
v = VideoWriter('mouse_3D_reconstruction.avi');
v.FrameRate = 60;
open(v);
writeVideo(v,M);
close(v);

% Re-normalization and saving in a .tif
mn=min(min(min(mouse3D)))
mx=max(max(max(mouse3D)))
B_P_P = uint8(((mouse3D)-mn).*(255/(mx-mn)));

for k = 1:Nslices
    if(k==1)
        imwrite(B_P_P(:,:,k),'R.tif','WriteMode','overwrite');
    else
        imwrite(B_P_P(:,:,k),'R.tif','WriteMode','append');
    end
end
