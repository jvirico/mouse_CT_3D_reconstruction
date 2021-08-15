function f = backproject_linear(q, rVec, phiVec, xVec, yVec, intpol)

[xGrid, yGrid] = meshgrid(xVec, yVec);
f = zeros(size(xGrid));
Nr = length(rVec);
Nphi = length(phiVec);
deltaR = rVec(2) - rVec(1);

switch intpol
  case 'nearest'
    for phiIx = 1:Nphi
      phi = phiVec(phiIx);
      proj = q(:, phiIx);
      r = xGrid * cos(phi) + yGrid * sin(phi);
      rIx = round(r / deltaR + (Nr + 1) / 2);
      f = f + proj(rIx);
    end
  case 'linear'
    
    %We iterate for each of the 100 angles
    for phiIx = 1:Nphi

      phi = phiVec(phiIx); %get the current angle
      proj = q(:, phiIx); %get the projection at angle phi from sinogram
      
      r = xGrid * cos(phi) + yGrid * sin(phi);
      
      rIx = r / deltaR + (Nr + 1) / 2;
      
      %left voxel
      r_left = xGrid * cos(phi) + yGrid * sin(phi);
      rIx_left = floor(r_left / deltaR + (Nr + 1) / 2);
      wl = 1 - (rIx - rIx_left);
      
      %right voxel
      r_right = xGrid * cos(phi) + yGrid * sin(phi);
      rIx_right = ceil(r_right / deltaR + (Nr + 1) / 2);
      wr = 1 - wl;
      
      %adding weighted voxels
      f = f + proj(rIx_left) .* wl + proj(rIx_right) .* wr;
    end
    
  otherwise
    error('Unknown interpolation.');
end

f = f * pi / (Nphi*deltaR);