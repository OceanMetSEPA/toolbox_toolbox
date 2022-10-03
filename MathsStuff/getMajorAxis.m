function majorAxis = getMajorAxis(u,v)
% Need covariance for major axis:
PCAParameters = RCM.Utils.PCA(u,v);
f = PCAParameters.eigenVector(1,PCAParameters.cols(1));
g = PCAParameters.eigenVector(2,PCAParameters.cols(1));
majorAxis=mod(atan2d(f,g),360);
return

end
