pwebc = pwebc or {} -- Dont touch
pwebc.chatW = 600 -- Chat width in px. 1920 is 100%
pwebc.chatH = 350 -- Chat height in px. 1080 is 100%

pwebc.chatPad = 25 -- Chat padding relative to  bottom-left corner

pwebc.colors = { -- Colors
    frameBg = Color(59, 59, 59), -- Background of chat frame
    textEntry = Color(85, 85, 85), -- Backgound of chat entry
    messageHover = Color(0,0,0,50), -- Background of hovered messages
    textColor = Color(255, 255, 255), -- Text color

    prefix = { -- Prefix colors
        red = Color(255, 0, 0), -- Red
        yellow = Color(255, 255, 0), -- Yellow
    }
}

pwebc.blacklistedTags = { -- HTML tags that restricted
    "a",
    "script"
}

pwebc.prefixes = { -- Prefixes table
    server = { -- Prefix key in code
        prefix = "Server", -- Prefix text
        prefixCol = pwebc.colors.prefix.red, -- Prefix color
    },
}