function faulttorupt(filefault,filemod,filename,vr,rake)
% Build .rupt file for MudPy forward modeling
% 
% In:
%   filefault: path to fault file contining subfault positions and numbers
%   (path/to/file.fault)
%   filemod: path to velocity model (path/to/file.mod)
%   vr: rupture velocity in km/s
%   rake: rake to calculate slip along strike and dip
% 
% Out:
%   rupt file with filename filename
%   No,lon,lat,z(km),str,dip,type,rise(s),ss(m),ds(m),L(m),W(m),onset(s),mu(Pa)

% Load the files
fault = dlmread(filefault,'',1,0); % subfault info: No,Lon,Lat,z(km),strike,dip,rise_type,rise_time(s),length(m),width(m)
vmod = load(filemod); % velocity model: depth/thickness Vs Vp density(g/cm3) Qs Qp
for ii = 2:size(vmod,1); vmod(ii,1) = vmod(ii-1,1)+vmod(ii,1); end

rupt = zeros(size(fault,1),14);
rupt(:,1) = fault(:,1); % No
rupt(:,2) = fault(:,2); % Lon
rupt(:,3) = fault(:,3); % Lat
rupt(:,4) = fault(:,4); % z (km)
rupt(:,5) = fault(:,5); % str
rupt(:,6) = fault(:,6); % dip
rupt(:,7) = fault(:,7); % rise type
rupt(:,8) = fault(:,8); % rise time (s)
rupt(:,11) = fault(:,9); % L(m)
rupt(:,12) = fault(:,10); % W(m)

% Calculate mu in Pa
for ii = 1:size(fault,1)
    iv = find(fault(ii,4) < vmod(:,1),1);
    rupt(ii,14) = (vmod(iv(end),4)*1000)*(vmod(iv(end),2)*1000)^2;
    clear iv
end

% Selection of subfault with hypocenter/centroid
figure; plot(fault(:,2),fault(:,3),'*')
for ii = 1:size(fault,1); text(fault(ii,2),fault(ii,3),num2str(fault(ii,1))); end
subf = input('Choose the subfault number corresponding to the hypocenter (ex: 40): ');

iv = find(fault(:,1) == subf);
[utmx,utmy] = deg2utm(fault(:,3),fault(:,2));
hypx = utmx(iv); hypy = utmy(iv);
utmx = utmx - hypx; utmy = utmy - hypy; utmz = fault(:,4) - fault(iv,4);

rupt(:,13) = (sqrt(utmx.^2 + utmy.^2 + utmz.^2)/(vr*1000)); 

subf = input('Choose the subfault(s) with some slip (ex: [45 46]): ');
slip = input('Now give the slip amounts (ex: [0.1 0.1]): ');

ss = cosd(rake)*slip;
ds = sind(rake)*slip;

for ii = 1:length(subf)
    iv = find(fault(:,1) == subf(ii));
    rupt(iv,9) = ss(ii);
    rupt(iv,10) = ds(ii);
    clear iv
end

% Output file
fid = fopen(filename,'w');
% No,lon,lat,z(km),str,dip,type,rise(s),ss(m),ds(m),L(m),W(m),onset(s),mu(Pa)
fprintf(fid,'%s\n','#No.  lon     lat   z(km)   str dip type rise(s) ss(m) ds(m) L(m)    W(m) onset(s)    mu(Pa) ');
fprintf(fid,'%d\t%2.4f\t%2.4f\t%2.3f\t%d\t%d\t%1.1f\t%1.1f\t%2.4f\t%2.4f\t%d\t%d\t%3.3f\t%2.2E\n',rupt');
fclose(fid);

disp('Job done!')
