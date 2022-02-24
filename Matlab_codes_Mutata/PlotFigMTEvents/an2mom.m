% Function from dsrin and an2mom inside dsrect.for
function momten = an2mom(angs)

% angs: [dip strike rake]

RAKE= angs(3);
STR = angs(2);
DIP = angs(1);
A(1) = cosd(RAKE)*cosd(STR) + sind(RAKE)*cosd(DIP)*sind(STR);
A(2) = cosd(RAKE)*sind(STR) - sind(RAKE)*cosd(DIP)*cosd(STR);
A(3) = -sind(RAKE)*sind(DIP);
N(1) = -sind(STR)*sind(DIP);
N(2) = cosd(STR)*sind(DIP);
N(3) = -cosd(DIP);

% Moment tensor components:  M(I,j) = A(I)*N(J)+A(J)*N(I)
momten(1) = 2.0*A(3)*N(3);	%  MRR = M(3,3)
momten(2) = 2.0*A(1)*N(1);	%  MTT = M(1,1)
momten(3) = 2.0*A(2)*N(2);	%  MPP = M(2,2)
momten(4) = A(1)*N(3)+A(3)*N(1);  %  MRT = M(1,3)
momten(5) = -A(2)*N(3)-A(3)*N(2); %  MRP = -M(2,3)
momten(6) = -A(2)*N(1)-A(1)*N(2); %  MTP = -M(2,1)
momten(abs(momten)<0.000001) = 0;

