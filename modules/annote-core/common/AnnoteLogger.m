classdef AnnoteLogger < log4m
% ANNOTELOGGER
%
% DESCRIPTION:
%   
% 
% SYNTAX:
%
%   
% INPUTS:
%
% 
% OUTPUTS:
%
%
% COMMENTS:
%
%
%@
% Copyright 2016 The Johns Hopkins University Applied Physics Laboratory
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is 
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%@
%
    methods (Access = public)
        
        function self = AnnoteLogger(fullpath_passed)
          
			self@log4m(fullpath_passed);
        end
    end
    
     methods (Access = protected)  
         
         function writeLog(self,level,scriptName,message)
              
             writeLog@log4m(self,level,scriptName,message);
             
             % TODO: Write to pannel?
         end
         
         function writeCommandWindow(self,level,scriptName,message)
                  
            % set up our level string
            switch level
                case{self.TRACE}
                    levelStr = 'TRACE';
                    colorStr = '[0,0,0]';
                case{self.DEBUG}
                    levelStr = 'DEBUG';
                    colorStr = '*[0,0,1]';
                case{self.INFO}
                    levelStr = 'INFO';
                    colorStr = '*[0,0.5,0.5]';
                case{self.WARN}
                    levelStr = 'WARN';
                    colorStr = '*[1,0.5,0]';
                case{self.ERROR}
                    levelStr = 'ERROR';
                    colorStr = '*[1,0,0]';
                case{self.FATAL}
                    levelStr = 'FATAL';
                    colorStr = '*[1,0,0.5]';
                otherwise
                    levelStr = 'UNKNOWN';
                    colorStr = '*[0.5,0.5,0]';
            end

             
             
             
            % If necessary write to command window
            if( self.commandWindowLevel <= level )
                cprintf(colorStr, '[%s] ', levelStr);
                fprintf('%s:%s\n', scriptName, message);
            end
            
         end
        
    end
    
end

