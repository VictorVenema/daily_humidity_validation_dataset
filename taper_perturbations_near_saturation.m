function perturbations2D = taper_perturbations_near_saturation(seasonalBreakPerturb, humidtyPerturb)
% This function was originally written to limit the size of the
% perturbations near saturation (100%), but later extended to do the same
% near 0% humidty to avoid negative values.

perturbations2D = repmat(seasonalBreakPerturb, [1 100]);
perturbations2D = perturbations2D + repmat(humidtyPerturb, [366,1]);

% % Implement tapering near 100%
maxPerturb = max(abs(perturbations2D(:)));
maxPerturb = ceil(maxPerturb);
biMax = max([50 100-maxPerturb*4]);
temp =perturbations2D(:,biMax:100);
maxPerturbEnd = max(abs(temp(:)));

windowSize = ceil(maxPerturbEnd*4); 
windowSize = min([windowSize 50]);
window = hanning(windowSize*2);
window = window(windowSize:end)';
window = [window, 0];
bi = 100-numel(window)+1;
ei = 100;

% % Implement tapering near 0%
eiMax = min([maxPerturb*4 50]);
temp =perturbations2D(:,1:eiMax);
maxPerturbBegin = max(abs(temp(:)));

windowSize = ceil(maxPerturbBegin*4);
windowSize = min([windowSize 50]);
window0 = hanning(windowSize*2);
window0 = window0(1:windowSize)';
window0 = [0 window0];
bi0 = 1;
ei0 = numel(window0);

for iSeason = 1:366
    perturbations2D(iSeason, bi:ei)     = perturbations2D(iSeason, bi:ei)     .* window;    
    perturbations2D(iSeason, bi0:ei0) = perturbations2D(iSeason, bi0:ei0) .* window0;
end
