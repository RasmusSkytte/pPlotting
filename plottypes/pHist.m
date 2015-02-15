% This function generates a HISTOGRAM, for easy usage use pHist(myData), but you can also call h=pHist, and then do h.data = myData

classdef (HandleCompatible = true) pHist < handle

    % PROPERTIES FOR USER TO SEE AND SET
    properties (SetObservable)
        Linewidth       = 2;
        Color           = [];
        Solid           = true;
        StatDrawStyle   = 'QUICK';
        Data            = [];
        Statistics      = struct;
        BinCount        = 20;
    end
        
    % HIDDEN PROPERTIES FOR INTERNAL USE
    properties (Hidden,SetAccess=private)
        StatHandle = [];
        FigureHandle = [];
        GraphicsHandle = [];
    end
    
    methods 
        % CONSTRUCTER
        function obj = pHist(varargin)
            % ASSING COLOR TO HISTOGRAM
            obj.Color = lines(1);
            
            % CHECK IF VARARGIN IS GIVEN
            if ~isempty(varargin)
                
                % IF VARARGIN IS VECTOR, SET AS DATA
                if isvector(varargin)
                    obj.Data = varargin{1};
                    obj.Draw
                    
                % THROW ERROR
                else
                    display('Error (pHist): arguments could not be parsed')
                end
            end
                
            % SET UPDATE LISTENERS
            addlistener(obj,'Linewidth'     ,'PostSet',@obj.propertyUpdate);
            addlistener(obj,'Color'         ,'PostSet',@obj.propertyUpdate);
            addlistener(obj,'Solid'         ,'PostSet',@obj.propertyUpdate);
            addlistener(obj,'StatDrawStyle' ,'PostSet',@obj.propertyUpdate);
            addlistener(obj,'Data'          ,'PostSet',@obj.propertyUpdate);
            addlistener(obj,'BinCount'      ,'PostSet',@obj.propertyUpdate);

        end

        

        % DRAW HISTOGRAM
        function Draw(obj)
            
            % CHECK THAT HISTOGRAM HAS DATA
            if isempty(obj.Data)
                display('Error (pHist): No data in object, set data before using draw()')
                return;
            end
            
            % VERIFY VECTOR DATA
            if ~isvector(obj.Data)
                display('Error (pHist): Only a single vector can be used as data')
                obj.Data = [];
                return;
            end
            
            % BRING FIGURE TO FRONT, OR CREATE NEW FIGURE
            if ishandle(obj.FigureHandle)
                figure(obj.FigureHandle)
                
                % DELETE OLD HISTOGRAM
                if ~isempty(obj.GraphicsHandle)
                    
                    % EXCLUDE THE 0 HANDLE
                    obj.GraphicsHandle = obj.GraphicsHandle(obj.GraphicsHandle~=0);
                    
                    % DELETE REMAING HANDLES
                    delete(obj.GraphicsHandle(ishandle(obj.GraphicsHandle)))
                    obj.GraphicsHandle = [];
                    
                end
                
                if ~isempty(obj.StatHandle)
                    
                    % EXCLUDE THE 0 HANDLE
                    obj.StatHandle = obj.StatHandle(obj.StatHandle~=0);
                    
                    % DELETE REMAING HANDLES
                    delete(obj.StatHandle(ishandle(obj.StatHandle)))
                    obj.StatHandle = [];
                end
                
            else
                obj.FigureHandle = figure;
            end

            % GET HISTOGRAM DATA
            [nElements, centers] = hist(obj.Data,obj.BinCount);
            
            
            % GET BIN WIDTH
            binWidth = centers(2)-centers(1);
            
            
            % GENERATE DATA FOR PLOT
            xdata = zeros(2*obj.BinCount,1);        % ALLOCATE
            ydata = zeros(2*obj.BinCount,1);        % ALLOCATE
            
            xdata(1:2:end) = centers-binWidth/2;    % BIN START
            xdata(2:2:end) = centers+binWidth/2;    % BIN END
            ydata(1:2:end) = nElements;             % BIN HEIGHT
            ydata(2:2:end) = nElements;             % BIN HEIGHT
            
            xdata = [xdata(1); xdata; xdata(end)];  % ADD START AND
            ydata = [0; ydata; 0];                  % END POINT
            
            
            % CALCULATE STATISTICS
            % CALCULATE MEAN
            obj.Statistics.mean = mean(obj.Data);
            
            % CALCULATE STANDARD DEVIATION
            obj.Statistics.RMS = std(obj.Data);
            
            % STANDARD ERROR ON THE MEAN
            obj.Statistics.mean_uncertainty = obj.Statistics.RMS/sqrt(length(obj.Data));
            
            
            
            % SET BOX ON
            box on
            
            % SET AXES HOLD
            hold on
            
            
            % PLOT LINE ALONG EDGE
            obj.GraphicsHandle(2) = plot(xdata,ydata,'Color',obj.Color,'Linewidth',obj.Linewidth);
            
            
            % PLOT SOLID FILL
            if obj.Solid
                obj.GraphicsHandle(1) = patch(xdata,ydata,ones(size(xdata)),...
                    'EdgeColor','None',...
                    'FaceColor',hsv2rgb(rgb2hsv(obj.Color).*[1 0.35 1]));  % LIGHTEN COLOR A BIT
            end
           
            
            
            % PLOT STATISTCS BOX
%             if strfind(obj.stat,'BOX')    
% 
%                 CREATE TEXT BOX WITH STATS
%                 h = uicontrol('Style','Text',...                    % TEXT BOX
%                     'Units','Normalized',...
%                     'Position',[0.05 0.05 0 0],...
%                     'BackgroundColor',[1 1 1],...
%                     'HorizontalAlignment','Left',...
%                     'FontSize',12,...
%                     'String', {sprintf('Mean:\t\t % .2g +- % .2g',mu,sigma_mu),sprintf('RMS:\t\t % .2g',RMS)});
%                 
%                 annotation('textbox', [0.2,0.4,0.1,0.1],...
%                'String', {sprintf('Mean:\t\t % .2g +- % .2g',mu,sigma_mu),sprintf('RMS:\t\t % .2g',RMS)}))
% 
%                 
%                 SET THE SIZE OF THE BOX
%                 h.Position = h.Position + h.Extent;
%                 
%                 SET UPDATE CALLBACK FOR FIGURE
%                 set(obj.FigureHandle,'ResizeFcn',@obj.doUpdate)
%                 set(obj.FigureHandle,'CloseRequestFcn',@obj.doCleanup)
%                  
%             end
            
            % PLOT STATISTCS QUICK
            if strfind(obj.StatDrawStyle,'QUICK')
                
                % PLOT ERROR MARKER
                hold on
                ypos = max(nElements)*1.15;
                obj.StatHandle(2) = scatter(obj.Statistics.mean,ypos,... % CENTER DOT
                    'MarkerEdgeColor',obj.Color,...
                    'MarkerFaceColor',obj.Color);
                
                
                % GENERATE ERROR LINE DATA
                err_xdata = [repmat(obj.Statistics.mean-obj.Statistics.RMS,1,3) repmat(obj.Statistics.mean+obj.Statistics.RMS,1,3)];
                
                
                % WE MAKE THE T's AT THE END BE 0.03 MAX BIN HEIGHT
                err_ydata = [ypos+0.03*max(nElements) ypos-0.03*max(nElements) ypos ypos ypos+0.03*max(nElements) ypos-0.03*max(nElements)];
                obj.StatHandle(3) = plot(err_xdata,err_ydata,... % ERROR LINE
                    'Color',obj.Color,...
                    'LineWidth',2);
                
                
            end
        end
        
        
        
        % STATISTICS OUTPUT
        % GET MEAN
        function output = getMean(obj)
            
            % RETURN MEAN AND UNCERTAINTY
            output.mean = obj.Statistics.mean;
            output.uncertainty = obj.Statistics.mean_uncertainty;
            
        end
        
        
        
        % RECOLOR HISTOGRAM
        function reColor(obj)
            
            % GRAB NEW COLOR
            obj.Color = pColorGen;
            
            % REDRAW
            obj.Draw
            
        end

        

        % WHEN FIGURE IS RESIZED WE NEED TO UPDATE SOME ELEMENTS
        function doUpdate(obj,~,~)
            
            % CHECK IF STAT BOX EXISTS
            if obj.StatHandle(1)~=0
                obj.reSizeStatBox
            end
            
        end
        
        
        
        % WHEN FIGURE IS CLOSED WE NEED TO UPDATE FIGURE HANDLES
        function doCleanup(obj,h,~)
            
            % DELETE FIGURE HANDLE FROM PROPERTIES
            if obj.FigureHandle == h
                obj.FigureHandle = [];
            end
            
            delete(h)
            
        end
        
        
        
        %RESCALE THE STAT BOX
        function reSizeStatBox(obj)
            
            % GET EXTENT OF TEXT BOX
            extent = get(get(obj.StatHandle(1),'Children'),'Extent');
            
            % RESIZE STAT BOX
            set(obj.StatHandle(1),'Position',[0.85-extent(3) 0.85-extent(4) extent(3)+0.05 extent(4)+0.05])
            
        end
        
        
        
        % REDRAW ON PROPERTY UPDATE
        function propertyUpdate(obj,~,~)
            if ~(isnumeric(obj.Linewidth) && numel(obj.Linewidth)==1)
                display('Error (pHist): Linewidth must be a single number')
                obj.Linewidth = 2;
            end
            if ~(isnumeric(obj.Color) && numel(obj.Color)==3)
                display('Error (pHist): Color must be a three element vector')
                obj.Color = lines(1);
            end
            if ~(isnumeric(obj.Solid) && numel(obj.Solid)==1)
                display('Error (pHist): Fill parameter must be a single number')
                obj.Solid = 1;
            end
            if ~all(arrayfun(@(x) any(strcmpi(x,{'QUICK','BOX'})),strsplit(obj.StatDrawStyle,';')))
                display('Error (pHist): Invalid Statistics Draw Style, using "QUICK" instead')
                obj.StatDrawStyle = 'QUICK';
            end
            if ~isvector(obj.Data)
                display('Error (pHist): Error in data format; must be a single vector')
                obj.Data = [];
            end
            if ~(isnumeric(obj.BinCount) && numel(obj.BinCount)==1)
                display('Error (pHist): BinCount must be a single number')
                obj.BinCount = 20;
            end
            obj.Draw
        end
        
        
        % ADDING FUNCTION
        function add(obj,addableObj)
            
           % CLOSE THE CURRENT WINDOW
           close(obj.FigureHandle)
           
           % ASSIGN NEW FIGURE WINDOW
           obj.FigureHandle = addableObj.FigureHandle;
           
           % REDRAW FIGURE
           obj.Draw()
            
        end
    end
end


