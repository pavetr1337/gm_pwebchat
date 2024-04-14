pwebc = pwebc or {}

-- Fonts
surface.CreateFont("pwebc.chatEntry", {
	font = "Arial",
	extended = true,
	size = 18,
	weight = 500,
	antialias = true,
})

-- Hide Defaults
hook.Add("StartChat", "pwebc.hideKeybind", function()
	return true
end)

hook.Add("HUDShouldDraw", "pwebc.hideChatBox", function(name)
	if name == "CHudChat" then
		return false
	end
end)

-- Helpers
local ScrW, ScrH = ScrW, ScrH

function pwebc.screenSize(px,isHeight)
    if isHeight then
        return (ScrH()/1080)*px
    else
        return (ScrW()/1920)*px
    end
end

function pwebc.colorToHTML(clr)
    local r,g,b,a = clr:Unpack()
    return string.format("rgba(%i,%i,%i,%G)",r,g,b,a/255)
end

function pwebc.invertColor(color)
    return Color(255 - color.r, 255 - color.g, 255 - color.b, color.a)
end


-- Frames
function pwebc.initChatbox()
    pwebc.chatFrame = vgui.Create("DFrame")
    pwebc.chatFrame:SetSize(pwebc.screenSize(pwebc.chatW),pwebc.screenSize(pwebc.chatH,true))
    pwebc.chatFrame:SetPos(pwebc.screenSize(pwebc.chatPad),ScrH()-pwebc.screenSize(pwebc.chatH)-pwebc.screenSize(pwebc.chatPad))
    pwebc.chatFrame:ShowCloseButton(false)
    pwebc.chatFrame:SetTitle("")
    pwebc.chatFrame.Paint = function(s,w,h)
    end

    pwebc.chatBox = vgui.Create("DHTML",pwebc.chatFrame)

    pwebc.chatBox:Dock(FILL)
    pwebc.chatBox:SetHTML([[
        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document</title>
            <style>
                .chatPrefix {
                    background-color: yellow;
                    border: 5px solid transparent;
                    border-radius: 20px;
                    text-transform: uppercase;
                    margin-right: 5px;
                    font-weight: bold;
                }
                img {
                    height: 100%;
                    width: auto;
                }
            </style>
        </head>
        <body>
            <!--<p class='chatText'><span class='chatPrefix'>1221</span>ChatText</p>-->
        </body>
        </html>
    ]])
    pwebc.chatBox:SetAllowLua(true)
    pwebc.chatBox.OnDocumentReady = function(url)
        pwebc.chatBox:RunJavascript(string.format([[
        var style = document.createElement('style');
        style.innerHTML = 'body { background-color: %s; } .chatText:hover {background-color: %s;} * { font-family: Arial, Helvetica, sans-serif; color: %s; }';
        document.head.appendChild(style);
        ]],pwebc.colorToHTML(pwebc.colors.frameBg),pwebc.colorToHTML(pwebc.colors.messageHover),pwebc.colorToHTML(pwebc.colors.textColor)))
    end

    pwebc.chatInput = vgui.Create("DTextEntry",pwebc.chatFrame)
    pwebc.chatInput:Dock(BOTTOM)
    pwebc.chatInput:SetFont("pwebc.chatEntry")
    pwebc.chatInput.Paint = function(s,w,h)
        surface.SetDrawColor(pwebc.colors.textEntry)
        surface.DrawRect(0,0,w,h)
    end
    pwebc.chatInput:SetDrawLanguageID(false)

    pwebc.chatInput.PaintOver = function(w,h)
        pwebc.chatInput:DrawTextEntryText(pwebc.colors.textColor,pwebc.invertColor(pwebc.colors.textColor),pwebc.colors.textColor)
    end

    pwebc.chatInput.OnKeyCodeTyped = function( self, code )
        if code == KEY_ESCAPE then
            pwebc.closeChatbox()
            gui.HideGameUI()
        elseif code == KEY_ENTER then
            if string.Trim( self:GetText() ) != "" then
                LocalPlayer():ConCommand( "say " .. self:GetText() )
            end
            pwebc.closeChatbox()
        end
    end
end

function pwebc.removeChatbox()
    if ValidPanel(pwebc.chatFrame) then
        pwebc.chatFrame:Remove()
    end
    if ValidPanel(pwebc.chatBox) then
        pwebc.chatBox:Remove()
    end
    if ValidPanel(pwebc.chatInput) then
        pwebc.chatInput:Remove()
    end
end

-- Functions
function pwebc.InsertText(...)
    local args = {...}
    if ValidPanel(pwebc.chatBox) then
        local endCode = ""

        for _, obj in ipairs(args) do
            if type(obj) == "string" then
                if string.Left(endCode,3) == "<span " or string.Right(endCode,7) == "</span>" or string.Right(endCode,3) == ';">' then
                    endCode = endCode .. " " .. obj .. "</span>"
                else
                    endCode = endCode .. "<span>" .. obj .. "</span>"
                end
            elseif obj and IsValid(obj) and obj:IsPlayer() then
                local col = GAMEMODE:GetTeamColor(obj)
                endCode = endCode .. string.format([[<span><span style="color: %s;">%s</span>: </span>]],pwebc.colorToHTML(col),obj:Nick())
            elseif type(obj) == "table" then
                if obj.prefix and obj.prefixCol then
                    endCode = "<span>"..endCode .. string.format([[<span class="chatPrefix" style="background-color:%s;">%s</span>]],pwebc.colorToHTML(obj.prefixCol),obj.prefix)
                end
                if obj.r and obj.g and obj.b then
                    endCode = endCode .. string.format([[<span style="color: %s;">]],pwebc.colorToHTML(Color(obj.r, obj.g, obj.b)))
                end
            end
        end

        local minCode = string.lower(string.Replace(endCode," ",""))
        for z,tag in ipairs(pwebc.blacklistedTags) do
            if string.match(minCode,"<"..tag) then
                endCode = string.format("[Restricted Tag %s]",tag)
            end
        end

        pwebc.chatBox:RunJavascript(string.format([[
            var txt = document.createElement("p");
            txt.style["vertical-align"] = "middle";
            txt.classList.add("chatText");
            txt.innerHTML = '%s';
            window.document.body.insertBefore(txt, window.document.body.nextSibling);
            window.scrollTo(0, document.body.scrollHeight);
        ]],endCode))
    end
end

function pwebc.openChatbox()
	pwebc.chatFrame:MakePopup()
	pwebc.chatInput:RequestFocus()
	hook.Run( "StartChat" )
end

function pwebc.closeChatbox()
	pwebc.chatFrame:SetMouseInputEnabled( false )
	pwebc.chatFrame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	
	hook.Run( "FinishChat" )
	
	pwebc.chatInput:SetText( "" )
	hook.Run( "ChatTextChanged", "" )
end

local oldAddText = chat.AddText
function chat.AddText( ... )
	pwebc.InsertText(...)
end

hook.Add("PlayerBindPress", "pwebc.overrideChatBind", function( ply, bind, pressed )
    local bTeam = false
    if bind == "messagemode" then
    elseif bind == "messagemode2" then
        bTeam = true
    else
        return
    end
    pwebc.openChatbox(bTeam)
    return true
end)

timer.Simple(0.5,function()
    pwebc.initChatbox()
end)



-- DEBUG
concommand.Add("refreshChatbox",function()
    pwebc.removeChatbox()
    pwebc.initChatbox()
end)

concommand.Add("printChat",function()
    chat.AddText("This is a test text")
    chat.AddText(Color(255,0,0),"Red text")

    chat.AddText({prefix="Server",prefixCol=Color(255,0,0)},"It have prefix")

    chat.AddText({prefix="Test",prefixCol=Color(255,255,0)},"All",Color(255,0,0),"in",Color(0,255,0),"one")

    chat.AddText([[<a href="https://google.com">Restricted tag</a>]])

    chat.AddText(LocalPlayer(),"Player chat")
end)

-- NET
net.Receive("pwebc.printchat",function()
    local txt = net.ReadString()
    chat.AddText(pwebc.prefixes.server,txt)
end)