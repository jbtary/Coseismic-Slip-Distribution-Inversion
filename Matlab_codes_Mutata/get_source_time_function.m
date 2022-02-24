function [t,Mdot] = get_source_time_function(mu,area,rise_time,t0,slip)

% Compute source time function for a given rise time, right now it assumes
% 1m of slip and a triangle STF

t = linspace(t0,t0+rise_time,1000);
Mdot = zeros(size(t));
m = 4*mu*area/(rise_time^2);
% Upwards intercept
b1 = -m*t0;
% Downwards intercept
b2 = m*(t0+rise_time);
% Assign moment rate
% i = where(t<=t0+rise_time/2)[0]
ii = find(t <= t0+rise_time/2);
Mdot(ii)=m*t(ii)+b1;
% i = where(t>t0+rise_time/2)[0]
ii = find(t > t0+rise_time/2);
Mdot(ii)=-m*t(ii)+b2;
Mdot = Mdot*slip;
    

