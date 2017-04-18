function [bestSurrogate, spectralDiffBest] = iaaft_loop_cat_1dm_difference(fourierCoeff, sortedValues, categories, standardDeviation, counterThreshold, errorThreshold, timeThreshold, interationsThreshold, iterativeCounterAmplitude, iterativeDenomAmplitude)
% function [bestSurrogate, spectralDiffBest] = iaaft_loop_cat_1dm(fourierCoeff, sortedValues, categories, maxNoPhases, standardDeviation, counterThreshold, errorThreshold, timeThresshold, iterativeCounterAmplitude, iterativeDenomAmplitude)
% INPUT: 
% fourierCoeff:    The 1 dimensional Fourier coefficients that describe the
%                  structure and implicitely pass the size of the matrix
% sortedValues:    A cell array with all the wanted amplitudes (e.g. LWC of LWP
%                  values) sorted in acending order for every sorted numbered category.
% categories:      A time series with numbered categories that determine
%                  which set of sortedValues should be used.
% counterThreshold A threshold for the number of iterations without an
%                  improvement of more than errorThreshold.
% errorThreshold:  A threshold for the error at which the algorithm will
%                  stop.
% 
% OUTPUT:
% surrogateBest:  The 1D IAAFT surrogate time series
% spectralDiff:   The RMS difference between the Fourier coefficients of
%                 the original and of the surrogate.

% Settings
if ( nargin < 5 || isempty(counterThreshold) )
    counterThreshold = 1e2; % Number of iterative steps with no improvement of more than errorThreshold before the program moves on.
end
if ( nargin < 6 || isempty(errorThreshold)  )
    errorThreshold = 2e-6; %
end
if ( nargin < 7 || isempty(timeThreshold)  )
    timeThreshold = +inf;
end
if ( nargin < 8 || isempty(interationsThreshold)  )
    interationsThreshold = +inf;
end
if ( nargin < 9 || isempty(iterativeCounterAmplitude)  )
    iterativeCounterAmplitude = 1;
    iterativeDenomAmplitude   = 10; % 10;
end

verbose = 1;
makePlots = 0; % Best used together with debugging.

% Initialse function
if ( numel(fourierCoeff) == numel(sortedValues)*2 )
    mirrorBool = 1;
else 
    mirrorBool = 0;
end
[noValues, noVar] = size(fourierCoeff);
if mirrorBool 
    noValuesHalf = noValues/2;
end
spectralDiffBest = +inf;
% standardDeviation = std(sortedValues{:});

% fourierCoeffAngles = angle(fourierCoeff);
fourierCoeff       = abs(fourierCoeff);

% if makePlots
%     figure(99)
%     imagesc_3d(angleDiffs)
% end

% Initialise the cell with the pointers to the categories
uniqueCategories = sort(unique(categories));
noCategories = numel(uniqueCategories);
catIndices = cell(noCategories,1);
noValuesCategory = zeros(1, noCategories);
indices = cell(1, noCategories);
for j=1:noCategories
    index = find(categories == uniqueCategories(j));
    catIndices{j} = index;
    noValuesCategory(j) = numel(index);
    indices{j} = init_regular_indices(iterativeCounterAmplitude, iterativeDenomAmplitude, noValuesCategory(j));
end
noIndices = size([indices{1}],2); % This name may be confusing, it is actually the number of vectors with indices

% The method starts with white noise
surrogate = rand(noValues,noVar);
surrogate = surrogate - mean(surrogate(:));
bestSurrogate = surrogate;

% Set counters
counter = 1;
bestCounter = 1;
counterSpec = 1;
maxCounter = 1e4;
spectralDiffg = zeros(maxCounter,1);

% Main iterative loop
indexFinite = find(isfinite(fourierCoeff));
tic
for stageCounter=1:2
    if (stageCounter == 2)
        % In this second round all amplitudes and coefficients are used
        % in the iteration, just like in the original iaaft algorithm.
        tic
        if ( verbose ), disp('Second stage'), end
%         iterativeCounterSpec      = iterativeDenomSpec;
%         iterativeCounterAmplitude = iterativeDenomAmplitude;
        % use the best surrogate as the new one.
        surrogate = bestSurrogate;   % The best surrogate of the first phase is the starting surrogate of the second phase
        spectralDiffBest = +inf; % make the second phase use the old surrogate as its best one up to now.
        counter = 0; % Set to zero to signify the selection of the best surrogate to wait at least one iteration
        bestCounter = 0;
        for j=1:noCategories            
            indices{j} = (1:noValuesCategory(j))'; % % init_regular_indices(iterativeCounterAmplitude, iterativeDenomAmplitude, noValuesX*noValuesY);
        end
        noIndices = 1;        
        if isfinite(counterThreshold)
            counterThreshold = min([100 counterThreshold]); % In the second round with the IAAFT algorithm, it doesn't help to iterate after convergence has stopped.
        end
    end
    
    while ( (toc < timeThreshold) && (bestCounter < counterThreshold) && (spectralDiffBest > errorThreshold) && (counter < interationsThreshold) )    % adapt the power spectrum

%         oldSurrogate = surrogate;
        x=ifft(surrogate);
        phase = angle(x);

        difference = sqrt( nanmean( (abs(x(:))-abs(fourierCoeff(:))).^2  ) );
        spectralDiff = difference/standardDeviation;
        spectralDiffg(counterSpec) = spectralDiff;
        counterSpec = counterSpec + 1;    
        if (counterSpec > maxCounter)
            counterSpec = 1;
        end

        if ( (spectralDiff < spectralDiffBest) && (counter > 1) )
            spectralDiffBest = spectralDiff;
            if ( verbose ), spectralDiffBest, end %#ok<NOPRT>
            bestSurrogate = surrogate;
            bestCounter = 0;
        else
            bestCounter = bestCounter + 1;
        end

        % Next line updated to change only the Fourier coefficients of the high frequencies (small time scales) 
        x(indexFinite) = fourierCoeff(indexFinite) .* exp(1i*phase(indexFinite));
        surrogate = fft(x);

        if ( verbose )
            fprintf(1, '%d: %d\n', counter, spectralDiff);
        end

        if (makePlots)
            figure(21)            
            plot(real(surrogate))
            title('Surrogate after spectal adaptation')
            axis tight
            drawnow
        end

        % adapt the amplitude distribution
        surrogate = real(surrogate);
        if mirrorBool 
            error('Not programmed yet')
%             [dummy,index] = sort(surrogate(1:noValuesHalf));
%             surrogate(index)=sortedValues;
%             [dummy,index]=sort(surrogate(1+noValuesHalf:end));
%             surrogate(index+noValuesHalf)=sortedValues;
        else
            % Adjust the difference time series
            for k = 1:noVar
                for m = k+1:noVar
                    randomNumber = ceil(rand(1)*noIndices);
                    diff = surrogate(:,k)-surrogate(:,m);
%                     diffNew = zeros(size(diff));
                    for n=1:noCategories
                        [dummy, index] = sort(diff(catIndices{n}));
                    
                        changeWeNeed = ( sortedValues{n}{k,m}(indices{n}(:,randomNumber)) - diff(catIndices{n}(index(indices{n}(:,randomNumber)))) )/ 2;
                        surrogate(catIndices{n}(index(indices{n}(:,randomNumber))),k) = surrogate(catIndices{n}(index(indices{n}(:,randomNumber))),k) + changeWeNeed;
                        surrogate(catIndices{n}(index(indices{n}(:,randomNumber))),m) = surrogate(catIndices{n}(index(indices{n}(:,randomNumber))),m) - changeWeNeed;                        
%                       diffNew(catIndices{n}(index(indices{n}(:,randomNumber)))) = sortedValues{n}{k,m}(indices{n}(:,randomNumber));
                    end
%                     surrogate(:,k) = surrogate(:,k) + diffNew/2;
%                     surrogate(:,m) = surrogate(:,m) - diffNew/2;
                end
            end
            % Adjust the time series values themselves
            for m=1:noVar
                randomNumber = ceil(rand(1)*noIndices);                
                for n=1:noCategories
                    [dummy, index] = sort(surrogate(catIndices{n},m));
                    surrogate(catIndices{n}(index(indices{n}(:,randomNumber))),m)=sortedValues{n}{m,m}(indices{n}(:,randomNumber));
                end                
            end
        end
        counter = counter + 1;

        
        if (makePlots)
            figure(22)
            plot(real(surrogate))
            title('Surrogate after amplitude adaptation')
            axis tight
            drawnow
        end
    end
end % for 2 stages of the algorithm

if mirrorBool
    plot(real(surrogateBest))
    bestSurrogate = bestSurrogate(1:noValuesHalf);
end
bestSurrogate = real(bestSurrogate);

