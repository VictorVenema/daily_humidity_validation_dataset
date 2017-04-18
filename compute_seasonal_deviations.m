function seasonalPerturb = compute_seasonal_deviations(seasonalBreakSize)
% Computes the seasonal cycle of the deviations by smoothing white noise.

% Settings
valuesInYear = 366;
windowSize   = floor(valuesInYear/5);

% Generate white noise
seasonalPerturb = randn(valuesInYear,1);
seasonalPerturb = repmat(seasonalPerturb, [3 1]);

% figure(1)
% plot(seasonalPerturb)

% Smooth the white noise 4 times
filterFunction = ones(1,windowSize)/windowSize;
for i=1:4
    seasonalPerturb = filter(filterFunction,1,seasonalPerturb);   
    seasonalPerturb = seasonalPerturb(valuesInYear:valuesInYear*2-1);
    seasonalPerturb = repmat(seasonalPerturb, [3 1]);
end

% figure(11)
% plot(seasonalPerturb)

% Crop and normalise the seasonal cycle
seasonalPerturb = seasonalPerturb(valuesInYear:valuesInYear*2-1);
seasonalPerturb = seasonalPerturb - mean(seasonalPerturb(:));
seasonalPerturb = seasonalPerturb / std(seasonalPerturb(:));

% figure(12)
% plot(seasonalPerturb)

% Scale the seasonal cycle to the wanted size
seasonalPerturbSize  = randn(1)*seasonalBreakSize;
seasonalPerturb = seasonalPerturb * seasonalPerturbSize;

% figure(13)
% plot(seasonalPerturb)

% Compute the minimum or the maximum and shift this towards the summer if
% necessary.
if ( rand(1) < 0.5 )
    [dummy, index] = min(seasonalPerturb);
else
    [dummy, index] = max(seasonalPerturb);
end
if ( index <= 5*30 )
    shift = 7*30-index;
    seasonalPerturb = circshift(seasonalPerturb, shift);
end
if ( index >= 9*30 )
    shift = 8*30-index;
    seasonalPerturb = circshift(seasonalPerturb, shift);
end
