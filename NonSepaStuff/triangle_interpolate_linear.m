function v = triangle_interpolate_linear ( m, n, p1, p2, p3, p, v1, v2, v3 )

%*****************************************************************************80
%
%% triangle_interpolate_linear() interpolates data given on a triangle's vertices.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2015
%
%  Author:
%
%    John Burkardt
%
%  Input:
%
%    integer M, the dimension of the quantity.
%
%    integer N, the number of points.
%
%    real P1(2), P2(2), P3(2), the vertices of the triangle,
%    in counterclockwise order.
%
%    real P(2,N), the point at which the interpolant is desired.
%
%    real V1(M), V2(M), V3(M), the value of some quantity at the vertices.
%
%  Output:
%
%    real V(M,N), the interpolated value of the quantity at P.
%
  v = zeros ( m, n );

  for j = 1 : n
    v(1:m,j) = ...
      ( triangle_area ( [ p(1:2,j),  p2,        p3        ] ) * v1(1:m)   ...
      + triangle_area ( [ p1,        p(1:2,j),  p3        ] ) * v2(1:m)   ...
      + triangle_area ( [ p1,        p2,        p(1:2,j)  ] ) * v3(1:m) ) ...
      / triangle_area ( [ p1,        p2,        p3        ]  );
  end

  return
end
     
