--------------------------------------
-- Variables
--------------------------------------

local reminderInterval = 60; -- in minutes

local startTime = 0;
local timePlayed = 0;
local daysText = "-1";
local hoursText = "-1";
local minutesText = "-1";
local secondsText = "-1";
local isPlaying = false;
local useShortName = false;
local alreadyShown = false;
local Player = UnitName("Player");

local currentTime = -1;
local secondsPlayed = -1;
local minutesPlayed = -1;
local hoursPlayed = -1;
local daysPlayed = -1;

local debugging = false

--------------------------------------
-- Define App UI
--------------------------------------

local AppUI = CreateFrame("Frame", "TimePlayedFrame", UIParent, "BasicFrameTemplateWithInset");
AppUI:SetSize(400, 1); -- neither can be 0 or it won't render anymore
AppUI:SetPoint("CENTER", UIParent, "TOP", 0, -15);
AppUI.title = AppUI:CreateFontString(nil, "OVERLAY");
AppUI.title:SetFontObject("GameFontHighlight");
AppUI.title:SetPoint("CENTER", AppUI.TitleBg, "CENTER", 0, 0);
AppUI:Hide();

local Toast = CreateFrame("Frame");

--------------------------------------
-- Methods
--------------------------------------

local function UpdateData()
    currentTime = GetTime();
    timePlayed = math.floor(currentTime - startTime);

    secondsPlayed = timePlayed;
    minutesPlayed = math.floor(secondsPlayed / 60);
    hoursPlayed = math.floor(minutesPlayed / 60);
    daysPlayed = math.floor(hoursPlayed / 24);

    hoursPlayed = hoursPlayed % 24;
    minutesPlayed = minutesPlayed % 60;
    secondsPlayed = secondsPlayed % 60;
end

local function Debug()
    UpdateData();
    print("|cff00ccff----------------------------|cFFC0C0C0");
    print("currentTime: " .. currentTime);
    print("timePlayed: " .. timePlayed);
    print("hoursPlayed: " .. hoursPlayed);
    print("minutesPlayed: " .. minutesPlayed);
    print("secondsPlayed: " .. secondsPlayed);
    print("alreadyShown: " .. tostring(alreadyShown));
end

local function OnLogin()
    startTime = GetTime();
    isPlaying = true;
end

local function OnLogout()
    isPlaying = false;
end

local function defineTimeText()
    if useShortName then
        daysText = "d";
        hoursText = "h";
        minutesText = "m";
        secondsText = "s";
    else
        if daysPlayed == 1 then
            daysText = " day";
        else
            daysText = " days";
        end

        if hoursPlayed == 1 then
            hoursText = " hour";
        else
            hoursText = " hours";
        end

        if minutesPlayed == 1 then
            minutesText = " minute";
        else
            minutesText = " minutes";
        end

        if secondsPlayed == 1 then
            secondsText = " second";
        else
            secondsText = " seconds";
        end
    end
end

--------------------------------------
-- Update
--------------------------------------

local function _UpdateApp()
    if isPlaying then
        UpdateData();
        local displayText = "Time played this session: ";
        if daysPlayed > 0 then
            defineTimeText();
            displayText = displayText .. daysPlayed .. daysText .. ", " .. hoursPlayed .. hoursText .. ", " .. minutesPlayed .. minutesText;
        elseif hoursPlayed > 0 then
            defineTimeText();
            displayText = displayText .. hoursPlayed .. hoursText .. ", " .. minutesPlayed .. minutesText .. ", " .. secondsPlayed .. secondsText;
        elseif minutesPlayed > 0 then
            defineTimeText();
            displayText = displayText .. minutesPlayed .. minutesText .. ", " .. secondsPlayed .. secondsText;
        else
            defineTimeText();
            displayText = displayText .. secondsPlayed .. secondsText;
        end

        AppUI.title:SetText(displayText);
    end
end

local function UpdateApp()
    if isPlaying then
        local minutes = 0;
        if AppUI:IsVisible() then
            _UpdateApp();
        else
            currentTime = GetTime();
            minutes = math.floor((currentTime - startTime) / 60)
        end

        if minutes % reminderInterval == 0 and minutes ~= 0 and alreadyShown == false then
            alreadyShown = true;
            AppUI:SetShown(true);
        else
            if alreadyShown == true and minutes % reminderInterval ~= 0 then
                alreadyShown = false;
            end
        end
    end
end

--------------------------------------
-- Slash Command
--------------------------------------
SLASH_TIME_PLAYED1 = "/tp";
SLASH_TIME_PLAYED2 = "/timeplayed";
SlashCmdList.TIME_PLAYED = function()
    AppUI:SetShown(true);
    useShortName = false;
end

SLASH_TIME_PLAYED_SHORT1 = "/tps";
SLASH_TIME_PLAYED_SHORT2 = "/tpshort";
SlashCmdList.TIME_PLAYED_SHORT = function()
    AppUI:SetShown(true);
    useShortName = true;
end

SLASH_TIME_PLAYED_DEBUG1 = "/tpd";
SlashCmdList.TIME_PLAYED_DEBUG = function()
    if debugging then
        Debug();
    end
end

--------------------------------------
-- Functionality
--------------------------------------

print("|cff00ccffTimePlayed: |cFFC0C0C0Starting session timer for |cFF00FF00" .. Player .. "|cFFC0C0C0.");

AppUI:RegisterEvent("PLAYER_LOGIN")
AppUI:RegisterEvent("PLAYER_LOGOUT")
AppUI:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        OnLogin();
    elseif event == "PLAYER_LOGOUT" then
        OnLogout();
    end
end)

Toast:SetScript("OnUpdate", UpdateApp);