function plot_deterministic_perturbation

breakSizeMeanDet = 0.7; 
breakSizeDeformation = 1.5; 
seasonalBreakSizeDet = 0.7;
trendBias = 0.02; % Bias of the perturbaition in % per year, leading to a trend bias in the inhomogeneous data

seasonalBreakPerturb =  compute_seasonal_deviations(seasonalBreakSizeDet);
breakBias = trendBias * ( 0 );
deterministicPerturb = compute_deterministic_perturbations(breakSizeMeanDet, breakSizeDeformation, breakBias);
perturbations2DDet = taper_perturbations_near_saturation(seasonalBreakPerturb, deterministicPerturb); % Taper near 100% and 0% humidity to prevent unphysical values

figure(11)
imagesc(perturbations2DDet)
colorbar
xlabel('humidity [%]')
ylabel('Julian day [ ]')

save_current_figure(unique_filename('/data/zamg_humidity/example_deterministic_perturbation_', '.png'))

a=0; %#ok<NASGU>