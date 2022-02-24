function [M,Merror]=harvard2xyz(harvard);
%   harvard2xyz   convert moment tensor from Spherical to Cartesian coordinates
% usage: [M,Merror]=harvard2xyz(harvard);

% Convert Harvard convention of spherical coord, to local Cartesian.
% input is a row vector with 12 elements containing 6 pairs of
% moment tensor elements and their formal uncertainties.
% First convert 
% Mrr  Mss  Mee  Mrs  Mre  Mse  (r=up,s=south,e=east)  [Harvard convention]
% to 
% Mzz  Mxx  Myy  Mxz -Myz -Mxy  (x=north,y=east,z=down) [output convention]
% then reshape components, which are ordered as above to a 3x3 matrix M.
% Mxx Mxy Mxz Myx Myy Myz Mzx Mzy Mzz
%  2   6   4   6   3   5   4   5   1
%
% output is:
% M=[Mxx Mxy Mxz         Merror=[Mxx Mxy Mxz
%    Mxy Myy Myz                 Mxy Myy Myz
%    Mxz Myz Mzz];               Mxz Myz Mzz];
 
temp  =harvard([1:2:12]).*[1 1 1 1 -1 -1];
M     =reshape(temp([2 6 4 6 3 5 4 5 1]),3,3);
temp  =harvard([2:2:12]);
Merror=reshape(temp([2 6 4 6 3 5 4 5 1]),3,3);

