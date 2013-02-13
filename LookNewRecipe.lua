defaultVars = {
  PlaySounds = true,
  AlertIfUnusable = true
}

LookNewRecipe_Settings = {}

LookNewRecipe = {}

-- Frame Events

function LookNewRecipeDrawer_OnLoad(self)
  -- Tab Handling code
  PanelTemplates_SetNumTabs(self, 2);
  LookNewRecipeDrawer_UpdateTabs(0, 0)
end

function LookNewRecipeDrawer_OnShow()
end

function LookNewRecipeDrawer_UpdateTabs(allRecipeCount, newRecipeCount)
  -- Handle all recipes
  if allRecipeCount > 0 then
    LookNewRecipeDrawerTab2:SetText("All ("..allRecipeCount..")")
    PanelTemplates_EnableTab(LookNewRecipeDrawer, 2)
    PanelTemplates_SetTab(LookNewRecipeDrawer, 2);
  else
    LookNewRecipeDrawerTab2:SetText("All")
    PanelTemplates_DisableTab(LookNewRecipeDrawer, 2)
    PanelTemplates_DeselectTab(LookNewRecipeDrawerTab2)
  end

  -- Handle new recipes
  if newRecipeCount > 0 then
    LookNewRecipeDrawerTab1:SetText("New ("..newRecipeCount..")")
    PanelTemplates_EnableTab(LookNewRecipeDrawer, 1)
    PanelTemplates_SetTab(LookNewRecipeDrawer, 1);
  else
    LookNewRecipeDrawerTab1:SetText("New")
    PanelTemplates_DisableTab(LookNewRecipeDrawer, 1)
    PanelTemplates_DeselectTab(LookNewRecipeDrawerTab1)
  end

  -- Update the tabs
  PanelTemplates_UpdateTabs(LookNewRecipeDrawer)

end

-- Function declaration.
local onEvent, checkMerchantInventory, isItemAlreadyKnown

-- Scanning Tooltip
local AlreadyKnownTooltip = CreateFrame('GameTooltip', 'AlreadyKnownTooltip', UIParent, 'GameTooltipTemplate')

-- Scan again?
local scanSuccessful

function checkMerchantInventory()
  local itemCount = GetMerchantNumItems()
  local recipeCount = 0
  local usableCount = 0
  local knownCount = 0
  for i=1,itemCount do
    -- Our current item.
    local currentItem = GetMerchantItemLink(i)
    if (currentItem == nil) then
      scanSuccessful = false
      return
    end
    
    -- Get assorted information about the item.
    local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(currentItem)
    local mName, mTexture, mPrice, mQuantity, mNumAvailable, mIsUsable, mExtendedCost = GetMerchantItemInfo(i)
    
    if (class == "Recipe") then
      recipeCount = recipeCount + 1

      -- Get usability information about the item
      if mIsUsable then
        if isItemAlreadyKnown(currentItem) then
          knownCount = knownCount + 1
        else
          usableCount = usableCount + 1
          print(currentItem)
        end
      end
    end
  end
  
  -- Search output
  if recipeCount > 0 then
    print("|cFFFF6666 Look! New Recipe!|r |cFF00FF00"..usableCount.."|r || |cFFFF0000"..(recipeCount - usableCount - knownCount).."|r || |cFF6666FF"..knownCount.."|r")
    if usableCount > 0 then
      PlaySoundFile("Sound/Creature/Cat/CatStepA.ogg")
    end
  end

print("loop")
  LookNewRecipeDrawer_UpdateTabs(recipeCount, usableCount)

  scanSuccessful = true
  
end

function isItemAlreadyKnown(item)   
  -- call this every time you want to scan
  AlreadyKnownTooltip:SetOwner(UIParent, 'ANCHOR_NONE')

  -- Clear the old tooltip.
  AlreadyKnownTooltip:ClearLines()
  AlreadyKnownTooltip:SetHyperlink(item)   
   
  -- Parse the tooltip for the string "Already known"
  for i=1,AlreadyKnownTooltip:NumLines() do
    if string.find(_G["AlreadyKnownTooltipTextLeft"..i]:GetText(), "Already known") then
      AlreadyKnownTooltip:Hide()
      return true
    end
  end
   
  -- finally hide it again
  AlreadyKnownTooltip:Hide()
  return nil
end

-- Set up events.
do
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:RegisterEvent("MERCHANT_SHOW")
  frame:RegisterEvent("MERCHANT_CLOSED")
  frame:RegisterEvent("MERCHANT_UPDATE")
  frame:RegisterEvent("TRAINER_SHOW")
  frame:RegisterEvent("TRAINER_CLOSED")
  frame:RegisterEvent("TRAINER_UPDATE")
  frame:SetScript("OnEvent", function(self, event, ...)
    return LookNewRecipe[event](...)
  end)
end

-- Event handlers.
function LookNewRecipe.ADDON_LOADED(addon)
  if addon == "LookNewRecipe" then
    print("|cFFFF6666Look! New Recipe!|r has loaded successfully.")
  end
end

function LookNewRecipe.MERCHANT_SHOW(...)
  scanSuccessful = false
  LookNewRecipeDrawer_UpdateTabs(0, 0)
  checkMerchantInventory()
  LookNewRecipeDrawer:Show()
end

function LookNewRecipe.MERCHANT_CLOSED(...)
  scanSuccessful = false
  LookNewRecipeDrawer:Hide()
end

function LookNewRecipe.MERCHANT_UPDATE(...)
  if not scanSuccessful then
    checkMerchantInventory()
  end
end

function LookNewRecipe.TRAINER_SHOW(...)
end

function LookNewRecipe.TRAINER_CLOSED(...)
end

function LookNewRecipe.TRAINER_UPDATE(...)
end
