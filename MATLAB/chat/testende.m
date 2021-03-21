function maintest
global entered;
global outgoing;
global key;

global asciiplain;

hPass = figure('Units','Pixels',...
                'Position', [500 200 350 300],...
                'MenuBar','none',...
                'ToolBar','none',...
                'Resize', 'off',...
                'Name', 'Enter the Password');
            
p = uipanel(hPass,'Position',[.02 .02 .96 .96]);
%%%initalizing uicontrols

enPB = uicontrol(p,'Style','pushbutton',...
                    'String','Encrypt',...
                    'Units','normalized',...
                    'Callback', @encrypt_Callback,...
                    'Position',[.05 .05 .35 .12]);
                
dePB = uicontrol(p,'Style','pushbutton',...
                    'String','Decrypt',...
                    'Units','normalized',...
                    'Callback', @decrypt_Callback,...
                    'Position',[.6 .05 .35 .12]);
                
promptST = uicontrol(p,'Style','text',...
                    'String','Key:',...
                    'FontSize',12,...
                    'Units','normalized',...
                    'Position',[.0 .425 .6 .2]);
                
passTB = uicontrol(p,'Style','edit',...
                    'String','The Key',...
                    'Units','normalized',...
                    'tag', 'key',...
                    'Position',[.38 .52 .4 .12]);
plainTB = uicontrol(p,'Style','edit',...
                    'String','Hello World',...
                    'Units','normalized',...
                    'tag', 'entered',...
                    'Position',[.05 .75 .9 .12]);
            
encryptTB = uicontrol(p,'Style','edit',...
                    'String','',...
                    'Units','normalized',...
                    'tag','outgoing',...
                    'Position',[.05 .3 .9 .12]);
%%%end uicontrol initalization

    function encrypt_Callback(src, event)
        hkey = findobj('tag', 'key');
        key = get(hkey, 'String');
        hentered = findobj('tag', 'entered');
        entered = get(hentered, 'String');
        houtgoing = findobj('tag', 'outgoing');
        
        asciikey = double(key);
        %fixedkey = [];
        asciiplain = double(entered);
        %%%offset the key so that only text characters are used
        i = 1;
       % for b = 1:length(asciikey)
        %    if asciikey(b) > 64 && asciikey(b) < 91
               
         %      fixedkey = horzcat(fixedkey, asciikey(b) - 65)
         %      i = i +1;
         %   elseif asciikey(b) > 96 && asciikey(b) < 123
         %       fixedkey = horzcat(fixedkey, asciikey(b) - 97);
         %       i = i+1;
         %   end;
        %end
        
        for b = 1:length(asciikey)
            asciikey(b) = asciikey(b) - 32;
        end

        x = 1;
        for a = 1:length(entered)
            
                asciiplain(a) = asciiplain(a) + asciikey(x);
            if mod(x, length(asciikey)) == 0
                x = 1;
            else
                x = x + 1;
            end;
        end
        
        %csvwrite('csvlist.csv',asciiplain);
        save('test.mat', 'asciiplain');
        dlmwrite('csvlist.csv',asciiplain,'-append')
        
        outgoing = char(asciiplain);
        set(houtgoing, 'String', outgoing);
    end

 function decrypt_Callback(src, event)
        hkey = findobj('tag', 'key');
        key = get(hkey, 'String');
        hentered = findobj('tag', 'entered');
        entered = get(hentered, 'String');
        houtgoing = findobj('tag', 'outgoing');
        
        M = csvread('csvlist.csv');
        asciikey = double(key);
        %fixedkey = [];
        %asciiplain = double(entered);
        %%%offset the key so that only text characters are used
        i = 1;
       % for b = 1:length(asciikey)
        %    if asciikey(b) > 64 && asciikey(b) < 91
               
         %      fixedkey = horzcat(fixedkey, asciikey(b) - 65)
         %      i = i +1;
         %   elseif asciikey(b) > 96 && asciikey(b) < 123
         %       fixedkey = horzcat(fixedkey, asciikey(b) - 97);
         %       i = i+1;
         %   end;
        %end
        
        for b = 1:length(asciikey)
            asciikey(b) = asciikey(b) - 32;
        end
            
        x = 1;
        for a = 1:length(M)
            
                %if asciiplain(a) > 57 
                %    asciiplain(a) = asciiplain(a) - fixedkey(x);
                %elseif asciiplain(a) > 47 && asciiplain(a) < 58
                %    asciiplain(a) = asciiplain(a) - 27;
                %end
                M(a) = M(a) - asciikey(x);
            if mod(x, length(asciikey)) == 0
                x = 1;
            else
                x = x + 1;
            end;
        end
                disp(M);
        outgoing = char(M);
        set(houtgoing, 'String', outgoing);
    end
 end

