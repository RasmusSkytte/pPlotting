% This function uses the HAXBY colormap on the current figure

function pHaxby(varargin)
        
    % GET CURRENT FIGURE
    figureHandle = get(0,'CurrentFigure');

    % CHECK FOR ERROR
    if isempty(figureHandle)
        display('Error (pHaxby): no figure open')
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
        display('Error (pHaxby): figure has no valid surface or image plots')
        return;
    end

    % SET COLORMAP
    set(figureHandle,'Colormap',Haxby(varargin))

end


% THE FUNCTION BELOW IS COPIED FROM http://www.mathworks.com/matlabcentral/fileexchange/25690-haxby-color-map
% AND MODIFIED SLIGHTLY
% Original written by Kelsey Jordahl, 2009 OCT 30
function map = Haxby(m)
    %HAXBY  Haxby color map
    %   HAXBY(M) returns an M-by-3 matrix containing a colormap with Haxby's
    %   colors, commonly used for displaying bathymetry data.
    %   HAXBY, by itself, is the same length as the current colormap.
    %
    %   For example, to reset the colormap of the current figure:
    %
    %             colormap(haxby)
    %
    %   Use
    %             colormap(flipud(haxby))
    %
    %   for bathymetry data (positive downward).
    %
    %   Colormap is based on the colors used by W. F. Haxby's Gravity
    %   field of World's oceans, 1985, developed for geoid and gravity maps.
    %   The version used here is formed from a linear interpolation of
    %   the GMT color table used by MB-System by David W. Caress and Dale N. Chayes.
    %   <http://www.ldeo.columbia.edu/res/pi/MB-System>
    %
    %   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, HOT
    %   COLORMAP, RGBPLOT.

    % Kelsey Jordahl
    % Marymount Manhattan College
    % Time-stamp: <Fri Oct 30 12:45:12 EDT 2009>

    if isempty(m)
        m = size(get(gcf,'colormap'),1);
    end
    % mbm_grdplot Haxby color pallette
    ncolors=11;
    c=[ 37    57   175;    40   127   251;    50   190   255;   106   235   255;
        138   236   174;   205   255   162;   240   236   121;   255   189    87;
        255   161    68;   255   186   133;   255   255   255];
    pp=1:(m-1)/(ncolors-1):m;
    r=interp1(pp,c(:,1),1:m);
    g=interp1(pp,c(:,2),1:m);
    b=interp1(pp,c(:,3),1:m);
    map=[r' g' b']/255;
end