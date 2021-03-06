echo on
%------------------------------------------------------------
% InvProb
%   Example inverse geodetic problem. Computes azimuth,
%   vertical angle and mark-to-mark (chord) distance from
%   1st to 2nd point.
% 2014-07-07
%
% M-files:  dms2rad, rad2dms, inverse, direct, refell
%
% *** NOTE ***
% This function uses the straightline, mark-to-mark (chord)
% distance between the two points as measured by, e.g., GPS
% baselines. It does not use the geodesic distance on the
% reference ellipsoid that is used in the traditional inverse
% geodetic problem for horizontal control networks.
%------------------------------------------------------------
%clear

%---------- Define lat,lon,ht of 1st (from) point(s)

lat1=dms2rad([53 12 46.10520]);      % Enter latitude
lon1=dms2rad([-105 55 50.52000]);    % Enter longitude
h1=468.986;                          % Enter ell. height
n1=max(size(lat1));

%---------- Define lat,lon,ht of 2st (to) point(s)

lat2=dms2rad([53 13 14.69151]);      % Enter latitude
lon2=dms2rad([-105 55 45.44058]);    % Enter longitude
h2=450.0018;                         % Enter ell. height
n2=max(size(lat1));

%---------- Compute az,va,dist between points

[a,b,e2,finv]=refell('NAD83');
[az,va,d]=inverse(lat1,lon1,h1,lat2,lon2,h2,a,e2);
azdms=rad2dms(az);
vadms=rad2dms(va);

%---------- List results

for i=1:n1
  fprintf('\nLine      %3.0f\n',i);
  fprintf('Azimuth   %3.0f %2.0f %9.6f\n',azdms(i,1),azdms(i,2),azdms(i,3));
  fprintf('V.Angle   %3.0f %2.0f %9.6f\n',vadms(i,1),vadms(i,2),vadms(i,3));
  fprintf('Distance  %15.4f\n',d(i));
end
