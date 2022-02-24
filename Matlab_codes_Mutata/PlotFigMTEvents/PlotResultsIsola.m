% Plot the results of Isola:
%   - Small map with m_map
%   - Plot correlation with depth with MTs
%   - Fit of waveforms with synth and obs
%
% Built from Isola routine plotres.m and some others
clear
% Path to folders of Isola (invert, gmtfiles etc.)
path = '/Users/karl/Dropbox (Uniandes)/jb/Articles/Cauca/Isola/20180401151702/';
%% Simple map of stations used in the inversion 
% Still no distinction between stations selected or not
clearvars -except path
addpath(genpath('/Users/karl/Documents/MATLAB/m_map'))
[map.station_name,map.lat,map.lon] = textread([path '/gmtfiles/selstat.gmt'],'%s %f %f',-1); 

figure;
lats = [min(map.lat)-1 max(map.lat)+1]; 
longs = [min(map.lon)-1 max(map.lon)+1];
axes('position',[.1 .5 .4 .4]); % Pos minx miny sizex sizey, main map
hold on; 
m_proj('lambert','long',longs,'lat',lats);
m_gshhs_h('patch',[.8 .8 .8]);
h1=m_line(map.lon,map.lat,'marker','^','color','k',...
          'linest','none','markerfacecolor','k','clip','point');
m_text(map.lon,map.lat,map.station_name,'vertical','top');
m_grid('linest','none','tickdir','out'); colormap(m_colmap('land'));  
ylabel('Latitude'); xlabel('Longitude'); 
clear h1 map lats longs

[inv3.srcpos,inv3.srctime,inv3.mrr,inv3.mtt,inv3.mff,inv3.mrt,...
    inv3.mrf,inv3.mtf] = textread([path 'invert/inv3.dat'],'%f %f %q %q %q %q %q %q');

fid = fopen([path 'event.isl'],'r');
eventcor=fscanf(fid,'%g',2);
epidepth=fscanf(fid,'%g',1);
fclose(fid);

fm = str2double([inv3.mrr inv3.mtt inv3.mff inv3.mrt inv3.mrf inv3.mtf]);
[X,Y]=m_ll2xy(eventcor(1),eventcor(2));
focalmech(fm, X, Y, 0.01,'b',0.75) % Last value is stretch in E-W
clear inv3 fid eventcor epidepth fm X Y

%% Plot the correlation vs depth with moment tensors
clearvars -except path

fid = fopen([path 'tsources.isl'],'r'); tsource = fscanf(fid,'%s',1);
disp('Inversion was done for a line of sources under epicenter.')
nsources=fscanf(fid,'%i',1); distep=fscanf(fid,'%f',1);
sdepth=fscanf(fid,'%f',1); invtype=fscanf(fid,'%c');
fclose(fid); clear invtype 

[inv1_isour_shift,inv1_eigen,alphas,sigma_alphas,inv1_mom,inv1_mag,...
    inv1_vol,inv1_dc,inv1_clvd,inv1_sdr1,inv1_sdr2,inv1_varred,all]=readinv1new(...
    [path 'invert/inv1.dat'],nsources,1);
clear inv1* sigma* fid alphas 

zs = sdepth:distep:sdepth+((nsources-1)*distep);

axes('position',[.6 .5 .3 .4]); % Pos minx miny sizex sizey
hold on; box on; grid on;

for ii = 1:size(all,1)
    momten = an2mom([all(ii,7) all(ii,6) all(ii,8)]); % Dip Strike Rake
    % 20% DC in white to 120% in black
    focalmech(momten,all(ii,3),-zs(ii),9,[1.2 1.2 1.2]-(all(ii,5)/100),0.002)
    clear momten
end
xlabel('Variance red. %'); ylabel('Depth (km)')

% [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,moment] = textread([path '/invert/corr01.dat'],'%f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
% 
% [a1,a2,a3,a4,a5,a6]=sdr2as(265,63,11,1); % .1877E+16
% momten = an2mom([63 265 11]);
% figure; focalmech(momten,...
%     5, 5, 6,'b',1) % Last value is stretch in E-W, use spherical coordinates
% 
% MT=[-a4+a6 a1 a2;...
%     a1 -a5+a6 -a3;...
%     a2 -a3 a4+a5+a6];
% MT = (0.916)*MT + (1-0.916)*eye(3,3);
% 
% figure; focalmech([MT(1,1) MT(2,2) MT(3,3) MT(1,2) MT(1,3) MT(2,3)],...
%     5, 5, 6,'b',1) % Last value is stretch in E-W, use spherical coordinates

%% Figure of fit obs and synth data for selected stations
clearvars -except path
[staname,~,~,~,~,~,~,~,~] = textread([path '/invert/allstat.dat'],'%s %f %f %f %f %f %f %f %f',-1);
nostations = length(staname);
% for i=1:nostations
%     realfilfilename{i}=[char(staname{i}) 'fil.dat'];
%     realsynfilename{i}=[char(staname{i}) 'syn.dat'];
% end

fid = fopen([path 'waveplotoptions.isl'],'r');
wave.nor=fscanf(fid,'%f',1);
wave.usel=fscanf(fid,'%f',1);
wave.ftime=fscanf(fid,'%f',1);
wave.totime=fscanf(fid,'%f',1);
wave.pvar=fscanf(fid,'%f',1);
wave.pbw=fscanf(fid,'%f',1);
fclose(fid);

wave.npts = 8192;

[id,dtime,nsubevents,~,~,invband,~] = readinpinv([path 'invert/inpinv.dat']);

dtime=num2str(dtime);
% nsubevents=num2str(nsubevents);
% invband=[num2str(invband(1)) ' - ' num2str(invband(4))];

% Numbers in black are the variance reduction per component
figure;
plotallstations(nostations,staname,1,wave.ftime,wave.totime,1,dtime,1,1,wave.npts,path)

%% TRASH

[~,~,variance,~,~,~,~,~,~,~,~,~,~] = textread([path 'invert/corr01.dat'],'%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);

fid = fopen([path 'stations.isl'],'r');
nstations=fscanf(fid,'%i',1);
fclose(fid);

fid = fopen([path 'event.isl'],'r');
eventcor=fscanf(fid,'%g',2);
epidepth=fscanf(fid,'%g',1);
fclose(fid);

[inv2.srcpos2,inv2.srctime2,inv2.mo,inv2.str1,inv2.dip1,inv2.rake1,...
    inv2.str2,inv2.dip2,inv2.rake2,inv2.aziP,inv2.plungeP,inv2.aziT,...
    inv2.plungeT,inv2.aziB,inv2.plungeB,inv2.dc,inv2.varred] = textread([path 'invert/inv2.dat'],'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');

fid = fopen([path 'invert/inv4.dat'],'r');
line=fgets(fid);        %01 line
line=fgets(fid);        %02 line
line=fgets(fid);        %03 line
line=fgets(fid);        %04 line
line=fgets(fid);        %05 line
line=fgets(fid);        %06 line
line=fgets(fid);        %07 line
line=fgets(fid);        %08 line
line=fgets(fid);        %09 line
line=fgets(fid);        %10 line
line=fgets(fid);        %11 line
line=fgets(fid);        %12 line
overallvarredvalue = sscanf(line,'%e');
fclose(fid);

[inv1.isour_shift,inv1.eigen,inv1.mom,inv1.mag,inv1.vol,inv1.dc,inv1.clvd,...
    inv1.sdr1,inv1.sdr2,inv1.varred]=readinv1(nsources,1,path); % psrcpos = 1

