function plot_comparison_data_surrogate_detail

baseDirNameSurr = ['/data/zamg_humidity/Surrogate/Netzwerk8_voll_hom_vv.10/'];

currentDirNameSurr = baseDirNameSurr; % fullfile(baseDirNameSurr, subDirsSurr.name);
fprintf(1, '%s\n', currentDirNameSurr)
[stationNoSurr, dateSurr, surr] = read_zamg(currentDirNameSurr);
noStations1 = numel(stationNoSurr);
noValuesData = size(surr,1);
noStations2 = numel(stationNoSurr);

figure(1)
ax = get(gcf, 'position');
ax(4) = 1300;
ax(3) = 1300;
set(gcf, 'position', ax);
mplot(dateSurr.decYear, surr)

noValuesData = 365;
surrPart   = surr(1:noValuesData,:);
dateSurrPart.decYear   = dateSurr.decYear(1:noValuesData,:);
dateSurrPart.julianDay   = dateSurr.julianDay(1:noValuesData,:);
dateSurrPart.month   = dateSurr.month(1:noValuesData,:);

figure(2)
ax = get(gcf, 'position');
ax(4) = 1300;
ax(3) = 1300;
set(gcf, 'position', ax);
mplot(dateSurrPart.julianDay, surrPart)

noValuesData = 365*10;
surrPart   = surr(1:noValuesData,:);
dateSurrPart.decYear   = dateSurr.decYear(1:noValuesData,:);
dateSurrPart.year   = dateSurr.year(1:noValuesData,:);
dateSurrPart.julianDay   = dateSurr.julianDay(1:noValuesData,:);
dateSurrPart.month   = dateSurr.month(1:noValuesData,:);

figure(3)
ax = get(gcf, 'position');
ax(4) = 500;
ax(3) = 1300;
set(gcf, 'position', ax);
for iYear = 1901:1905
    for iMonth=1:12
        index = find(dateSurrPart.month == iMonth & dateSurrPart.year==iYear);
        color = rand(1,3);
        plot(dateSurrPart.decYear(index), surrPart(index,2), 'color', color)
        hold on
    end
end
hold off

a=0;