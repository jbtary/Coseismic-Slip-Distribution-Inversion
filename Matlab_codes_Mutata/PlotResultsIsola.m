% Plot the results of Isola:
%   - Small map with m_map
%   - Plot correlation with depth with MTs
%   - Fit of waveforms with synth and obs
%
% Built from Isola routine plotres.m and some others
clear
% Path to some functions
addpath(genpath('/PlotFigMTEvents/'))
% Path to folders of Isola (invert, gmtfiles etc.), Full / DC_constrained
path = '/DC_constrained/';
%% Simple map of stations used in the inversion 
% Still no distinction between stations selected or not
clearvars -except path
addpath(genpath('/m_map'))
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
clear sigma* fid alphas 

zs = sdepth:distep:sdepth+((nsources-1)*distep);

axes('position',[.6 .5 .3 .4]); % Pos minx miny sizex sizey
% axes('position',[.2 .5 .3 .4]);
hold on; box on; grid on;

for ii = 1:2:size(all,1)
    momten = an2mom([all(ii,7) all(ii,6) all(ii,8)]); % Dip Strike Rake
    % 20% DC in white to 120% in black
    focalmech(momten,all(ii,3)^2,-zs(ii),7,[1 1 1]-(all(ii,5)/100),0.005)
    clear momten
end
xlabel('Variance red. %'); ylabel('Depth (km)')
set(gca,'FontSize',12);

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
plotallstations(nostations,staname,1,wave.ftime,150,1,dtime,0,1,wave.npts,path)

%% Plot of moment tensors using V. Vavrycuk routines (from plot_mechanisms.m)
clear

% Mrr Mtt Mpp Mrt Mrp Mtp
% m0 = [3.06e17 -8.16e17 5.10e17 -6.81e17 -5.37e17 -2.90e17]; % USGS
% m0 = [-1.133 -4.889 5.065 -4.697 -3.515 -1.627]*1e17; % Isola Full
% m0 = [-0.967 -4.654 5.621 -3.747 -4.189 -1.124]*1e17; % Isola DC
strike = 37; dip = 86; rake = -59; m0 = sdr2mt(strike,dip,rake); % Foc Mech
% Convert to xyz moment tensor with Coral routine (K. Creager)
[m,~]=harvard2xyz([m0(1) 0 m0(2) 0 m0(3) 0 m0(4) 0 m0(5) 0 m0(6) 0]);

angles_all = angles(m);
strike_1 = angles_all(1); dip_1 = angles_all(2); rake_1 = angles_all(3);
figure; hold on; axis equal; axis off; 
shadowing(m);
Fi=0:0.1:361; plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
nodal_lines_(strike_1, dip_1, rake_1); % P_T_axes_(strike_1, dip_1, rake_1);

%% Plot of foc mec with all possible solutions
clear

% Foc mec chosen
strike = 37; dip = 86; rake = -59; m0 = sdr2mt(strike,dip,rake); % Foc Mech
[m,~]=harvard2xyz([m0(1) 0 m0(2) 0 m0(3) 0 m0(4) 0 m0(5) 0 m0(6) 0]);

figure; hold on; axis equal; axis off; 
Fi=0:0.1:361; plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
shadowing(m);

% Load the solutions from focmec.log
fid = fopen('/Users/karl/Documents/NLLOC/Mutatanlloc/FocMech/VelMod_Carlos/focmec.log','r');
for ii = 1:7; tline = fgetl(fid); clear tline; end % Getting rid of the header
for ii = 1:78 % Gather all solutions
    tline = fgetl(fid);
    tline = strsplit(tline);
    focmecs(ii,:) = [str2double(tline{1,3}) str2double(tline{1,2}) str2double(tline{1,4})];
    clear tline
end
fclose(fid);

% Plot all possible nodal lines
for ii = 1:size(focmecs,1)
    strike = focmecs(ii,1); dip = focmecs(ii,2); rake = focmecs(ii,3);
    m0 = sdr2mt(strike,dip,rake); % Foc Mech
    [m1,~]=harvard2xyz([m0(1) 0 m0(2) 0 m0(3) 0 m0(4) 0 m0(5) 0 m0(6) 0]);
    angles_all = angles(m1);
    strike_1 = angles_all(1); dip_1 = angles_all(2); rake_1 = angles_all(3);
    nodal_lines_(strike_1, dip_1, rake_1,'b',0.5);
    
    clear m0 m1 angles_all strike_1 dip_1 rake_1
end
angles_all = angles(m);
strike_1 = angles_all(1); dip_1 = angles_all(2); rake_1 = angles_all(3);
nodal_lines_(strike_1, dip_1, rake_1,'k',1.5);

%% Plot foc mechs of aftershocks
clear

% strike = 227; dip = 61; rake = 42; m0 = sdr2mt(strike,dip,rake); % Ev 10
% strike = 206; dip = 79; rake = 49; m0 = sdr2mt(strike,dip,rake); % Ev 12
strike = 228; dip = 59; rake = 30; m0 = sdr2mt(strike,dip,rake); % Ev 14
[m,~]=harvard2xyz([m0(1) 0 m0(2) 0 m0(3) 0 m0(4) 0 m0(5) 0 m0(6) 0]);

angles_all = angles(m);
strike_1 = angles_all(1); dip_1 = angles_all(2); rake_1 = angles_all(3);
figure; hold on; axis equal; axis off; 
shadowing(m);
Fi=0:0.1:361; plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
nodal_lines_(strike_1, dip_1, rake_1,'k',1.5);

