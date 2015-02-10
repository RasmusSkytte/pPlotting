% This function generates a BAR plot, for easy usage use pBar(myData), but you can also call h=pBar, and then do h.data = myData

classdef (HandleCompatible = true) pBar < handle
    
    % PROPERTIES FOR USER TO SEE AND SET
    properties (SetObservable)
        EdgeColor = 'None';
        color = [];
        xData = [];
        yData = [];
        barWidth = 10;
    end
    
    % HIDDEN PROPERTIES FOR INTERNAL USE
    properties (Hidden,SetAccess=private)
        statHandle = [];
        figureHandle = [];
        copyHandles = [];
        graphicsHandle = [];
    end
    
    
    
    methods 
        % CONSTRUCTER
        function obj = pHist(varargin)
            % ASSING COLOR TO HISTOGRAM
            obj.color = pColorGen;
            
            % CHECK IF VARARGIN IS GIVEN
            if ~isempty(varargin)
                % IF VARARGIN IS VECTOR, SET AS DATA
                if isvector(varargin)
                    obj.data = varargin{1};
                    obj.draw
                    
                % THROW ERROR
                else
                    display('Error (pHist): arguments could not be parsed')
                end
            end
                
            % SET UPDATE LISTENERS
            addlistener(obj,'linewidth','PostSet',@obj.propertyUpdate);
            addlistener(obj,'color','PostSet',@obj.propertyUpdate);
            addlistener(obj,'solid','PostSet',@obj.propertyUpdate);
            addlistener(obj,'stat','PostSet',@obj.propertyUpdate);
            addlistener(obj,'data','PostSet',@obj.propertyUpdate);
            addlistener(obj,'binCount','PostSet',@obj.propertyUpdate);
        end

        

        % DRAW HISTOGRAM
        function draw(obj)
            
            % CHECK THAT HISTOGRAM HAS DATA
            if isempty(obj.data)
                display('Error (pHist): no data in object, set data before using draw()')
            end
            
            % VERIFY VECTOR DATA
            if ~isvector(obj.data)
                display('Error (pHist): only a single vector can be used as data')
                obj.data = [];
                return;
            end
            
            % BRING FIGURE TO FRONT, OR CREATE NEW FIGURE
            if ishandle(obj.figureHandle)
                figure(obj.figureHandle)
                
                % DELETE OLD HISTOGRAM
                if ~isempty(obj.graphicsHandle)
                    
                    % EXCLUDE THE 0 HANDLE
                    obj.graphicsHandle = obj.graphicsHandle(obj.graphicsHandle~=0);
                    
                    % DELETE REMAING HANDLES
                    delete(obj.graphicsHandle(ishandle(obj.graphicsHandle)))
                    obj.graphicsHandle = [];
                    
                end
                
                if ~isempty(obj.statHandle)
                    
                    % EXCLUDE THE 0 HANDLE
                    obj.statHandle = obj.statHandle(obj.statHandle~=0);
                    
                    % DELETE REMAING HANDLES
                    delete(obj.statHandle(ishandle(obj.statHandle)))
                    obj.statHandle = [];
                end
                
            else
                obj.figureHandle = figure;
            end

            
            
            % GET HISTOGRAM DATA
            [nElements, centers] = hist(obj.data,obj.binCount);
            
            
            
            % GET BIN WIDTH
            binWidth = centers(2)-centers(1);
            
            
            
            % GENERATE DATA FOR PLOT
            xdata = zeros(2*obj.binCount,1);        % ALLOCATE
            ydata = zeros(2*obj.binCount,1);        % ALLOCATE
            
            xdata(1:2:end) = centers-binWidth/2;    % BIN START
            xdata(2:2:end) = centers+binWidth/2;    % BIN END
            ydata(1:2:end) = nElements;             % BIN HEIGHT
            ydata(2:2:end) = nElements;             % BIN HEIGHT
            
            xdata = [xdata(1); xdata; xdata(end)];  % ADD START AND
            ydata = [0; ydata; 0];                  % END POINT
            
            
            
            % SET AXES HOLD
            hold on
            
            
            
            % PLOT SOLID FILL
            if obj.solid
                obj.graphicsHandle(1) = patch(xdata,ydata,ones(size(xdata)),...
                    'EdgeColor','None',...
                    'FaceColor',hsv2rgb(rgb2hsv(obj.color).*[1 0.35 1]));  % LIGHTEN COLOR A BIT
            end
           
            
            
            % PLOT LINE ALONG EDGE
            obj.graphicsHandle(2) = plot(xdata,ydata,'Color',obj.color,'Linewidth',obj.linewidth);
            
           
            
            
            % PLOT STATISTCS
            if strfind(obj.stat,'BOX')
                
                
                % CALCULATE MEAN
                mu = mean(obj.data);
                
                
                
                % CALCULATE STANDARD DEVIATION
                RMS = sqrt(var(obj.data));
                
                
                
                % STANDARD ERROR ON THE MEAN
                sigma_mu = RMS/sqrt(length(xdata));
                
                
                
                % CREATE STAT BOX
                obj.statHandle(1) = uipanel('Title','StatBox','FontSize',12,... % OUTER BOX
                    'BackgroundColor','White',...
                    'Position',[0.6 0.75 0.3 0.15]);
                h = uicontrol('Parent',obj.statHandle(1),...                    % TEXT BOX
                    'Style','Text',...
                    'Units','Normalized',...
                    'Position',[0.05 0.05 0.90 0.90],...
                    'BackgroundColor',[1 1 1],...
                    'HorizontalAlignment','Left',...
                    'FontSize',12,...
                    'String', {sprintf('Mean:\t\t % .2g +- % .2g',mu,sigma_mu),sprintf('RMS:\t\t % .2g',RMS)});
                
                
                
                % RESIZE STATBOX TO FIT TEXT BOX
                extent = get(h,'Extent');
                set(obj.statHandle(1),'Position',[0.85-extent(3) 0.85-extent(4) extent(3)+0.05 extent(4)+0.05])
                
                
                
                % SET UPDATE CALLBACK FOR FIGURE
                set(obj.figureHandle,'ResizeFcn',@obj.doUpdate)
                set(obj.figureHandle,'CloseRequestFcn',@obj.doCleanup)
                
                
            end
            
            
            if strfind(obj.stat,'QUICK')
                
                
                % CALCULATE MEAN
                mu = mean(obj.data);
                
                
                
                % CALCULATE STANDARD DEVIATION
                RMS = sqrt(var(obj.data));
                
                
                
                % PLOT ERROR MARKER
                hold on
                ypos = max(nElements)*1.15;
                obj.statHandle(2) = scatter(mu,ypos,... % CENTER DOT
                    'MarkerEdgeColor',obj.color,...
                    'MarkerFaceColor',obj.color);
                
                
                
                % GENERATE ERROR LINE DATA
                err_xdata = [repmat(mu-RMS,1,3) repmat(mu+RMS,1,3)];
                
                
                
                % WE MAKE THE T's AT THE END BE 0.03 MAX BIN HEIGHT
                err_ydata = [ypos+0.03*max(nElements) ypos-0.03*max(nElements) ypos ypos ypos+0.03*max(nElements) ypos-0.03*max(nElements)];
                obj.statHandle(3) = plot(err_xdata,err_ydata,... % ERROR LINE
                    'Color',obj.color,...
                    'LineWidth',2);
                
                
            end
        end
        
        
        
        % STATISTICS OUTPUT
        % GET MEAN
        function output = getMean(obj)
            
            % RETURN MEAN AND UNCERTAINTY
            output.mean = mean(obj.data);
            output.uncertainty = std(obj.data)/sqrt(length(obj.data));
            
        end
        
        
        
        % RECOLOR HISTOGRAM
        function reColor(obj)
            
            % GRAB NEW COLOR
            obj.color = pColorGen;
            
            
            % REDRAW
            obj.draw
            
            
        end

        

        % WHEN FIGURE IS RESIZED WE NEED TO UPDATE SOME ELEMENTS
        function doUpdate(obj,~,~)
            
            % CHECK IF STAT BOX EXISTS
            if obj.statHandle(1)~=0
                obj.reSizeStatBox
            end
            
        end
        
        
        
        % WHEN FIGURE IS CLOSED WE NEED TO UPDATE FIGURE HANDLES
        function doCleanup(obj,h,~)
            
            % DELETE FIGUER HANDLE FROM PROPERTIES
            if obj.figureHandle == h
                obj.figureHandle = [];
            end
            
            delete(h)
            
        end
        
        
        
        %RESCALE THE STAT BOX
        function reSizeStatBox(obj)
            
            % GET EXTENT OF TEXT BOX
            extent = get(get(obj.statHandle(1),'Children'),'Extent');
            
            
            % RESIZE STAT BOX
            set(obj.statHandle(1),'Position',[0.85-extent(3) 0.85-extent(4) extent(3)+0.05 extent(4)+0.05])
            
            
        end
        
        
        
        % REDRAW ON PROPERTY UPDATE
        function propertyUpdate(obj,~,~)
            obj.draw
        end
        
        
        % APPENDING FUNCTION
        function append(obj)
            
            
            % GET CURRENT FIGURE
            currentFigure = get(0,'CurrentFigure');
            
            
            % GET CURRENT AXES
            currentAxes =  get(currentFigure,'CurrentAxes');
            
            for i = 1:length(obj.graphicsHandle)
                obj.copyHandles(end+1) = copyobj(obj.graphicsHandle, currentAxes);
            end
            
        end
    end
end