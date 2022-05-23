 function roiLimits12 = roiLimits(width,depth,xMax,yMax,zMax,x,y,z)
           %ROI size limits                 
           if (x-width) < 1 
                 xStart = 1 ;
            else xStart = (x-width);  
            end
            if (x+width) > xMax 
                 xEnd = xMax ;
            else xEnd = (x+width);  
            end
            if (y-width) < 1 
                 yStart = 1 ;
            else yStart = (y-width);  
            end
            if (y+width) > yMax 
                 yEnd = yMax ;
            else yEnd = (y+width);  
            end
            if (z-width) < 1 
                 zStart = 1 ;
            else zStart = (z-width);  
            end
            if (z+width) > zMax 
                 zEnd = zMax ;
            else zEnd = (z+width);  
            end
            % if projections of depth are used determine projection limits
            if depth >0
                if (x-depth) < 1 
                xPStart = 1 ;
                else xPStart = (x-depth);  
                end
                if (x+depth) > xMax 
                     xPEnd = xMax ;
                else xPEnd = (x+depth);  
                end
                if (y-depth) < 1 
                     yPStart = 1 ;
                else yPStart = (y-depth);  
                end
                if (y+depth) > yMax 
                     yPEnd = yMax ;
                else yPEnd = (y+depth);  
                end
                if (z-depth) < 1 
                     zPStart = 1 ;
                else zPStart = (z-depth);  
                end
                if (z+depth) > zMax 
                     zPEnd = zMax ;
                else zPEnd = (z+depth);  
                end
            else
                xPStart = x;
                xPEnd = x;
                yPStart = y;
                yPEnd = y;
                zPStart = z;
                zPEnd = z;
            end
        roiLimits12 = [xStart xEnd yStart yEnd zStart zEnd...
                       xPStart xPEnd yPStart yPEnd zPStart zPEnd];
            
        end