% Plot the slip files

clear
path = '/SSI_Results/';
file = '2.5_1.1_mutata.0111.inv';
M = dlmread([path file],'', 1, 0);
nx = 17; nz = 17; nsf = nx*nz;

% Slip on subfaults
slip = zeros(length(nsf),1);
for ii = 1:nsf:length(M)
    slip = slip + sqrt(M(ii:ii+nsf-1,9).^2 + M(ii:ii+nsf-1,10).^2);
end

% Order of points from bottom line to shallowest line, from lower-left
% corner to upper right corner
% Then num_windows * number of subfaults in total
% Coordinates
x = 0+(M(1,11)/2):M(1,11):nx*M(1,11); x = x/1000;
z = 0+(M(1,12)/2):M(1,12):nz*M(1,12); z = z/1000;

[X,Z] = meshgrid(x,z);
slipgrd = reshape(slip,[nx,nz])'; slipgrd = flipud(slipgrd);

%% Writting file
arr = [X(:) Z(:) slipgrd(:)];
fileID = fopen([file(1:end-4) '.xyz'],'w');
fprintf(fileID,'%.4f %.4f %.4f\n',arr');
fclose(fileID);

%% Plotting
ni = 20; % Interp factor
x2 = 0:M(1,11)/ni:nx*M(1,11); x2 = x2/1000;
z2 = 0:M(1,12)/ni:nz*M(1,12); z2 = z2/1000;
[X2,Z2] = meshgrid(x2,z2);
slipgrd2 = interp2(X,Z,slipgrd,X2,Z2,'cubic');

figure; imagesc(x2,z2,slipgrd2)
xlabel('Distance along strike (km)'); ylabel('Depth along dip (km)')
axis([min(x2) max(x2) min(z2) max(z2)])
set(gca,'FontSize',12);

%% Plot wave fit
clear
addpath(genpath('/PlotFigMTEvents/'))
addpath('/MatSAC') % For the rdSac.m function
% Station list
sta_list = {'HEL','CBOC','ZAR','PTB','NOR','UPD2','PAL','BRR'};
comps = ['n','e','u']; % Component extensions
run_name = 'mutata'; run_num = '0111';

% Path to observed data (ex: ANWB.disp.e)
path_o = '/Results/waveforms/';
% Path to synthetics (ex: mutata.0000.ANWB.disp.e.sac)
path_s = '/Results/wavefroms2.5_1.1/';
wei = [1 1 1;1 0 1;1 1 1;1 1 1;1 1 1;0 1 1;1 1 1;1 1 1];

figure
subplot1(8,3);
kk = 1;
for ii = 1:length(sta_list)
    
    for nn = 1:3
        [data_o,hd_o] = rdSac([path_o sta_list{ii} '.disp.' comps(nn)]);
        [data_s,hd_s] = rdSac([path_s run_name '.' run_num '.' sta_list{ii} '.disp.' comps(nn) '.sac']);
        % Potential time difference between data and synth in sec.
        dif_time = ((hd_o(72)*86400) + (hd_o(73)*3600) + (hd_o(74)*60) + hd_o(75) + (hd_o(76)/1e3)) - ...
            ((hd_s(72)*86400) + (hd_s(73)*3600) + (hd_s(74)*60) + hd_s(75) + (hd_s(76)/1e3));
        
        % Waveforms should start at the same time
        if dif_time ~= 0; disp(['Warning, data alignment of ' sta_list{ii}]); end
        time = (0:length(data_o)-1)*hd_o(1);
        
        % Plot
        subplot1(kk); axis off
        
        if wei(ii,nn) > 0
            plot(time,data_o/max(abs(data_o)),'k','LineWidth',1.5);
        else
            plot(time,data_o/max(abs(data_o)),'LineWidth',1.5,'Color',[0.5,0.5,0.5]);
        end
        hold on
        if wei(ii,nn) > 0
            plot(time,data_s/max(abs(data_s)),'r','LineWidth',1);
        else
            plot(time,data_s/max(abs(data_s)),'LineWidth',1,'Color',[.5,0,0]);
        end
        hold off
        axis ([0 max(time) -1 1]) ;
        
        % plot(time,data_o,'k'); hold on; plot(time,data_s,'r')
        % xlabel('Time (s)'); ylabel('Amp.'); title([sta_list{ii} ', ' comps(nn)])
        % xlim([0 max(time)])
        
        kk = kk + 1;
        clear data_o hd_o data_s hd_s dif_time time
    end
end

%% Plot the STF (from view.source_time_function of MudPy)
clear
path = '/SSI_Results/';
file = '2.5_1.1_mutata.0111.inv';
f = dlmread([path file],'', 1, 0);

num = f(:,1);
% Get slips
all_ss = f(:,9); all_ds = f(:,10);
unum = unique(num); nfault = length(unum);

% Count number of windows
nwin = length(find(num == unum(1)));
% Get rigidities
mu = f(1:length(unum),14);
% Get rise times
rise_time = f(1:length(unum),8);
% Get areas
area = f(1:length(unum),11).*f(1:length(unum),12);
% Loop over subfaults
for kfault = 1:nfault
    % Get rupture times for subfault windows
    ii = find(num == unum(kfault));
    trup = f(ii,13);
    % Get slips on windows
    ss = all_ss(ii);
    ds = all_ds(ii);
    % Add it up
    slip=sqrt(ss.^2+ds.^2);
    if kfault == 1
        % Get first source time function
        [t1,M1] = get_source_time_function(mu(kfault),area(kfault),...
            rise_time(kfault),trup(1),slip(1));
        for kwin = 2:nwin
            % Get next source time function
            [t2,M2] = get_source_time_function(mu(kfault),area(kfault),...
                rise_time(kfault),trup(kwin),slip(kwin));
            
            [t1,M1] = add2stf(t1,M1,t2,M2);
            clear t2 M2
        end
    else
        % Loop over windows
        for kwin = 1:nwin
            % Get next source time function
            [t2,M2] = get_source_time_function(mu(kfault),area(kfault),...
                rise_time(kfault),trup(kwin),slip(kwin));
            
            [t1,M1] = add2stf(t1,M1,t2,M2);
            clear t2 M2
        end
    end
    
end

% Get power
% ex = floor(log10(max(M1)));
% M1 = M1/(10^ex);

figure; plot(t1,M1,'k','LineWidth',1)
xlabel('Time (s)'); ylabel('Moment rate (Nm/s)')
set(gca,'FontSize',12);

%% To check/plot STF of each subfault
clear
path = '/SSI_Results/';
file = '2.5_1.1_mutata.0111.inv';
f = dlmread([path file],'', 1, 0);

num = f(:,1);
% Get slips
all_ss = f(:,9); all_ds = f(:,10);
unum = unique(num); nfault = length(unum);

% Count number of windows
nwin = length(find(num == unum(1)));
% Get rigidities
mu = f(1:length(unum),14);
% Get rise times
rise_time = f(1:length(unum),8);
% Get areas
area = f(1:length(unum),11).*f(1:length(unum),12);
% Loop over subfaults
for kfault = 1:nfault
    % Get rupture times for subfault windows
    ii = find(num == unum(kfault));
    trup = f(ii,13);
    % Get slips on windows
    ss = all_ss(ii);
    ds = all_ds(ii);
    % Add it up
    slip=sqrt(ss.^2+ds.^2);
    % Get first source time function
    [t1,M1] = get_source_time_function(mu(kfault),area(kfault),...
        rise_time(kfault),trup(1),slip(1));
    
    % Loop over windows
    for kwin = 2:nwin
        % Get next source time function
        [t2,M2] = get_source_time_function(mu(kfault),area(kfault),...
            rise_time(kfault),trup(kwin),slip(kwin));
        
        [t1,M1] = add2stf(t1,M1,t2,M2);
        clear t2 M2
    end
    t1_stf(kfault,:) = t1; M1_stf(kfault,:) = M1;
    clear t1 M1
    
%     figure(5); plot(t1,M1,'k','LineWidth',1)
%     title(['Subfault #' num2str(kfault)])
%     xlabel('Time (s)'); ylabel('Moment rate (Nm/s)')
%     set(gca,'FontSize',12);
%     pause;
%     close figure 5
end

%% Calculation of magnitudes

% First way: integral of STF
Mo1 = trapz(t1,M1);
Mw1 = (log10(Mo1) - 9.1)/1.5;

% Second way: from average slip and area
Mo2 = mean(mu)*(50000^2)*0.03;
Mw2 = (log10(Mo2) - 9.1)/1.5;
