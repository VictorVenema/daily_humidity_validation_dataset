function reference = insert_missing_data(reference, date)
% Insert three types of missing data.

[noValues, noStations] = size(reference);

% Missing data at the beginning of the period to simulate network buildup
index = find(date.year == 1925, 1);
mask = create_station_mask_beginning(noValues, index, noStations, NaN, 1, 1);
reference(mask == 0) = NaN;

% Missing data during WWII
warFractionMissing = 0.75;
mask = create_station_mask_WWII(date, noValues, noStations, warFractionMissing, NaN, 1);
reference(mask == 0) = NaN;

% Random missing data
mask = create_station_mask_random(noValues, noStations, 0.0016, 0.75, 1);
reference(mask == 0) = NaN;

drawnow


function stationMask = create_station_mask_beginning(length, lastBegin, noStations, roundInteger, stationOrder, verbose)

if ( nargin < 1 || isempty(length) )
%     length = 100*12;
end
if ( nargin < 2 || isempty(lastBegin) )
%     lastBegin = 25*12;
end
if ( nargin < 3 || isempty(noStations) )
    noStations = 25;
end
if ( nargin < 4 || isempty(roundInteger) )
    roundInteger = 12; % 1: random, 2: oldest stations first
end
if ( nargin < 5 || isempty(stationOrder) )
    stationOrder = 1; % 1: random, 2: oldest stations first
end
if ( nargin < 6 || isempty(verbose) )
    verbose = 1;
end

noStationsBeginning = 3;

res = lastBegin/(noStations-noStationsBeginning);
begin = round(0:res:lastBegin);
if ( isfinite(roundInteger) )
    begin = ceil(begin/roundInteger) * roundInteger;
else
    begin = ceil(begin);
end
if (noStationsBeginning > 1 )
    begin = [begin repmat(NaN, [1 noStationsBeginning-1])];
end

    
if (stationOrder == 1 )
    [dummy, index] = sort(rand(1,noStations));
else
    index = 1:noStations;
end

stationMask = ones(length, noStations);
for i=1:numel(begin)
    if ( begin(index(i)) >= 1 && isfinite(begin(index(i))) )
        stationMask(1:begin(index(i)), i) = 0;
    end
end
	
if verbose
    figure(1)
    imagesc(1:length, 1:noStations, squeeze(stationMask(:,:))')
    xlabel('Time')
    ylabel('Station no.')
    title('Missing data at beginning')
end
	

function stationMask = create_station_mask_WWII(date, length, noStations, warFractionMissing, roundInteger, verbose)

if ( nargin < 2 || isempty(length) )
%     length = 100*12;
end
if ( nargin < 3 || isempty(noStations) )
    noStations = 25;
end
if ( nargin < 4 || isempty(warFractionMissing) )
    warFractionMissing = 0.5;
end
if ( nargin < 5 || isempty(roundInteger) )
%     roundInteger = 12; % 1: random, 2: oldest stations first
end
if ( nargin < 6 || isempty(verbose) )
    verbose = 1;
end

stationMask = ones(length, noStations);

maskedStations = 1:noStations;
indexMaskedStations = 1;
if ( sum(maskedStations) > 0 )
    for iindex = 1946:-1:1940
        if ( ~isempty(indexMaskedStations) )        
            indexMaskedStations = find(rand(1,numel(maskedStations)) < warFractionMissing);
            while ( numel(indexMaskedStations)+3 > noStations )                
                indexMaskedStations = find(rand(1,numel(maskedStations)) < warFractionMissing);
            end
            maskedStations = maskedStations(indexMaskedStations);
            stationMask(date.year == iindex, maskedStations) = 0;
        end
    end
end

	
if verbose
    figure(2)
    imagesc(squeeze(stationMask(:,:))')
    xlabel('Time')
    ylabel('Station no.')
    title('WWII missing data')
end
	


function mask = create_station_mask_random(noValues, noStations, fraction, fractionNext, verbose)

mask = ones(noValues, noStations);
noValuesTotal = noValues*noStations;

index = find(rand(size(mask(:))) < fraction);
mask(index) = 0;

while ( ~isempty(index) )
    indexNext = find(rand(size(index(:))) < fractionNext);
    index = index(indexNext)+1; %#ok<FNDSB>
    index = index(index<noValuesTotal);
    mask(index) = 0;
end
fractionImplemented = sum(mask(:)==0)/noValuesTotal; %#ok<NASGU>

if verbose
    figure(3)
    imagesc(squeeze(mask(:,:))')
    xlabel('Time')
    ylabel('Station no.')
    title('Random missing data')
end
