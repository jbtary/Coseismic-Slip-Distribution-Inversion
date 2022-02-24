% convert strike-dip-rake to HRV mt
% f = strike, d = dip, l = rake
%1 Mrr =  Mzz =  Mo sin2d sinl
%2 Mtt =  Mxx = -Mo(sind cosl sin2f +     sin2d sinl (sinf)^2 )
%3 Mpp =  Myy =  Mo(sind cosl sin2f -     sin2d sinl (cosf)^2 )
%4 Mrt =  Mxz = -Mo(cosd cosl cosf  +     cos2d sinl sinf )
%5 Mrp = -Myz =  Mo(cosd cosl sinf  -     cos2d sinl cosf )
%6 Mtp = -Mxy = -Mo(sind cosl cos2f + 0.5 sin2d sinl sin2f )
% From seizmo toolbox
function mt = sdr2mt(strike,dip,rake)

mt=nan(numel(strike),6);
mt(:,1)=sind(2*dip).*sind(rake);
mt(:,2)=sind(dip).*cosd(rake).*sind(2*strike) ...
    + sind(2*dip).*sind(rake).*sind(strike).^2;
mt(:,3)=sind(dip).*cosd(rake).*sind(2*strike) ...
    - sind(2*dip).*sind(rake).*cosd(strike).^2;
mt(:,4)=cosd(dip).*cosd(rake).*cosd(strike) ...
    + cosd(2*dip).*sind(rake).*sind(strike);
mt(:,5)=cosd(dip).*cosd(rake).*sind(strike) ...
    - cosd(2*dip).*sind(rake).*cosd(strike);
mt(:,6)=sind(dip).*cosd(rake).*cosd(2*strike) ...
    + 0.5.*sind(2*dip).*sind(rake).*sind(2*strike);
mt(:,2:2:6)=-mt(:,2:2:6);
