function data = lengthen_shorten_dataset_daily_zamg(year, month, data, noValues)
% Adjusted for the short time series of the ZAMG humidity dataset, no
% longer forces the mirroring datapart to start with a leap year.

currrentNoValues = size(data, 1);

% Lengthen series by mirroring
while ( currrentNoValues < noValues )
    beginYear = year(1);
    if ( month(1) ~= 1 )
        beginYear = beginYear + 1;
    end    
    index = find(year == beginYear);
    bi1 = index(1);
    ei1 = size(data,1);

    bi2 = bi1;
    ei2 = ei1;
    
    data    = [flipdim(data(bi2:ei2,:),1); data(bi1:ei1,:)];
    currrentNoValues = size(data, 1);
end

% Shorten to the right size
data = data(1:noValues,:);
