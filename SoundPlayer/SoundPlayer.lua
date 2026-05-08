SoundPlayerExe = SoundPlayerExe or {}
SoundPlayerExe.angle = SoundPlayerExe.angle or 45
local angle = SoundPlayerExe.angle
local radius = 80
local editBox
local frame
local dbFrame
local listening = false
local RefreshDatabase

local maxID = 18019 -- highest sound ID in 3.3.5a, but some are missing, so we might get blank ones when randomizing

if not SoundPlayerDB then
    SoundPlayerDB = {}
end

------------------------------------------------
------------------------------------------------
------------------------------------------------
-- Functions
------------------------------------------------
------------------------------------------------
------------------------------------------------

local function CleanPath(s)
    s = s:gsub("^%s*(.-)%s*$", "%1") -- trim
    s = s:gsub("[%c]", "")           -- control chars
    s = s:gsub("\\\\", "\\")         -- change double backslashes to single
    return s
end

local function ExtractPath(input)
    local path = input:match('"(.-)"')
    return path or input
end

local function IsValidSoundInput(str)
    if str:find("\\") then
        return true
    end

    local num = tonumber(str)
    if num and num >= 0 and num <= maxID and str:match("^%d+$") then
        return true
    end

    return false
end

local function PlaySoundExe(sound)

    sound = tostring(sound)

    if (tonumber(GetCVar("Sound_EnableSFX")) == 0) then
        print("|cffff0000SoundPlayer|r: Your sound is disabled.")
        return
    end

	if IsValidSoundInput(sound) then
        sound = ExtractPath(sound)
        sound = CleanPath(sound)
        local num = tonumber(sound)
        if num then
            PlaySound(num)
        else
            PlaySoundFile(sound)
        end
	else
		print("|cffff0000SoundPlayer|r: Invalid sound input.")
	end
end

local function StopAllSounds()
    AudioOptionsFrame_AudioRestart()
end

local function TriggerListening()
    listening = not listening
    if listening then
        if (tonumber(GetCVar("Sound_EnableSFX")) == 1) then
            PlaySoundFile("Sound\\Creature\\OrcMaleStandardNPC\\OrcMaleStandardNPCGreeting04.wav")  
        end
        print("|cff00ff00SoundPlayer|r: Party listening enabled")
    else
        if (tonumber(GetCVar("Sound_EnableSFX")) == 1) then
            PlaySoundFile("Sound\\Creature\\OrcMaleShadyNPC\\OrcMaleShadyNPCFarewell02.wav")
        end
        print("|cff00ff00SoundPlayer|r: Party listening disabled")
    end
end

local function AddToDB(id, desc)
    sound = tostring(id)
    if IsValidSoundInput(sound) then
    sound = ExtractPath(sound)
    sound = CleanPath(sound)
    local num = tonumber(sound)
    if num then
        table.insert(SoundPlayerDB,{
            type = "id",
            id = id,
            desc = desc
        })
    else
        table.insert(SoundPlayerDB,{
            type = "path",
            path = sound
        })
    end
	else
		print("|cffff0000SoundPlayer|r: Invalid sound input.")
	end

    if dbFrame and dbFrame:IsShown() and RefreshDatabase then
        RefreshDatabase()
    end
    return true
end

local function ToggleFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

local function toggleDBFrame()
    if dbFrame:IsShown() then
        dbFrame:Hide()
    else
        dbFrame:Show()
    end
end

local function PlayRandomSound()
    local id = math.random(3,maxID)
    PlaySoundExe(id)
    print("|cff00ff00SoundPlayer|r: Played sound ID:", id)
end

local function ReceiveSound(event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, channel, sender = ...
        if prefix ~= "SoundPlayerExe" then return end
        if not listening then return end
        if sender == UnitName("player") then return end
        if not IsValidSoundInput(msg) then return end
        msg = ExtractPath(msg)
        PlaySoundExe(msg)
        if (tonumber(GetCVar("Sound_EnableSFX")) == 1) then
            print("|cff00ff00SoundPlayer|r: |cffffff00" .. msg .. "|r from " .. sender)
        else
            print("|cffff0000SoundPlayer|r: Received sound (" .. msg .. ") from " .. sender .. " but your sound is disabled")
        end
        return
    end

    local msg, author = ...
    if not listening then return end
    if author == UnitName("player") then return end
    if not IsValidSoundInput(msg) then return end
    msg = ExtractPath(msg)
    PlaySoundExe(msg)
            if (tonumber(GetCVar("Sound_EnableSFX")) == 1) then
            print("|cff00ff00SoundPlayer|r: |cffffff00" .. msg .. "|r from " .. author)
        else
            print("|cffff0000SoundPlayer|r: Received sound (" .. msg .. ") from " .. author .. " but your sound is disabled")
        end
end

------------------------------------------------
------------------------------------------------
------------------------------------------------
-- Database Window
------------------------------------------------
------------------------------------------------
------------------------------------------------

dbFrame = CreateFrame("Frame", "SoundPlayerDBWindow", UIParent, "UIPanelDialogTemplate")
dbFrame:SetSize(350, 550)
dbFrame:SetPoint("CENTER")
dbFrame:Hide()
dbFrame:SetMovable(true)
dbFrame:EnableMouse(true)
dbFrame:RegisterForDrag("LeftButton")

dbFrame:SetScript("OnHide", function()
    PlaySound(680)
end)

-- resizing is buggy and fuck it for now

-- dbFrame:SetResizable(true)

-- local MIN_HEIGHT = 200
-- local MAX_HEIGHT = 700

-- local resizeButton = CreateFrame("Button", nil, dbFrame)
-- resizeButton:SetPoint("BOTTOMRIGHT", dbFrame, "BOTTOMRIGHT", -5, 5)
-- resizeButton:SetSize(16,16)
-- resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
-- resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
-- resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

-- resizeButton:SetScript("OnMouseDown", function(self)
--     dbFrame:StartSizing("BOTTOM")
-- end)

-- resizeButton:SetScript("OnMouseUp", function(self)
--     dbFrame:StopMovingOrSizing()
--     local w, h = dbFrame:GetSize()
--     if h < MIN_HEIGHT then h = MIN_HEIGHT end
--     if h > MAX_HEIGHT then h = MAX_HEIGHT end
--     dbFrame:SetSize(w, h)
--     if UpdateContentHeight then
--         UpdateContentHeight()
--     end
-- end)

dbFrame.title = dbFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dbFrame.title:SetPoint("TOP", dbFrame, "TOP", 0, -10)
dbFrame.title:SetText(UnitName("player").."'s Database")
dbFrame.title:SetTextColor(1, 1, 0)
dbFrame.title:SetFont(dbFrame.title:GetFont(), 14)

tinsert(UISpecialFrames, "SoundPlayerDBWindow")

dbFrame:SetScript("OnDragStart", dbFrame.StartMoving)
dbFrame:SetScript("OnDragStop", dbFrame.StopMovingOrSizing)

local scrollFrame = CreateFrame("ScrollFrame", "ScrollDB", dbFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1,1)

scrollFrame:SetScrollChild(content)

local function UpdateContentHeight()
    local rowHeight = 32
    local numRows = #SoundPlayerDB
    content:SetHeight(numRows * rowHeight)
end

local rows = {}
local COL_ID = 3
local COL_DESC = 50
local COL_PLAY = 255
local COL_DELETE = 285

local function CreateRow(index)

    local row = CreateFrame("Frame", nil, content)
    row:SetSize(280, 30)
    row:SetPoint("TOPLEFT", 0, -(index-1)*32)

    rows[index] = row
    
    -- ID
    row.idText = row:CreateFontString(nil,"OVERLAY","GameFontNormal")
    row.idText:SetPoint("LEFT", row, "LEFT", COL_ID, 0)

    row.idClick = CreateFrame("Button", nil, row)
    row.idClick:SetPoint("TOPLEFT", row.idText, "TOPLEFT")
    row.idClick:SetPoint("BOTTOMRIGHT", row.idText, "BOTTOMRIGHT")

    row.idClick:RegisterForClicks("LeftButtonUp")

    row.idClick:SetScript("OnClick", function()
        editBox:SetText(row.idText:GetText())
    end)

    row.idClick:SetScript("OnEnter", function()
        row.idText:SetTextColor(0.3, 0.3, 1)
    end)

    row.idClick:SetScript("OnLeave", function()
        row.idText:SetTextColor(1, 0.8, 0)
    end)

    -- desc
    row.desc = CreateFrame("EditBox", nil, row)
    row.desc:SetSize(200, 20)
    row.desc:SetPoint("LEFT", row, "LEFT", COL_DESC, 0)
    row.desc:SetAutoFocus(false)
    row.desc:SetFontObject(GameFontNormal)
    row.desc:SetTextInsets(2,2,0,0)
    row.desc:SetMultiLine(false)
    row.desc:SetScript("OnTextChanged", function(self)
        data.desc = self:GetText()
    end)
    row.desc:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    row.desc:SetBackdropColor(0,0,0,0.5)

    row.desc:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- PLAY
    row.play = CreateFrame("Button", nil, row)
    row.play:SetSize(25,25)
    row.play:SetPoint("LEFT", row, "LEFT", COL_PLAY, 0)
    row.play:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    local icon = row.play:CreateTexture(nil,"BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")


    -- DELETE
    row.delete = CreateFrame("Button", nil, row)
    row.delete:SetSize(20,20)
    row.delete:SetPoint("LEFT", row, "LEFT", COL_DELETE, 0)
    row.delete:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    local xicon = row.delete:CreateTexture(nil,"BACKGROUND")
    xicon:SetAllPoints()
    xicon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

end

RefreshDatabase = function()

    UpdateContentHeight()

    for i,row in ipairs(rows) do
        row:Hide()
    end

    for i,data in ipairs(SoundPlayerDB) do

        if not rows[i] then
            CreateRow(i)
        end

        local row = rows[i]
        row:Show()

        -- TYPE CHECK
        if data.type == "path" then

            -- PATH RECORD
            local filename = data.path:match("[^\\]+$")
            row.idText:SetText(filename)
            row.idText:SetWidth(240)
            row.idText:SetFont("Fonts\\FRIZQT__.TTF", 10)
            row.idText:SetJustifyH("LEFT")
            row.idText:SetNonSpaceWrap(false)
            row.desc:Hide()

            -- PLAY PATH
            row.play:SetScript("OnClick", function()
                PlaySoundFile(data.path)
            end)

            -- CLICK PATH
            row.idClick:SetScript("OnClick", function()
                editBox:SetText(data.path or "")
            end)

        else

            -- ID RECORD
            row.idText:SetText(data.id)

            row.desc:Show()
            row.desc:SetText(data.desc or "")

            -- PLAY ID
            row.play:SetScript("OnClick", function()
                PlaySoundExe(data.id)
            end)

            -- EDIT DESC
            row.desc:SetScript("OnTextChanged", function(self)
                data.desc = self:GetText()
            end)

            -- CLICK ID
            row.idClick:SetScript("OnClick", function()
                editBox:SetText(row.idText:GetText())
            end)

        end

        -- DELETE
        row.delete:SetScript("OnClick", function()

    table.remove(SoundPlayerDB, i)

    if data.type == "path" then
        print("|cff00ff00SoundPlayer|r: Deleted path", data.path)
    else
        print("|cff00ff00SoundPlayer|r: Deleted sound ID", data.id, data.desc ~= "" and ("("..data.desc..")") or "")
    end

    RefreshDatabase()

end)

    end

end

dbFrame:SetScript("OnShow", function()
    PlaySound(681)  
    RefreshDatabase()
end)

------------------------------------------------
------------------------------------------------
------------------------------------------------
-- Sound Player Window
------------------------------------------------
------------------------------------------------
------------------------------------------------

frame = CreateFrame("Frame", "SoundPlayerWindow", UIParent, "UIPanelDialogTemplate")
frame:SetSize(300, 150)
frame:SetPoint("CENTER")
frame:Hide()
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnHide", function()
    PlaySound(680)
end)

frame:SetScript("OnShow", function()
    PlaySound(681)
end)

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
frame.title:SetPoint("TOP", frame, "TOP", 0, -10) 
frame.title:SetText("Sound Player") 
frame.title:SetTextColor(1, 1, 0) 
frame.title:SetFont(frame.title:GetFont(), 14)

local helpBtn = CreateFrame("Button", nil, frame)
helpBtn:SetSize(22,22)
helpBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)

-- tooltip
helpBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Sound Player v1.3")
    GameTooltip:AddLine("Play sounds by ID or Path", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Made by Exewin in 2026", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Testing: Gedrikh", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

helpBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


tinsert(UISpecialFrames, "SoundPlayerWindow")

frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
editBox:SetSize(180,30)
editBox:SetPoint("CENTER", frame, "CENTER", 0, 0)
editBox:SetAutoFocus(false)
editBox:SetText("")

local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
label:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 0, 2)
label:SetText("Type id (e.g. 12831)")
label:SetTextColor(1,1,1)

local confirm = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
confirm:SetSize(80,30)
confirm:SetPoint("BOTTOM", frame, "BOTTOM", -40, 20)
confirm:SetText("PLAY")
confirm:SetScript("OnClick", function()
    SendAddonMessage("SoundPlayerExe", editBox:GetText(), "PARTY", UnitName("player"))
    PlaySoundExe(editBox:GetText())
end)

editBox:SetScript("OnEnterPressed", function(self)
    confirm:Click()
end)

local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addButton:SetSize(80,30)
addButton:SetPoint("BOTTOM", frame, "BOTTOM", 40, 20)
addButton:SetText("Add to DB")
addButton:SetScript("OnClick", function()

    AddToDB(editBox:GetText(), "")
    RefreshDatabase()

end)



------------------------------------------------
-- RANDOM BUTTON
------------------------------------------------

local randomButton = CreateFrame("Button", nil, frame)
randomButton:SetSize(30, 30)
randomButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
randomButton:EnableMouse(true)

local icon = randomButton:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
local itemID = 36862
icon:SetTexture(GetItemIcon(itemID))

randomButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

randomButton:SetScript("OnClick", function()
    PlayRandomSound()
end)


randomButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Random")
    GameTooltip:AddLine("- can sometimes randomize blank sounds", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

randomButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


------------------------------------------------
-- STOP SOUND BUTTON
------------------------------------------------

local stopButton = CreateFrame("Button", nil, frame)
stopButton:SetSize(30, 30)
stopButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 45)
stopButton:EnableMouse(true)

local icon = stopButton:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
local itemID = 44301
icon:SetTexture(GetItemIcon(itemID))

stopButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

stopButton:SetScript("OnClick", function()
	StopAllSounds()
end)


stopButton:SetScript("OnEnter", function(self)

    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Stop All Sounds")
    GameTooltip:AddLine("- will freeze game for a second", 0.7, 0.7, 0.7)
    GameTooltip:Show()

end)

stopButton:SetScript("OnLeave", function()

    GameTooltip:Hide()

end)


------------------------------------------------
-- LISTEN BUTTON
------------------------------------------------

local pulse = 0
local listenerFrame = CreateFrame("Frame")
listenerFrame:RegisterEvent("CHAT_MSG_ADDON")
listenerFrame:RegisterEvent("CHAT_MSG_PARTY")
listenerFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
listenerFrame:SetScript("OnEvent", function(self, event, ...)
    ReceiveSound(event, ...)
end)

local listenButton = CreateFrame("Button", nil, frame)
listenButton:SetSize(30, 30)
listenButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 80)
listenButton:EnableMouse(true)

local icon = listenButton:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
local itemID = 3110
icon:SetTexture(GetItemIcon(itemID))


listenButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

listenButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Listen to sounds")
    GameTooltip:AddLine("- doesn't work with random sounds", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("- doesn't work with sounds from DB", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("- works with PLAY button", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("- works with /sp command", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("- works with party messages", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

listenButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


listenButton:SetScript("OnClick", function(self)
    TriggerListening()
end)

local glow = listenButton:CreateTexture(nil, "OVERLAY")
glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
glow:SetBlendMode("ADD")
glow:SetPoint("CENTER", listenButton, "CENTER")
glow:SetSize(52, 52)
glow:SetAlpha(0)

listenButton:SetScript("OnUpdate", function(self, elapsed)
    if not listening then
        glow:SetAlpha(0)
        return
    end
    pulse = pulse + elapsed * 3
    local alpha = 0.5 + math.sin(pulse) * 0.5
    glow:SetAlpha(alpha)
end)



------------------------------------------------
-- DATABASE BUTTON
------------------------------------------------

local dbButton = CreateFrame("Button", nil, frame)
dbButton:SetSize(30, 30)
dbButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 10)
dbButton:EnableMouse(true)

local icon = dbButton:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
local itemID = 22719
icon:SetTexture(GetItemIcon(itemID))

dbButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

dbButton:SetScript("OnClick", function()
	toggleDBFrame()
end)


dbButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:SetText("Open your database")
    GameTooltip:Show()
end)

dbButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)



------------------------------------------------
------------------------------------------------
------------------------------------------------
-- Commands
------------------------------------------------
------------------------------------------------
------------------------------------------------


SLASH_SOUNDPLAYER1 = "/sp"

SlashCmdList["SOUNDPLAYER"] = function(msg)

    msg = msg:trim():lower()

    if msg == "" then
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
        return
    end

    local addCmd, rest = msg:match("^(%S+)%s*(.*)$")
    if addCmd == "add" and rest ~= "" then
        local idStr, desc = rest:match("^(%S+)%s*(.*)$")

        if AddToDB(idStr, desc) then
            print("|cff00ff00SoundPlayer|r: Added ID "..idStr..(desc ~= "" and (" ("..desc..")") or ""))
        end

        return
    end

    -- db play / delete
    local cmd, rest = msg:match("^(%S+)%s*(.*)$")

    -- /sp db - toggle db window
    if cmd == "db" and (rest == nil or rest == "") then
        if dbFrame then
            toggleDBFrame()
        end
        return
    end

    -- /sp db <index>
    if cmd == "db" and rest ~= "" then
        local index = tonumber(rest)

        if not index or not SoundPlayerDB[index] then
            print("|cffff0000SoundPlayer|r: Invalid DB index")
            return
        end

        local entry = SoundPlayerDB[index]
        PlaySoundExe(entry.id)

        print("|cff00ff00SoundPlayer|r: Playing DB["..index.."]", entry.id, entry.desc ~= "" and ("("..entry.desc..")") or "")
        return
    end

    -- /sp del <index>
    if cmd == "del" and rest ~= "" then
        local index = tonumber(rest)

        if not index or not SoundPlayerDB[index] then
            print("|cffff0000SoundPlayer|r: Invalid DB index")
            return
        end

        local removed = SoundPlayerDB[index]
        table.remove(SoundPlayerDB, index)

        if RefreshDatabase then
            RefreshDatabase()
        end

        print("|cff00ff00SoundPlayer|r: Removed DB["..index.."]", removed.id, removed.desc ~= "" and ("("..removed.desc..")") or "")
        return
    end

    -- random sound
    if msg == "rand" then
        PlayRandomSound()
        return
    end

    -- listen ON/OFF
    if msg == "listen" then
        TriggerListening()
        return
    end

    -- stop all sounds
    if msg == "stop" then
        StopAllSounds()
        return
    end

    -- help
    if msg == "help" then
        print("|cff00ff00SoundPlayer|r Commands:")
        print("/sp - toggle SoundPlayer window")
        print("/sp <id> - play sound")
        print("/sp rand - random sound")
        print("/sp listen - listen on/off party")
        print("/sp stop - stop all sounds")
        print("/sp add <id> <desc> - add new record to database (desc optional)")
        print("/sp db - toggle database window")
        print("/sp db <index> - play sound from database")
        print("/sp del <index> - delete sound from database")
        return
    end

    -- play specific sound
    if msg then
        SendAddonMessage("SoundPlayerExe", msg, "PARTY", UnitName("player"))
        PlaySoundExe(msg)
    end
end

------------------------------------------------
------------------------------------------------
------------------------------------------------
-- MINIMAP ICON
------------------------------------------------
------------------------------------------------
------------------------------------------------

local addon = CreateFrame("Button", "MinimapButton", Minimap)
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetSize(32,32)
addon:SetFrameStrata("MEDIUM")
addon:EnableMouse(true)
addon:RegisterForClicks("LeftButtonUp","RightButtonUp")
addon:RegisterForDrag("LeftButton")

-- icon texture
local icon = addon:CreateTexture(nil,"BACKGROUND")
local itemID = 40865
icon:SetTexture(GetItemIcon(itemID))
icon:SetPoint("TOPLEFT", addon, "TOPLEFT", 6, -6)
icon:SetPoint("BOTTOMRIGHT", addon, "BOTTOMRIGHT", -6, 6)
icon:SetTexCoord(0.07,0.93,0.07,0.93)

--minimap button border
local border = addon:CreateTexture(nil,"OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(54,54)
border:SetPoint("TOPLEFT",0,0)

-- highlight
addon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

------------------------------------------------
-- Position function
------------------------------------------------

local function UpdatePosition()

    local x = math.cos(math.rad(angle)) * radius
    local y = math.sin(math.rad(angle)) * radius

    addon:ClearAllPoints()
    addon:SetPoint("CENTER",Minimap,"CENTER",x,y)

end

UpdatePosition()

addon:SetScript("OnEvent", function()

    SoundPlayerExe = SoundPlayerExe or {}
    angle = SoundPlayerExe.angle or 45

    UpdatePosition()

end)

------------------------------------------------
-- Dragging
------------------------------------------------

addon:SetScript("OnDragStart", function(self)

    self:SetScript("OnUpdate", function()

        local mx,my = Minimap:GetCenter()
        local px,py = GetCursorPosition()
        local scale = UIParent:GetScale()

        px = px / scale
        py = py / scale

        local dx = px - mx
        local dy = py - my

        angle = math.deg(math.atan2(dy,dx)) % 360
        SoundPlayerExe.angle = angle

        UpdatePosition()

    end)

end)

addon:SetScript("OnDragStop", function(self)

    self:SetScript("OnUpdate", nil)

end)

------------------------------------------------
-- Tooltip
------------------------------------------------

addon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:SetText("Sound Player")
    GameTooltip:AddLine("Left Click: Toggle",1,1,1)
    GameTooltip:AddLine("Type '/sp help' for commands",1,1,1)
    GameTooltip:Show()
end)

addon:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

------------------------------------------------
-- Click
------------------------------------------------

addon:SetScript("OnClick", function(self,button)
    if button == "LeftButton" then
        ToggleFrame()
    end
end)