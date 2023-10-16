%% PURPOSE: Applies Current Source Density (CSD, also called surface Laplacian) 
% tranformation on EEG data using spherical splines.
%  
% Inputs: 
%   chanlocfile     - full path and name to file with EEG channel locations of
%                       the montage used for these data (compatible with .loc, .ced, .xyz files).
%   mcont           - m-constant between 2 (vey flexible) and 10 (not flexible). Default = 4.
%   smoothl         - Smoothing constant lambda that sets CSD spline interpolation 
%                       flexibility (default = 0.00001). 
%   headrad         - Head radius CSD rescaling value (default = 10 cm).
% 
% Output:
%   CSD-transformed EEG data
% 
% Usage:
%   EEG = csd_transform(EEG)
% 
% Cedric Cannard, 2022
% 
% Original code:
%   https://psychophysiology.cpmc.columbia.edu/software/CSDtoolbox/index.html and ERPLAB
% 
% Reference: 
%   Kayser, J., Tenke, C.E. (2006). Principal components analysis of Laplacian waveforms 
%   as a generic method for identifying ERP generator patterns: I. Evaluation with auditory oddball tasks. 
%   Clinical Neurophysiology, 117(2), 348-368. doi:10.1016/j.clinph.2005.08.034

function EEG = csd_transform(EEG, chanlocfile, mcont, smoothl, headrad)

% check that data was not already CSD-transformed
if strcmp(EEG.ref,'csd-transform') == 1
    error('These data are already CSD-transformed'); 
end

% Channel locations
if ~exist('chanlocfile','var') || isempty(chanlocfile)
%     disp('Please select the channel location file corresponding to your EEG montage. It must be a .ced file.')
%     [locname, locpath] = uigetfile2({'*.'}, 'Select channel locations file (.ced, .locs, .xyz)'); 
%     chanlocfile = fullfile(locpath, locname);
    locPath = fileparts(which('csd_transform.m'));
    chanlocfile = fullfile(locPath, 'chanlocs_standard_BEM_1005.ced');
    disp('Using default BEM 1005 channel locations.')
end
EEG = pop_chanedit(EEG,'rplurchanloc',1,'lookup',chanlocfile);

% Other default inputs
if ~exist('mcont','var') || isempty(mcont)
    mcont = 4;
    disp('Using default mcont value = 4'); 
end
if ~exist('smoothl','var') || isempty(smoothl)
    smoothl = 0.00001; 
    disp('Using default smoothl value = 0.00001'); 
end
if ~exist('headrad','var') || isempty(headrad)
    headrad = 10; 
    disp('Using default headrad value = 10'); 
end

% Convert EEG channel locations into CSD locations
locExt = chanlocfile(end-2:end);
disp('Converting EEG channel locations into CSD locations')
switch locExt
    case 'xyz'
        [labels,X,Y,Z] = textread(chanlocfile, '%s%f%f%f%*[^\n]','commentstyle','c++');
%         [ThetaRad,PhiRad] = cart2sph(X,Y,Z);
        [ThetaRad,PhiRad] = cart2sph([EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);
        theta = ThetaRad * 180 / pi;
        phi = PhiRad * 180 / pi;
        for n = 1:EEG.nbchan
            z = X(n).^2 + Y(n).^2 + Z(n).^2 - 1; % calculate off sphere surface
            % disp(sprintf('%8s%10.4f%10.4f%10.4f%22.17f', char(lab(n,:)),X(n),Y(n),Z(n),z));
        end
    case 'ced'
        [Number,labels,th,radius,X,Y,Z,sph_theta,sph_phi,sph_radius] = textread(chanlocfile, '%n%s%f%f%f%f%f%f%f%f%*[^\n]','headerlines',1);
        theta = sph_theta + 90;     % rotate theta +90 degrees
        if theta > 180              % adjust theta if neccessary
            theta = theta - 360;
        end
        phi = sph_phi;
    case 'locs'
        [Number,th,radius,labels] = textread(chanlocfile, '%n%f%f%s%*[^\n]');
        theta = -th + 90;
        if theta > 180
            theta = theta - 360;      % adjust theta if neccessary
        end
        theta = theta;
        phi = 90 - (radius * 180);
    case 'csd'
        [labels,theta,phi] = textread(chanlocfile, '%s%f%f%*[^\n]','commentstyle','c++');

    otherwise
        errordlg(['Your channel location file is not compatible with this function. ' ...
            'Go to: Edit > Channel locations, select your file > Save (as .ced). ' ...
            'Then adjust your path to load the .ced file you generated']); return
end

% Montage structure
for iChan = 1:EEG.nbchan
    match = strcmpi(labels, {EEG.chanlocs(iChan).labels});
    M.lab(iChan) = {EEG.chanlocs(match).labels};
    M.theta(iChan) = theta(match);
    M.phi(iChan) = phi(match);
end
% lab = lab0';
% theta = theta0';
% phi = phi0';
% sph_theta = theta - 90;           % rotate theta -90 degrees
% if sph_theta < -180
%   sph_theta = sph_theta + 360;      % adjust theta if neccessary
% end      
% sph_phi = phi;
% th = -sph_theta;
% radius = (90 - phi) / 180;
% if strcmp(locExt, 'ced')            % reassign spherical angles for X,Y,Z coordinates
%     theta = sph_theta; 
%     phi = sph_phi;
% end
% % convert Theta and Phi to radians and Cartesian coordinates for optimal resolution
% ThetaRad = pi / 180 * theta;             
% PhiRad = pi / 180 * phi;                 
% [X,Y,Z] = sph2cart(ThetaRad,PhiRad,1);
% if strcmp(locExt, 'csd')
%     for n = 1:EEG.nbchan
%         z = X(n).^2 + Y(n).^2 + Z(n).^2 - 1; % calculate off sphere surface
%     end
% end

% ConvertLocations(chanlocfile,'chanlocs_csd.csd',{EEG.chanlocs.labels}');
% M = ExtractMontage('chanlocs_csd.csd', {EEG.chanlocs.labels}');

% generate transform matrices
[csd_G, csd_H] = GetGH(M, mcont);
% [csd_G2, csd_H2] = GetGH(M2, mcont);
% sum(csd_G2(2,:) - csd_G(2,:))

% clean up CSD fields from EEG structure
EEG = rmfield(EEG,'chaninfo');

% Run CSD-transformation
csd_data = zeros(size(EEG.data)); %preallocate
disp('Running CSD-transformation...')
csd_data(:,:) = current_source_density(EEG.data(:,:),csd_G,csd_H,smoothl,headrad);
disp('Completed')

% Write the history with a datatype note
% EEG = erphistory(EEG,[],'% converted dataset to Current Source Density datatype',1);
EEG.ref = 'csd-transform';
EEG.data = csd_data;
EEG = eeg_checkset(EEG);

end

