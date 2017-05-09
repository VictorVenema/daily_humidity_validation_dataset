function iPos = compute_break_positions(data, date, noValues, taperBreakFreqBegin)
% Computes the positions of the breaks. First computes the probability of
% the breaks per year for every position if taperBreakFreqBegin==1 or alternatively uses a
% constant probability. Then determines the break probability per day and
% draws random number to set the breaks.

% Default one break per 13 year
breakFreq = ones(1,noValues)/13; 

if ( taperBreakFreqBegin )
    % First 15 years the frequency gradually declines from one per 10 years to one per 13 years
    index = find(isfinite(data)); % Compute first year with data.
    indexBegin = index(1); clear index;
    dateBegin = date.year(indexBegin);
    indexEnd = find(dateBegin+15 == date.year); % Compute 15th year with data.
    indexEnd = indexEnd(1)-1;
    res = (breakFreq(1)-0.1)/(indexEnd-indexBegin);
    breakFreq(indexBegin:indexEnd) = 0.1:res:breakFreq(1); % insert higher break frequency.
end
% plot(breakFreq)

randomNos = rand(1,noValues)*365.24; % Multiplied by 365.24 to convert probability per year to per day.
iPos = find(randomNos < breakFreq); % Determine position of the breaks (the number of which may differ from the average) 
