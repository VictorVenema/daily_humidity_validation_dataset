function deterministicPerturb = compute_deterministic_perturbations(breakSizeMean, breakSizeDeformation, breakBias)

% Generate smooth perturbation of the humidity in percent for every percent
deterministicPerturb = fft_cloud(8, 4);                       % A power law power fuction with exponent -4
deterministicPerturb = deterministicPerturb(1:100); % Crop to percent range of humidity

% Normalise
deterministicPerturb = deterministicPerturb - mean(deterministicPerturb);
deterministicPerturb = deterministicPerturb / std(deterministicPerturb);                

% Scale to wanted size
perturbSize  = randn(1)*breakSizeDeformation;
deterministicPerturb = deterministicPerturb * perturbSize;

perturbSize  = randn(1)*breakSizeMean;
deterministicPerturb = deterministicPerturb + perturbSize + breakBias;

% figure(100)
% plot(deterministicPerturb, 'b-')
% hold on
