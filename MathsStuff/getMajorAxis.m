function majorAxis = getMajorAxis(u,v)
% Calculate major axis of ellipse based on u,v velocities
% 
% INPUTS:
% u - x component of velocity
% v - y compoent of velocity
%
% OUTPUT:
% majorAxis (in degrees)

% Need covariance for major axis:
PCAParameters = RCM.Utils.PCA(u,v);
f = PCAParameters.eigenVector(1,PCAParameters.cols(1));
g = PCAParameters.eigenVector(2,PCAParameters.cols(1));
majorAxis=mod(atan2d(f,g),360);
return

end
