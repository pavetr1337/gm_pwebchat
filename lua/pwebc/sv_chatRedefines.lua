pwebc = pwebc or {}
util.AddNetworkString("pwebc.printchat")
local meta = FindMetaTable("Player")

function meta:ChatPrint(msg)
    net.Start("pwebc.printchat")
    net.WriteString(msg)
    net.Send(self)
end

concommand.Add("sv_chatPrint",function(ply)
    ply:ChatPrint("1221")
end)