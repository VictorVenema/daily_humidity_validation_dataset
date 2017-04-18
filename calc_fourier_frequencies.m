function freq = calc_fourier_frequencies(samplingInterval, noValues, orderstr)

if ( nargin < 3 )
    orderstr = 'posneg'; % Default ordering of the frequencies is first positve then negative
else
    orderstr = lower(orderstr);
end

if ( (strcmp(orderstr, 'posneg') == 0) & (strcmp(orderstr, 'negpos') == 0) & (strcmp(orderstr, 'onlypos') == 0) )
    error('Order of frequencies not well specified by the string-variable orderstr.')
end

freqRes = 1/(noValues*samplingInterval);
freq = 0:freqRes:(1/(2*samplingInterval));

if strcmp(orderstr, 'onlypos') == 0
    if strcmp(orderstr, 'posneg') == 1
        if odd(noValues)
            freq = [freq(1:end), -1*flipdim(freq(2:end),2)];
        else
            freq = [freq(1:end), -1*flipdim(freq(2:end-1),2)];
        end
    else
        if odd(noValues)        
            freq = [-1*flipdim(freq(2:end),2), freq(1:end)  ];            
        else
            freq = [-1*flipdim(freq(2:end),2), freq(1:end-1)];
        end
    end
end
