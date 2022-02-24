function [ti,Mdot_out] = add2stf(t1,Mdot1,t2,Mdot2)
% Add two overlapping source time functions

% Make interpolation vector
tstart = min(t1(1),t2(1));
tend = max(t1(end),t2(end));
ti = linspace(tstart,tend,10000);
% Interpolate
% Mdot1_interp = interp(ti,t1,Mdot1,left=0,right=0);
Mdot1_interp = interp1(t1,Mdot1,ti,'linear');
Mdot1_interp(isnan(Mdot1_interp)==1) = 0;
% Mdot2_interp = interp(ti,t2,Mdot2,left=0,right=0);
Mdot2_interp = interp1(t2,Mdot2,ti,'linear');
Mdot2_interp(isnan(Mdot2_interp)==1) = 0;
% Add them up
Mdot_out = Mdot1_interp+Mdot2_interp;

