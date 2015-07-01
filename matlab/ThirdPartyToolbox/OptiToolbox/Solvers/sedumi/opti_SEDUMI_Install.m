%SeDuMi installation script
%
% This file is part of SeDuMi 1.1 by Imre Polik and Oleksandr Romanko
% Copyright (C) 2005 McMaster University, Hamilton, CANADA  (since 1.1)
%
% Copyright (C) 2001 Jos F. Sturm (up to 1.05R5)
%   Dept. Econometrics & O.R., Tilburg University, the Netherlands.
%   Supported by the Netherlands Organization for Scientific Research (NWO).
%
% Affiliation SeDuMi 1.03 and 1.04Beta (2000):
%   Dept. Quantitative Economics, Maastricht University, the Netherlands.
%
% Affiliations up to SeDuMi 1.02 (AUG1998):
%   CRL, McMaster University, Canada.
%   Supported by the Netherlands Organization for Scientific Research (NWO).
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA

% Modified J.Currie April 2013
%
% My build platform:
% - Windows 7 SP1 x64
% - Visual Studio 2010
% - Intel Math Kernel Library

%List of Files to Compile (and dependencies)
sourcelist={...
    'bwblkslv.c sdmauxFill.c sdmauxRdot.c',...
    'choltmpsiz.c',...
    'cholsplit.c',...
    'dpr1fact.c auxfwdpr1.c sdmauxCone.c  sdmauxCmp.c sdmauxFill.c sdmauxScalarmul.c sdmauxRdot.c blkaux.c',...
    'symfctmex.c symfct.c',...
    'ordmmdmex.c ordmmd.c',...
    'quadadd.c',...
    'eigK.c sdmauxCone.c sdmauxRdot.c',...
    'sqrtinv.c sdmauxCone.c',...
    'givensrot.c auxgivens.c sdmauxCone.c',...
    'urotorder.c auxgivens.c sdmauxCone.c sdmauxTriu.c sdmauxRdot.c',...
    'psdframeit.c reflect.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c',...
    'psdinvjmul.c reflect.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c',...
    'bwdpr1.c sdmauxCone.c sdmauxRdot.c',...
    'fwdpr1.c auxfwdpr1.c sdmauxCone.c sdmauxScalarmul.c',...
    'fwblkslv.c sdmauxScalarmul.c',...
    'qblkmul.c sdmauxScalarmul.c',...
    'blkchol.c blkchol2.c sdmauxFill.c sdmauxScalarmul.c',...
    'vecsym.c sdmauxCone.c',...
    'qrK.c sdmauxCone.c sdmauxRdot.c sdmauxScalarmul.c',...
    'finsymbden.c sdmauxCmp.c',...
    'symbfwblk.c',...
    'statsK.c sdmauxCone.c',...
    'whichcpx.c sdmauxCone.c',...
    'eyeK.c sdmauxCone.c',...
    'ddot.c sdmauxCone.c sdmauxRdot.c sdmauxScalarmul.c',...
    'makereal.c sdmauxCone.c sdmauxCmp.c',...
    'partitA.c sdmauxCmp.c',...
    'getada1.c sdmauxFill.c',...
    'getada2.c sdmauxCone.c sdmauxRdot.c sdmauxFill.c',...
    'getada3.c spscale.c sdmauxCone.c sdmauxRdot.c sdmauxScalarmul.c sdmauxCmp.c',...
    'adendotd.c sdmauxCone.c',...
    'adenscale.c',...
    'extractA.c',...
    'vectril.c sdmauxCone.c sdmauxCmp.c',...
    'qreshape.c sdmauxCone.c sdmauxCmp.c',...
    'sortnnz.c sdmauxCmp.c',...
    'iswnbr.c',...
    'incorder.c',...
    'findblks.c sdmauxCone.c sdmauxCmp.c',...
    'invcholfac.c triuaux.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c',...
    };

sourcelist = {'psdscale.c triuaux.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c'...
              'psdfactor.c triuaux.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c'...
              'psdeig.c triuaux.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c'...
              'psdinvscale.c triuaux.c sdmauxCone.c sdmauxRdot.c sdmauxTriu.c sdmauxScalarmul.c blkaux.c'};

%Generate function list
funclist = cell(size(sourcelist));
for i = 1:length(sourcelist)
    files = regexp(sourcelist{i},' ','split');
    ind = strfind(files{1},'.');
    funclist{i} = files{1}(1:ind-1);
end

%Clear existing functions in memory
clear(funclist{:});

% Modify below function if it cannot find Intel MKL on your system.
mkl_link = opti_FindMKL();

fprintf('\n------------------------------------------------\n');
fprintf('SeDuMi MEX FILES INSTALL\n\n');

%Get Headers and Libraries
post = [' -IInclude -DPC ' mkl_link];

%CD to Source Directory
cdir = cd;
cd '../Downloads/sedumi';

%Setup compiler command
pre = 'mex -largeArrayDims ';

try
%Compile & Move each file
for i = 1:length(funclist)    
    fprintf('Compiling %s.%s....',funclist{i},'c');
    eval([pre sourcelist{i} post])
    fprintf('Done!\n');
end
catch ME
    cd(cdir);
    error('opti:sedumi','Error Compiling SeDuMi!\n%s',ME.message);
end
cd(cdir);
fprintf('\nSeDuMi Compilation Complete\n');
fprintf('------------------------------------------------\n');