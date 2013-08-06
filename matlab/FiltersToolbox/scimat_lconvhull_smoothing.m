function scimat = scimat_lconvhull_smoothing(scimat, rad)
% SCIMAT_LCONVHULL_SMOOTHING  Smoothing of a binary image using a local
% convex hull
%
% SCIMAT2 = scimat_lconvhull_smoothing(SCIMAT, RAD)
%
%   SCIMAT is a SCI MAT volume with a binary image.
%
%   The perimeter voxels of the image are selected. The alpha-shape of
%   their coordinates produces a mesh triangulation with the local convex
%   hull.
%
%   RAD is a scalar with the radius of the alpha shape, i.e. the size of
%   the convex hull neighbourhood. When the convex hull is computed, only
%   voxels within RAD distance can be connected. When RAD=Inf, the
%   convex hull is obtained. Note that if you want to compare to other
%   alpha shape functions, e.g. cgal_alpha_shape3() or
%   cgal_fixed_alpha_shape3(), ALPHA=RAD^2.
%
%   The inside of the triangulation is converted to voxels using
%   cgal_insurftri().
%
%   SCIMAT2 is the local convex hull of SCIMAT.
%
% This function uses alphavol() by Jonas Lundgren.
%
% See also: cgal_insurftri, cgal_alpha_shape3, cgal_fixed_alpha_shape3,
% scimat_closed_surf_to_bw

% Author: Ramon Casero <rcasero@gmail.com>
% Copyright © 2012 University of Oxford
% Version: 0.3.6
% $Rev$
% $Date$
% 
% University of Oxford means the Chancellor, Masters and Scholars of
% the University of Oxford, having an administrative office at
% Wellington Square, Oxford OX1 2JD, UK. 
%
% This file is part of Gerardus.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. The offer of this
% program under the terms of the License is subject to the License
% being interpreted in accordance with English Law and subject to any
% action against the University of Oxford being under the jurisdiction
% of the English Courts.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% check arguments
narginchk(2, 2);
nargoutchk(0, 1);

% if the image has all voxels == 1, then the smoothed local convex hull is
% the image itself and we don't need to waste time doing other computations
%
% likewise, if the image has all voxels == 0, there's nothing to smooth
if ((nnz(scimat.data) == 0) || (numel(scimat.data) == nnz(scimat.data)))
    return
end

% if we don't have at least 4 unique points, the delaunay triangulation
% will give an error
if (nnz(scimat.data) < 4)
    return
end

% compute perimeter voxels
scimat.data = bwperim(scimat.data);

% coordinates of segmented voxels
[r, c, s] = ind2sub(size(scimat.data), find(scimat.data));
x = scinrrd_index2world([r c s], scimat.axis);
clear r c s

% compute alpha shape
try
    [~, s] = alphavol(x, rad);
catch err
    % "Error computing the Delaunay triangulation. The points may be
    % coplanar or collinear"
    %
    % Just exit the function leaving the input segmentation untouched
    if (strcmp(err.identifier,'MATLAB:delaunay:EmptyDelaunay3DErrId'))
        return
   else
       % display any other errors as usual
      rethrow(err);
    end
end

% keep only the mesh surface
tri = s.bnd;
clear s

% % compute alpha shape (alternative mode using CGAL functions): this method
% % is slower because of the CGAL Delaunay triangulation
% tic
% tri = cgal_fixed_alpha_shape3(x, rad.^2);
% tri = tri{1};
% toc

% very small segmentations can produce degenerated surfaces. In that case,
% there's nothing to smooth and we can just exit without modifying the
% input segmentation
if (size(tri, 1) < 4)
    return
end

% % DEBUG: plot alpha shape's surface
% close all
% figure
% trisurf(tri, x(:, 1)*1e3, x(:, 2)*1e3, x(:, 3)*1e3, 'EdgeColor', 'none')
% axis xy equal
% view(-22, -4)
% camlight('headlight')
% lighting gouraud
% set(gca, 'FontSize', 18)
% xlabel('x (mm)')
% ylabel('y (mm)')
% zlabel('z (mm)')

% convert mesh to segmentation
scimat.data(scimat.data~=0) = 0;
scimat = scimat_closed_surf_to_bw(tri, x, scimat);
