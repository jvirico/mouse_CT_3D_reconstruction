function q = rampfilter(p, rVec, domain)

Nr = length(rVec);
rDelta = rVec(2) - rVec(1);
rVecDouble = (-Nr:Nr-1) * rDelta;
Nphi = size(p,2);
odd = rem(Nr,2);

h = zeros(2*Nr, 1);
h(2-odd:2:end) = -1 ./ (pi^2 * rVecDouble(2-odd:2:end).^2);
h(Nr+1) = 1 / (4 * rDelta^2);
h = h * rDelta^2;
%subplot(2,2,1); plot(rVecDouble,h);

switch domain
  case 'signal'
    q = conv2(p, h, 'same');
  case 'fourier1'
    N = length(p);
    frqs=linspace(-1, 1, N).';
    h = abs( frqs );
    h = repmat(h, [1 N]);
    %plot(frqs,h);
    %title("Ramp Filter");
    P = fftshift(fft(ifftshift(p)));
    Q = P .* h;
    q = real(fftshift(ifft(ifftshift(Q), [], 1)));
  case 'fourier2'
    Hvec = 0.5*(-Nr:Nr-1)/Nr;
    H = fftshift(fft(ifftshift(h)));
    %subplot(2,2,2); plot(Hvec,real(H));
    Hmat = H * ones(1,Nphi);
    pp = [zeros((Nr+odd)/2, Nphi); p; zeros((Nr-odd)/2, Nphi)];
    P = fftshift(fft(ifftshift(pp), [], 1));
    Q = P .* Hmat;
    q = real(fftshift(ifft(ifftshift(Q), [], 1)));
    q = q((Nr+odd)/2+1:(Nr+odd)/2+Nr, :);
  otherwise
      error('Unknown domain.');
end