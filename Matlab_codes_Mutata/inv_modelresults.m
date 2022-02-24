% Read all model results for the slip inversion and give the VR, ABIC, M,
% ls and lt for all iterations
clear
path = 'NearField/Saved_Inversions/2.5_1.1_10_50km/models/';
files = dir([path '*.log']);

for ii = 1:length(files)
    fid = fopen([path files(ii).name],'r');
    
    for jj = 1:23 % Files have 23 lines
        tline = fgetl(fid);
        
        if jj == 3 % Iteration number
            it(ii) = str2double(tline(end-4:end));
        end
        if jj == 9 % Spatial reg. param.
            ls(ii) = str2double(tline(18:end));
        end
        if jj == 10 % Temporal reg. param.
            lt(ii) = str2double(tline(19:end));
        end
        if jj == 12 % Rupture velocity km/s
            vr(ii) = str2double(tline(32:end));
        end
        if jj == 16 % Variance red. %
            VR(ii) = str2double(tline(22:end));
        end
        if jj == 21 % ABIC number
            abic(ii) = str2double(tline(8:end));
        end
        if jj == 22 % Seismic moment N.m
            M0(ii) = str2double(tline(11:end));
        end
        if jj == 23 % Moment magnitude
            Mw(ii) = str2double(tline(6:end));
        end
        clear tline
    end
    
    fclose(fid);
    clear fid
end

% Plot abic, M0, Mw, VR
figure; 
subplot(2,2,1)
plot(it,VR,'k'); xlabel('It. #'); ylabel('Variance reduction /%')
subplot(2,2,2)
plot(it,abic,'k'); xlabel('It. #'); ylabel('ABIC value')
subplot(2,2,3)
plot(it,M0,'k'); xlabel('It. #'); ylabel('Seismic moment M_0 (N.m)')
subplot(2,2,4)
plot(it,Mw,'k'); xlabel('It. #'); ylabel('Moment magnitude')
