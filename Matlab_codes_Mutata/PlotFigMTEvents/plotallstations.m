function plotallstations(nostations,staname,normalized,ftime,...
    totime,uselimits,dtime,addvarred,normsynth,npts,path)
% Need 
%   *fil.dat *syn.dat files
%   allsta.dat

% we keep fixed that data will be e.g. evrfil.dat
% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

realdatafilename=realdatafilename';
syntdatafilename=syntdatafilename';
 
% cd invert

%%%%%%%%%%%initialize data matrices
realdataall=zeros(npts,4,nostations);    %%%% npts according to isolacfg.isl
syntdataall=zeros(npts,4,nostations); 
maxmindataindex=zeros(1,2,nostations);
maxreal4sta=zeros(nostations);
maxsynt4sta=zeros(nostations);

%%%%open data files and read data
for i=1:nostations
    fid1  = fopen([path 'invert/' realdatafilename{i}],'r');
    fid2  = fopen([path 'invert/' syntdatafilename{i}],'r');
    
    a=fscanf(fid1,'%f %f %f %f',[4 inf]);
    realdata=a';
    b=fscanf(fid2,'%f %f %f %f',[4 inf]);
    syntdata=b';
    
    fclose(fid1);
    fclose(fid2);
    
    
    realdataall(:,:,i)=realdata;
    maxmindataindex(:,:,i)=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010
    syntdataall(:,:,i)=syntdata;
end

[station,useornot,nsw,eww,vew,f1,f2,f3,f4] = textread([path 'invert/allstat.dat'],'%s %u %f %f %f %f %f %f %f',-1);

for i=1:nostations    %%%%%%loop over stations
    if useornot(i) == 0
        compuse(1,i) = 0; compuse(2,i) = 0; compuse(3,i) = 0;
    elseif useornot(i) == 1
        %   if weight == 0 component is not used..
        if nsw(i) == 0; compuse(1,i) = 0; else compuse(1,i) = 1; end
        if eww(i) == 0; compuse(2,i) = 0; else compuse(2,i) = 1; end
        if vew(i) == 0; compuse(3,i) = 0; else compuse(3,i) = 1; end
    end
end

% cd ..

for i = 1:nostations    %%%%%%loop over stations
    for j = 1:3                %%%%%%%%loop over components
        variance_reduction(i,j)= vared(realdataall(:,j+1,i),syntdataall(:,j+1,i),dtime);
    end
end

% New type of normalization, based on maximum amplitude of component per station NOT TOTAL maximum

if normalized == 1
    disp('Normalized plot. Using normalization per component ')

    for i=1:nostations
        for j=2:4
            maxreal(i,j)=max(abs(realdataall(:,j,i)));
            maxsynt(i,j)=max(abs(syntdataall(:,j,i)));
        end
        
        maxreal4sta(i)=max(maxreal(i,:)); % maximum per station per component
        maxsynt4sta(i)=max(maxsynt(i,:)); % maximum per station per component for synthetic data
        
        for j=2:4
            realdataall(:,j,i) = realdataall(:,j,i)/maxreal4sta(i);
            
            if normsynth==1
                syntdataall(:,j,i) = syntdataall(:,j,i)/maxsynt4sta(i);  % normalize synthetic
            else
                syntdataall(:,j,i) = syntdataall(:,j,i)/maxreal4sta(i);
            end
        end
    end
end

%%%%%%%%% PLOTTING   
componentname = cellstr(['NS';'EW';'Z ']);

%  Start by making legend  (top row of plots)
subplot1(nostations+1,3)  % initialize all plots

subplot1(1)    % selecte top left plot
axis off
subplot1(2) % top mid plot
axis off
subplot1(3) % top right plot

p1=plot(realdataall(:,1,1),realdataall(:,1+1,1),'k', 'LineWidth',1.5);
hold on
p2=plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r', 'LineWidth',1.);
hold off
leg=legend('Observed','Synthetic','HandleVisibility','on');

set(p1, 'visible', 'off');
set(p2, 'visible', 'off');
set(leg, 'visible', 'on');
axis off


k = 0;
for i=1:nostations    %%%%%%loop over stations
    for j=1:3                %%%%%%%%loop over components
        subplot1(j+k+3); axis off
        
        if  compuse(j,i) == 1
            plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                'LineWidth',1.5);
        elseif compuse(j,i) == 0     %%% not used in inversion
            plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                'LineWidth',1.5,'Color',[.5,0.5,.5]);
        end
        
        hold on
        if  compuse(j,i) == 1
            plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'r',...
                'LineWidth',1. );
        elseif compuse(j,i) == 0     %%% not used in inversion
            plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                'LineWidth',1.,'Color',[.5,0,0]);
        end
        hold off
          
        if uselimits == 1
            if normalized == 1
                axis ([ftime totime -1.0 1.0 ]) ;
            else
                axis([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
            end
        else   %%% not use time limits
            if normalized == 1
                v=axis;
                axis([v(1) v(2) -1.0 1.0 ]) ;
            else
                v=axis;
                axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%% Add text in graph
        %%%% AXIS SCALE.....
        
        if i==1
            title(componentname{j},...
                'FontSize',9,...
                'FontWeight','bold');
        end
        
        if i==nostations
            xlabel('Time (s)')
            
        elseif i~=nostations
            set(gca,'Xtick',[-10 1000])            
        end
          
        if  j==1
            y=ylabel(staname{i},'FontSize',12,'FontWeight','bold');
            set(get(gca,'YLabel'),'Rotation',0)
            set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);
        end
        
        if normalized == 1
            if uselimits == 1
                % if j==3
                %     text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                %     if normsynth==1
                %         text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                %     else
                %     end
                % end
                
                if addvarred == 1   %%%%%%%%%%  print variance
                    text((totime-ftime)*0.05, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','k','HorizontalAlignment','left','FontSize',10,...
                        'FontWeight','bold','FontName','FixedWidth');
                else
                end
                %%%%%%%%%%%%%%%%
            else  % not use limits
                if j==3
                    text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                    if normsynth==1
                        text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                    else
                    end
                end
                
                if addvarred == 1   %%%%%%%%%%print variance
                    v=axis;
                    text((v(2)-v(1))*0.95, -0.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                        'FontWeight','bold','FontName','FixedWidth');
                else
                end
                
            end
            %%%%%%%%%%%%%%%%%%%%
        else    %%% not normalized
            if addvarred == 1
                if uselimits == 0
                    v=axis;
                    ((v(2)-v(1))*0.02)+v(1);
                    text((v(2)-v(1))*0.95, v(4)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                        'FontWeight','bold','FontName','FixedWidth');
                else
                    v=axis;
                    text(((totime-ftime)*0.03)+ftime , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                        'FontWeight','bold','FontName','FixedWidth');
                    
                end
            else
            end
        end    %%%end of Normalized  if
        
    end       %%%%%%%loop over components
    
    k=k+3;
    
end   %%%%%%%loop over stations
   
set(get(gca,'YLabel'),'Rotation',0)
 