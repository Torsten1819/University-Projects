function readhistory

global chatname;
global cipher;


hHistory = figure('Units','Pixels',...
                'Position', [500 200 400 500],...
                'MenuBar','none',...
                'ToolBar','none',...
                'Name', [chatname ' Chat History']);
            
p = uipanel(hHistory,'Position',[.02 .02 .96 .96]);



                
closePB = uicontrol(p,'Style','pushbutton',...
                    'String','close',...
                    'Units','normalized',...
                    'FontSize',10,...
                    'Callback',@closePB_callback,...
                    'Position',[.36 .016 .25 .07]);

               

chatboxTB = uicontrol(p,'Style','edit',...
                    'String','',...
                    'tag', 'histTB',...
                    'FontSize',10,...
                    'HorizontalAlignment','left',...
                    'Max', 2,...
                    'Units','normalized',...
                    'Position',[.01 .1 .98 .89]);
jEdit=findjobj(chatboxTB,'nomenu'); %get the UIScrollPane container
set(jEdit,'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED);
jEdit.anchorToBottom;
jEdit=jEdit.getComponent(0).getComponent(0);
set(jEdit,'Editable',0);

loadhistory;

    %takes the locally saves history file and decypts it to it's own gui to
    %be viewed
    function loadhistory
        handle.chat = findobj('tag', 'histTB');
        history = dlmread('history.csv');
        sized = size(history);
        
        for s = 1:sized(1)
                x = 1;
        
                for a = 1:sized(2)
                    history(s,a) = history(s,a) - cipher(x);
                    if mod(x, length(cipher)) == 0
                        x = 1;
                    else
                        x = x + 1;
                    end;
                end
        end
        
        history = char(history);
        set(handle.chat, 'String', history);
        
    end

    function closePB_callback(src, event)
        delete(gcf);
    end

end
