function deterministicPerturb = compute_stochastic_perturbations(breakSizeMean, breakBias)

% Generate smooth perturbation of the humidity in percent for every percent
deterministicPerturb = fft_cloud(8, 4);                      % Generate power law power spectrum with exponent -4
deterministicPerturb = deterministicPerturb(1:100);% Crop

% Normalise
deterministicPerturb = deterministicPerturb - mean(deterministicPerturb);
deterministicPerturb = deterministicPerturb / std(deterministicPerturb);                

% Set size to the wanted size
perturbSize  = randn(1) * breakSizeMean;
deterministicPerturb = deterministicPerturb * perturbSize + breakBias;
deterministicPerturb = deterministicPerturb - min(deterministicPerturb);

a=0;
   