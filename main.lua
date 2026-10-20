--- A simple plugin that uses voice snippets of Azzanadra to make fun of you.

--Store player object reference and flags for having surged
local playerObj = PlayerList.Self()
local bonkBank = require("bonklines")
local lastTick = false
local surgeTick = false
local surgePos = playerObj.coordGrid

---Function to play a voice line after surging 1 tile
local function bonkLine()
    --Get random index
    local arrLen = #bonkBank
    local randID = math.random(arrLen)
    --BM the player with audacious sarcasm
    audio.Play(bonkBank[randID])
end

---Function to check for surging a single tile
local function getBonked()
    local pos = playerObj.coordGrid
    --Get abs of differences in X and Y coords
    local xComp = math.abs(surgePos.localX - pos.localX)
    local yComp = math.abs(surgePos.localZ - pos.localZ)
    --Check if position diff is 1 tile or less
    if (xComp <= 1) and (yComp <= 1) then
        bonkLine()
    end
    --Unsub from event started in abil tracker
    Event.ServerLogic.Unsubscribe("surgeTicker")
end

---Function that checks for last used ability to be reso or a movement ability
Event.VarTransmit.Subscribe("surgeChecker", function(varTransmitEvent)
    --Store varTransmitEvent name and check if its for last ability used.
    local varName = varTransmitEvent.var.configName
    if varName ~= "COMBATV2_JUST_USED_ABILITY" then
        --Early return if not correct var
        return
    end
    --Check if last used abil was a movement ability
    for i, val in ipairs({14726, 14665, 1488, 47129}) do
        if varTransmitEvent.newValue == val then
            --Set member vars 
            surgeTick = lastTick
            surgePos = playerObj.coordGrid
            --Use server tick rate to modulate comparison call
            Event.ServerLogic.Subscribe("surgeTicker", function()
                if surgeTick ~= lastTick then
                    getBonked()
                    return
                end
            end)
            break
        end
    end
end)

---Track each tick through bool to act as psuedo delay for position comparison
Event.ServerLogic.Subscribe("tickFlip", function()
    if lastTick then
        lastTick = false
    else
        lastTick = true
    end
end)
