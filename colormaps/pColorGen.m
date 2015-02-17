% This functon creates a COLOR vector based on the colormap

classdef (HandleCompatible = true) pColorGen < handle

    % PROPERTIES FOR USER TO SEE AND SET
    properties (SetObservable)
        
        ColorMap        = lines(64);
        
    end
        
    % HIDDEN PROPERTIES FOR INTERNAL USE
    properties (Hidden,SetAccess=private)
        
        CurrentIndex    = 1;
        
    end
    
    methods 
        
        % CONSTRUCTER
        function obj = pColorGen(varargin)
            
            % CHECK IF VARARGIN IS GIVEN
            if ~isempty(varargin)
                
                % IF VARARGIN IS 3*N MATRIX, SET AS COLORMAP
                if isnumeric(varargin{1}) && size(varargin{1},2) == 3 
                    
                    obj.ColorMap = varargin{1};
                    
                % THROW ERROR
                else
                    
                    display('Error (pColorGen): Input needs to be n x 3 matrix, using default')
                    return;
                    
                end
                
            end
            
            % SET UPDATE LISTENERS
            addlistener(obj,'ColorMap'     ,'PostSet',@obj.propertyUpdate);
            
        end
        
        
        % COLOR GENERATE FUNCTION
        function color = Generate(obj)
            
            % STEP THE CURRENT INDEX
            obj.CurrentIndex = mod(obj.CurrentIndex,64)+1;
            
            % EXTRACT COLOR
            color = obj.ColorMap(obj.CurrentIndex,:);
            
        end
        
        
        % CHECK VARIABLES ON PROPERTY UPDATE
        function propertyUpdate(obj,~,~)
            
            if ~(isnumeric(obj.ColorMap) && size(obj.ColorMap,2) == 3)
                
                display('Error (pColorGen): Input needs to be n x 3 matrix, using default')
                obj.ColorMap = lines(64);
                return;
                
            end
            
        end
        
    end
    
end


