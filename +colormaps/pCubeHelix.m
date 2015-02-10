% This function uses the CUBEHELIX colormap on the current figure

function pCubeHelix(varargin)
        
    % GET CURRENT FIGURE
    figureHandle = get(0,'CurrentFigure');

    % CHECK FOR ERROR
    if isempty(figureHandle)
        display('Error (pCubeHelix): no figure open')
        return;
    end

    % GET AXIS FROM FIGURE
    axisHandle = get(figureHandle,'CurrentAxes');
    
    % GET CHILD HANDLES FROM AXIS
    children = get(axisHandle,'Children');
    
    % EXCLUDE NON-SURFACE OR NON-IMAGE CHILDREN
    children = [children(strcmp(get(children,'Type'),'surface')); children(strcmp(get(children,'Type'),'image'))];
    
    % CHECK IF FIGURE HAS VALID PLOTS
    if isempty(children)
        display('Error (pCubeHelix): figure has no valid surface or image plots')
        return;
    end

    % SET COLORMAP
    set(figureHandle,'Colormap',CubeHelix(varargin))

end


% THE FUNCTION BELOW IS COPIED FROM arXiv:1108.5083
% AND MODIFIED SLIGHTLY
% Original written in Fortran77 by Dave Green, 2011 Jan 10
% Transcribed to MATLAB by Philip Graff, 2011 Sept 1
function map = CubeHelix(varargin)
    % Usage:
    %         colormap(CubeHelix(...))
    %
    %==========================================================
    % Calculates a "cube helix" colour map for MATLAB. The
    % colours are a tapered helix around the diagonal of the
    % RGB colour cube, from black [0,0,0] to white [1,1,1].
    % Deviations away from the diagonal vary quadratically,
    % increasing from zero at black to a maximum and then
    % decreasing to zero at white, all the time rotating in
    % colour.
    %
    % The input values are:
    %   nlev  = number of colour steps
    %   start = colour to begin at (1=red, 2=green, 3=red;
    %           e.g. 0.5=purple)
    %   rots  = number of rotations
    %   hue   = hue intensity scaling, 0=B&W
    %   gamma = intensity correction
    %
    % The routine returns an nlev-by-3 matrix that can be used
    % as a colourmap for MATLAB (function 'colormap').
    %
    % Use (256,0.5,-1.5,1.2,1.0) as defaults.
    %
    % See arXiv:1108.5083 for more details.
    %
    %----------------------------------------------------------
    % Original written in Fortran77 by Dave Green, 2011 Jan 10
    % Transcribed to MATLAB by Philip Graff, 2011 Sept 1
    %==========================================================
    if length(varargin) ~= 5
        nlev = 256;
        start = 0.5;
        rots = -1.5;
        hue = 1.2;
        gamma = 1;
    else
        nlev = varargin{1};
        start = varargin{2};
        rots = varargin{3};
        hue = varargin{4};
        gamma = varargin{5};
    end
    map=zeros(nlev,3);
    A=[-0.14861,1.78277;-0.29227,-0.90649;1.97294,0];
    for i=1:nlev
        fract=(i-1)/(nlev-1);
        angle=2*pi*(start/3+1+rots*fract);
        fract=fract^gamma;
        amp=hue*fract*(1-fract)/2;
        map(i,:)=fract+amp*(A*[cos(angle);sin(angle)])';
        for j=1:3
            if map(i,j)<0
                map(i,j)=0;
            elseif map(i,j)>1
                map(i,j)=1;
            end
        end
    end
end