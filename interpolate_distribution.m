function [distOut, varargout] = interpolate_distribution(distIn, noValuesOut, methodstr)
% This function "interpolates" a distribution. In other words from the 
% input distribution (distIn) it calculates a new distribution (distOut)
% with another number of values (noValuesOut).
%
% It has four methods to do so specified by methodstr.
%
% The nearest_neighbour methods copy the input values a certain number of
% times (or in case noValuesOut is smaller than the number of input values
% (noValuesIn) it removes part of the values). 
% In case the number of output values is not a multiple of the number of
% input values nearest_neighbour_wide chooses more points from the eges,
% whereas nearest_neighbour_narrow choose more points from the middle.
%
% The method interpolation calculates a vector with "indices" of
% noValuesOut points from 1 to noValuesIn. It uses these indices to
% interpolate the sorted distIn values.
%
% The method kernel performs a kernel estimate of the input data to
% generate the output distribution. This method seems to broaden the input
% distribution rather strongly. Use with care.

% First version:
% Victor Venema, 24 April 2008


% Process input
if ( nargin < 3 )
    methodstr = 'nearest_neighbour_wide';
else
    methodstr = lower(methodstr);
    if ~( strcmp(methodstr, 'nearest_neighbour_wide')   == 1 || ...
          strcmp(methodstr, 'nearest_neighbour_narrow') == 1 || ...            
          strcmp(methodstr, 'interpolation')            == 1 || ...
          strcmp(methodstr, 'kernel')                   == 1 )
        error('Unknown method specified to interpolate distribution.')
    end
end

% Initialise
noValuesIn = numel(distIn);

% Call appropriate interpolation functions
if ( strcmp(methodstr, 'nearest_neighbour_wide') == 1 )
    [distOut, index] = interpolate_distribution_nearest_neighbour_wide(distIn, noValuesIn, noValuesOut);
end

if ( strcmp(methodstr, 'nearest_neighbour_narrow') == 1 )
    [distOut, index] = interpolate_distribution_nearest_neighbour_narrow(distIn, noValuesIn, noValuesOut);
end

if ( strcmp(methodstr, 'interpolation') == 1 )
    distOut = interpolate_distribution_interpolation(distIn, noValuesIn, noValuesOut);
end

if ( strcmp(methodstr, 'kernel') == 1 )
%     error('Kernel version not yet implemented.')    
    distOut = interpolate_distribution_kernel(distIn, noValuesOut);
end

if ( nargout > 0 )
    varargout{1} = index;
end

end



function [distOut, index] = interpolate_distribution_nearest_neighbour_wide(distIn, noValuesIn, noValuesOut)    

    if ( noValuesOut > 1 )
        res   = (noValuesIn)/(noValuesOut-1);
        index = 1:res:noValuesIn+1;
        index = index - 0.5; 
        index(end) = index(end)-(1e4*eps);
        index = round(index);        
        distOut = distIn(index);
    else
        distOut = mean(distIn(:));
        index = NaN;
    end
end


function [distOut, index] = interpolate_distribution_nearest_neighbour_narrow(distIn, noValuesIn, noValuesOut)    

    if noValuesOut > 1
        res   = (noValuesIn-1)/(noValuesOut-1);
        index = 1:res:noValuesIn;
        index(end) = index(end);
        index = round(index);
        distOut = distIn(index);
    else
        distOut = mean(distIn(:));
        index = NaN;
    end
end


function distOut = interpolate_distribution_interpolation(distIn, noValuesIn, noValuesOut)

   if noValuesOut > 1
        res   = (noValuesIn-1)/(noValuesOut-1);
        indexOut = 1:res:noValuesIn;
        indexOut(end) = indexOut(end)-(10*eps);
        
        distInSorted = sort(distIn);
        distOut = interp1(1:numel(distIn), distInSorted, indexOut);
        
    else
        distOut = mean(distIn(:));
    end

end


function distOut = interpolate_distribution_kernel(distIn, noValuesOut)    

    if noValuesOut > 1
%         minVal = min(distIn(:));
%         maxVal = max(distIn(:));
%         res = (maxVal - minVal)/noValuesOut/10;
%         xi = minVal-100*res:res:maxVal+100*res;
        
        [pdf, xi] = ksdensity(distIn, 'npoints', 100*noValuesOut);
        cdf = cumsum(pdf);
        cdf = cdf/cdf(end);
        
        plot(pdf, 'r-')
        hold on
        plot(cdf, 'b-')
        hold off
       
        res = 1/(noValuesOut);
        oldProb = -0.5*res;
        counter = 1;
        distOut = repmat(NaN, 1, noValuesOut);
        for i=1:100*noValuesOut
            if ( cdf(i) - oldProb > res )
                distOut(counter) = xi(i);
                counter = counter + 1;
                oldProb = oldProb + res;
            end
        end
    else
        distOut = mean(distIn(:));
    end
end



