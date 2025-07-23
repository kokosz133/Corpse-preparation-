
local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local input = require('openmw.input')
local util = require('openmw.util')
local async = require('openmw.async')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local ambient = require('openmw.ambient')
local camera = require('openmw.camera')
local types = require('openmw.types')
local core = require('openmw.core')
local vfs = require('openmw.vfs')
local MWUI=require('openmw.interfaces').MWUI


local Recipes={}
Recipes["Create Skeleton"]={KSN_Misc_BoneSkelArmR=5}
Recipes["Create Bonelord"]={KSN_Misc_BoneSkelArmR=10}
Recipes["Create Bonewalker"]={KSN_Misc_BoneSkelTorso=5}
Recipes["Create Ghost"]={KSN_Misc_BoneSkelTorso=3}
Recipes["Create Greater Bonewalker"]={KSN_Misc_BoneSkelTorso=5}




Recipes["Craft Amulet"]={KSN_Misc_BoneSkelArmR=1}
Recipes["Craft Belt"]={KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Right Glove"]={KSN_Misc_BoneSkelTorso=2}
Recipes["Craft Left Glove"]={KSN_Misc_BoneSkelTorso=2}
Recipes["Craft Pant"]={KSN_Misc_BoneSkelTorso=4}
Recipes["Craft Skirt"]={KSN_Misc_BoneSkelArmR=1}
Recipes["Craft Robe"]={KSN_Misc_BoneSkelTorso=8}
Recipes["Craft Shirt"]={KSN_Misc_BoneSkelTorso=4}
Recipes["Craft Ring"]={KSN_Misc_BoneSkelArmR=1}
Recipes["Craft Shoes"]={KSN_Misc_BoneSkelTorso=2}



Recipes["Craft Arrows"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Axe One Hand"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Axe Two Hands"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Blunt Weapon One Hand"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Blunt Weapon Close Two Hands"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Blunt Weapon Wide Two Hands"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Bolts"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Bow"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Crossbow"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Long Blade One Hand"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Long Blade Two Hands"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Short Blade"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Spear"]={KSN_Misc_BoneSkelArmR=3}
Recipes["Craft Thrown Weapons"]={KSN_Misc_BoneSkelArmR=3}


Recipes["Craft Boots"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Cuirass"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Greaves"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Helmet"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Left Gauntlet"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Right Gauntlet"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Left Pauldron"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Right Pauldron"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}
Recipes["Craft Shield"]={KSN_Misc_BoneSkelArmR=3,KSN_Misc_BoneSkelTorso=1}

local Descriptions={}
Descriptions["Harvest"]="Take body parts"
Descriptions["Reanimate"]="Transform into zombie"
Descriptions["Craft Weapon"]="Craft weapons with body parts"
Descriptions["Craft Clothing"]="Craft clothings with body parts"
Descriptions["Craft Armor"]="Craft armors with body parts"

local PoliceSizeRatio=1360/ui.screenSize().x

local MenuSelection=ui.create{layer = 'Settings', template=MWUI.templates.boxTransparent, type = ui.TYPE.Container,props={visible=false, relativePosition=util.vector2(1/2, 1/2), autoSize=true, anchor=util.vector2(1/2,1/2)},
							content=ui.content{{type = ui.TYPE.Flex,props={arrange=ui.ALIGNMENT.Center, horizontal=false, autoSize=true},content=ui.content{}}
            
                                }}


local function CheckRecipe(recipe)
  local state=0
  local recipestate=0
  print(recipe)
  for ingredient, number in pairs(Recipes[recipe]) do
    state=state+1
    if types.Actor.inventory(self):countOf(ingredient)>=number then
      recipestate=recipestate+1
    end    
  end

  if state==recipestate then 
    for ingredient, number in pairs(Recipes[recipe]) do
      core.sendGlobalEvent("Remove",{Object=types.Actor.inventory(self):find(ingredient),Number=number})  
    end
    return(true)
  end
end




local function HideButtonDescription()
    if BarInfos and BarInfos.layout then
        BarInfos:destroy()
    end
end

BarInfos={}
local function ButtonInfos(Button)
  local function ShowVariable()
    local text
    if Recipes[Button] then
      text="You need "
      for ingredient,quantity in pairs(Recipes[Button]) do
        text=text..quantity.." "..types.Miscellaneous.records[ingredient].name.." ("..types.Actor.inventory(self):countOf(ingredient)..") "
      end
    else
      text=Descriptions[Button]
    end
    print(Button)
    local position=MenuSelection.layout.content[1].content[Button].props.Position
    position=util.vector2(0.7,0.5)
    if BarInfos.layout==nil then
      local content
      if vfs.fileExists( "textures/UI/"..Button..".dds") then
        content={type = ui.TYPE.Flex,props={arrange=ui.ALIGNMENT.Center, horizontal=false, autoSize=true},content=ui.content{
                                                                                                                  {type=ui.TYPE.Image,props={ TimerValue=0, Timer=0.03,TexturePath="textures/UI/"..Button..".dds",
                                                                                                                                              size=util.vector2 (ui.screenSize().x/5, ui.screenSize().y/3),
                                                                                                                                              resource = ui.texture { path = "textures/UI/"..Button..".dds", 
                                                                                                                                                                      offset = util.vector2(0, 0),
                                                                                                                                                                      size = util.vector2(512, 512), },   }},

                                                                                                                  {type=ui.TYPE.Text,props={   text=text, textSize=15*PoliceSizeRatio, textColor=util.color.rgb(0.792157, 0.647059, 0.376471)}}
                                                                                                                }}
      else
        content={type=ui.TYPE.Text,props={   text=text, textSize=15*PoliceSizeRatio, textColor=util.color.rgb(0.792157, 0.647059, 0.376471)}}
      end
      
      BarInfos=ui.create({type=ui.TYPE.Container,template=MWUI.templates.boxTransparent, layer="Settings",props = {  autosize=true,
                                                                                                          relativePosition=position,
                                                                                                          anchor = util.vector2(0, 0),},
                                                                                              content=ui.content{content
                                                                                                  }})

    end
  end
  return ShowVariable
end




ButtonFunction1={
CraftAmulet= function (mouseEvent, data)
  if CheckRecipe("Craft Amulet")==true then
    ui.showMessage("You craft an amulet")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_amulet",Actor=self})
  else
    ui.showMessage("You don't have materials to craft an amulet")
  end
end,
CraftBelt= function (mouseEvent, data)
  if CheckRecipe("Craft Belt")==true then
    ui.showMessage("You craft a belt")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_belt",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a belt")
  end
end,
CraftRightGlove= function (mouseEvent, data)
  if CheckRecipe("Craft Right Glove")==true then
    ui.showMessage("You craft a right glove")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_glove_right",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a right glove")
  end
end,
CraftPant= function (mouseEvent, data)
  if CheckRecipe("Craft Pant")==true then
    ui.showMessage("You craft a pant")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_pants",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a pant")
  end
end,
CraftLeftGlove= function (mouseEvent, data)
  if CheckRecipe("Craft Left Glove")==true then
    ui.showMessage("You craft a left glove")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_glove_left",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a left glove")
  end
end,
CraftRing= function (mouseEvent, data)
  if CheckRecipe("Craft Ring")==true then
    ui.showMessage("You craft a ring")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_ring",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a ring")
  end
end,
CraftRobe= function (mouseEvent, data)
  if CheckRecipe("Craft Robe")==true then
    ui.showMessage("You craft a robe")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_robe",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a robe")
  end
end,
CraftShirt= function (mouseEvent, data)
  if CheckRecipe("Craft Shirt")==true then
    ui.showMessage("You craft a shirt")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_shirt",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a shirt")
  end
end,
CraftShoes= function (mouseEvent, data)
  if CheckRecipe("Craft Shoes")==true then
    ui.showMessage("You craft shoes")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_shoes",Actor=self})
  else
    ui.showMessage("You don't have materials to craft shoes")
  end
end,
CraftSkirt= function (mouseEvent, data)
  if CheckRecipe("Craft Skirt")==true then
    ui.showMessage("You craft a skirt")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="flesh_skirt",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a skirt")
  end
end,



CraftArrows= function (mouseEvent, data)
  if CheckRecipe("Craft Arrows")==true then
    ui.showMessage("You craft arrows")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft arrows")
  end
end,
CraftAxeOneHand= function (mouseEvent, data)
  if CheckRecipe("Craft Axe One Hand")==true then
    ui.showMessage("You craft a one hand axe")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a one hand axe")
  end
end,
CraftAxeTwoHands= function (mouseEvent, data)
  if CheckRecipe("Craft Craft Two Hand")==true then
    ui.showMessage("You craft atwo hand axe")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a two hand axe")
  end
end,
CraftBluntWeaponOneHand= function (mouseEvent, data)
  if CheckRecipe("Craft Blunt Weapon One Hand")==true then
    ui.showMessage("You craft an one hand blunt weapon")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_club",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a one hand blunt weapon")
  end
end,
CraftBluntWeaponCloseTwoHands= function (mouseEvent, data)
  if CheckRecipe("Craft Blunt Weapon Close Two Hands")==true then
    ui.showMessage("You craft a two hands close blunt weapon")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_warhammer",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a two hands blunt weapon")
  end
end,
CraftBluntWeaponWideTwoHands= function (mouseEvent, data)
  if CheckRecipe("Craft Blunt Weapon Wide Two Hands")==true then
    ui.showMessage("You craft a two hand wide blunt weapon")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_staff",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a two hand wide blunt weapon")
  end
end,
CraftBolts= function (mouseEvent, data)
  if CheckRecipe("Craft Bolts")==true then
    ui.showMessage("You craft bolts")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft bolts")
  end
end,
CraftBow= function (mouseEvent, data)
  if CheckRecipe("Craft Bow")==true then
    ui.showMessage("You craft a bow")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a bow")
  end
end,
CraftCrossbow= function (mouseEvent, data)
  if CheckRecipe("Craft Crossbow")==true then
    ui.showMessage("You craft a crossbow")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a crossbow")
  end
end,
CraftLongBladeOneHands= function (mouseEvent, data)
  if CheckRecipe("Craft Long Blade One Hand")==true then
    ui.showMessage("You craft an one hand long blade")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_long_blade_1h",Actor=self})
  else
    ui.showMessage("You don't have materials to craft an one hand long blade")
  end
end,
CraftLongBladeTwoHand= function (mouseEvent, data)
  if CheckRecipe("Craft Long Blade Two Hands")==true then
    ui.showMessage("You craft a two hands long blade")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_2h_long_blade",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a two hand long blade")
  end
end,
CraftShortBlade= function (mouseEvent, data)
  if CheckRecipe("Craft Short Blade")==true then
    ui.showMessage("You craft ashort blade")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_short_blade",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a short blade")
  end
end,
CraftSpear= function (mouseEvent, data)
  if CheckRecipe("Craft Spear")==true then
    ui.showMessage("You craft a spear")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a spear")
  end
end,
CraftThrownWeapons= function (mouseEvent, data)
  if CheckRecipe("Craft Thrown Weapons")==true then
    ui.showMessage("You craft thrown weapons")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_throwingknife",Actor=self})
  else
    ui.showMessage("You don't have materials to craft thrown weapons")
  end
end,



CraftBoots= function (mouseEvent, data)
  if CheckRecipe("Craft Boots")==true then
    ui.showMessage("You craft boots")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_boots",Actor=self})
  else
    ui.showMessage("You don't have materials to craft boots")
  end
end,
CraftCuirass= function (mouseEvent, data)
  if CheckRecipe("Craft Cuirass")==true then
    ui.showMessage("You craft a cuirass")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_cuirass",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a cuirass")
  end
end,
CraftGreaves= function (mouseEvent, data)
  if CheckRecipe("Craft Greaves")==true then
    ui.showMessage("You craft greaves")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_greaves",Actor=self})
  else
    ui.showMessage("You don't have materials to craft greaves")
  end
end,
CraftHelmet= function (mouseEvent, data)
  if CheckRecipe("Craft Helmet")==true then
    ui.showMessage("You craft an helmet")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_helm",Actor=self})
  else
    ui.showMessage("You don't have materials to craft an helmet")
  end
end,
CraftLeftGauntlet= function (mouseEvent, data)
  if CheckRecipe("Craft Left Gauntlet")==true then
    ui.showMessage("You craft a left gauntlet")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_gauntlet_left",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a left gauntlet")
  end
end,
CraftRightGauntlet= function (mouseEvent, data)
  if CheckRecipe("Craft Right Gauntlet")==true then
    ui.showMessage("You craft a right gauntlet")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_gauntlet_right",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a right gauntlet")
  end
end,
CraftLeftPauldron= function (mouseEvent, data)
  if CheckRecipe("Craft Left Pauldron")==true then
    ui.showMessage("You craft a left pauldron")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_pauldron_left",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a left pauldron")
  end
end,
CraftRightPauldron= function (mouseEvent, data)
  if CheckRecipe("Craft Right Pauldron")==true then
    ui.showMessage("You craft a right pauldron")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_pauldron_right",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a right pauldron")
  end
end,
CraftShield= function (mouseEvent, data)
  if CheckRecipe("Craft Shield")==true then
    ui.showMessage("You craft a shield")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
    core.sendGlobalEvent("CraftItem",{ItemRecordId="bone_shield",Actor=self})
  else
    ui.showMessage("You don't have materials to craft a shield")
  end
end,
}




local function MenuSelectionContent1(data)
  MenuSelection.layout.content[1].content=ui.content{}    
  
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text=data.Text,textSize=15*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  local position=util.vector2(0,0)
  for i,choice in pairs(data.Choices) do
      MenuSelection.layout.content[1].content:add({name=choice, template=MWUI.templates.boxThick, type = ui.TYPE.Container,props={Position=util.vector2(1/2,0.3+i/15), relativePosition=util.vector2(1/2, 1/2), autoSize=true, anchor=util.vector2(0,0)},content=ui.content
      {{type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text=choice,textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)},events={ mouseClick = async:callback(function() ButtonFunction1[string.gsub(choice," ","")]() end),
                                                                                                                                                                                            focusGain = async:callback(ButtonInfos(choice)),
                                                                                                                                                                                            focusLoss = async:callback(HideButtonDescription)
                                                                                                                                                                                            }
      }}
      })            

    MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  end

  MenuSelection.layout.props.visible=true
  MenuSelection:update()

end


local faced = {}

ButtonFunction={
Harvest= function (mouseEvent, data)
  MenuSelection.layout.props.visible=false
  MenuSelection.layout.content[1].content=ui.content{}    
  MenuSelection:update()
	I.UI.removeMode(I.UI.MODE.Interface)
  ambient.playSound("Menu Click")
  HideButtonDescription()
  self:sendEvent("HarvestCorpse_P", {NPC = faced.hitObject})
  faced = {}
end,

Reanimate= function (mouseEvent, data)
  MenuSelection.layout.props.visible=false
  MenuSelection.layout.content[1].content=ui.content{}    
  MenuSelection:update()
	I.UI.removeMode(I.UI.MODE.Interface)
  ambient.playSound("Menu Click")
  HideButtonDescription()
  core.sendGlobalEvent("CreateZombie",{NPC=faced.hitObject,Player=self})
  ui.showMessage("You reanimate the body")
  faced = {}
end,


CreateSkeleton= function (mouseEvent, data)
  if CheckRecipe("Create Skeleton")==true then
    ui.showMessage("You craft a skeleton")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a skeleton")
  end
end,

CreateGhost= function (mouseEvent, data)
  if CheckRecipe("Create Ghost")==true then
    ui.showMessage("You craft a ghost")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a ghost")
  end
end,

CreateBonelord= function (mouseEvent, data)
  if CheckRecipe("Create Bonelord")==true then
    ui.showMessage("You craft a bonelord")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a bonelord")
  end
end,

CreateBonewalker= function (mouseEvent, data)
  if CheckRecipe("Create Bonewalker")==true then
    ui.showMessage("You craft a bonewalker")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a bonewalker")
  end
end,

CreateGreaterBonewalker= function (mouseEvent, data)
  if CheckRecipe("Create Greater Bonewalker")==true then
    ui.showMessage("You craft a greater bonewalker")
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    ambient.playSound("Menu Click")
    HideButtonDescription()
  else
    ui.showMessage("You don't have materials to craft a greater bonewalker")
  end
end,

CraftClothing= function (mouseEvent, data)
  HideButtonDescription()
  MenuSelectionContent1({Text="   What do want to do?   ",Choices={"Craft Amulet","Craft Belt","Craft Right Glove","Craft Left Glove","Craft Pant","Craft Robe","Craft Shirt","Craft Skirt","Craft Ring","Craft Shoes"}})
  ambient.playSound("Menu Click")
end,

CraftWeapon= function (mouseEvent, data)
  HideButtonDescription()
  MenuSelectionContent1({Text="   What do want to do?   ",Choices={"Craft Blunt Weapon One Hand","Craft Blunt Weapon Close Two Hands","Craft Blunt Weapon Wide Two Hands","Craft Long Blade One Hand","Craft Long Blade Two Hands","Craft Short Blade","Craft Thrown Weapons"}})--,"Craft Arrows","Craft Axe One Hand","Craft Axe Two Hands","Craft Bolts","Craft Bow","Craft Crossbow","Craft Spear"}})
  ambient.playSound("Menu Click")
end,

CraftArmor= function (mouseEvent, data)
  HideButtonDescription()
  MenuSelectionContent1({Text="   What do want to do?   ",Choices={"Craft Boots","Craft Cuirass","Craft Greaves","Craft Helmet","Craft Left Gauntlet","Craft Right Gauntlet","Craft Left Pauldron","Craft Right Pauldron","Craft Shield"}})
  ambient.playSound("Menu Click")
end,
}


local function MenuSelectionContent(data)
  MenuSelection.layout.content[1].content=ui.content{}    
  
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text=data.Text,textSize=15*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  
  for i,choice in pairs(data.Choices) do
      MenuSelection.layout.content[1].content:add({name=choice, template=MWUI.templates.boxThick, type = ui.TYPE.Container,props={Position=util.vector2(1/2,0.3+i/15), relativePosition=util.vector2(1/2, 1/2), anchor=util.vector2(0,0)},content=ui.content
      {{type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text=choice,textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)},events={mouseClick = async:callback(function() ButtonFunction[string.gsub(choice," ","")]() end),
                                                                                                                                                                                            focusGain = async:callback(ButtonInfos(choice)),
                                                                                                                                                                                            focusLoss = async:callback(HideButtonDescription)
                                                                                                                                                                                            }
      }}
      })    
    MenuSelection.layout.content[1].content:add({type = ui.TYPE.Text,template = I.MWUI.templates.textNormal,props={text="",textSize=20*PoliceSizeRatio,relativePosition=util.vector2(1/2, 0), anchor=util.vector2(0,0)}
    })
  end

  MenuSelection.layout.props.visible=true
  MenuSelection:update()

end


input.registerTriggerHandler("CorpsePreparation", async:callback(function ()
  print(MenuSelection.layout.props.visible)
  if MenuSelection.layout.props.visible==false then
    faced = nearby.castRenderingRay(camera.getPosition(), camera.getPosition() + camera.viewportToWorldVector(util.vector2(0.5, 0.5))* camera.getViewDistance(), {ignore = self})
    if faced.hitObject and types.NPC.objectIsInstance(faced.hitObject) == true and  types.Actor.isDead(faced.hitObject) == true then
      if (self.position - faced.hitObject.position):length() < 205 then


        if string.find(types.NPC.records[faced.hitObject.recordId].race,"zombie") or string.find(types.NPC.records[faced.hitObject.recordId].race,"skeleton") then
          MenuSelectionContent({Text="  What do want to do?  ",Choices={"Harvest"}})
        else
          MenuSelectionContent({Text="  What do want to do?  ",Choices={"Harvest","Reanimate"}})
        end
        I.UI.setMode(I.UI.MODE.Interface, { windows = {} })
      end
    else

      MenuSelectionContent({Text=" What do want to do?  ",Choices={"Create Skeleton","Create Bonelord","Create Bonewalker","Create Greater Bonewalker", "Create Ghost","Craft Clothing","Craft Armor","Craft Weapon"}})
      I.UI.setMode(I.UI.MODE.Interface, { windows = {} })
    end
  elseif MenuSelection.layout.props.visible==true then
    MenuSelection.layout.props.visible=false
    HideButtonDescription()
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
    I.UI.removeMode(I.UI.MODE.Interface)
    faced = {}
  end
end))


local function onUpdate()
	if I.UI.getMode() == nil and MenuSelection.layout.props.visible==true then 
    MenuSelection.layout.props.visible=false
    MenuSelection.layout.content[1].content=ui.content{}    
    MenuSelection:update()
  end

end


local DeltaT=core.getRealTime()
local function onFrame()
  DeltaT=math.floor((core.getRealTime()-DeltaT)*100+0.5)/100
  if BarInfos.layout and BarInfos.layout.content[1] and BarInfos.layout.content[1].content then
    BarInfos.layout.content[1].content[1].props.Timer=BarInfos.layout.content[1].content[1].props.Timer-DeltaT
      if BarInfos.layout.content[1].content[1].props.Timer<=0 then 
        BarInfos.layout.content[1].content[1].props.Timer=0.045
        BarInfos.layout.content[1].content[1].props.TimerValue=BarInfos.layout.content[1].content[1].props.TimerValue+1

        if BarInfos.layout.content[1].content[1].props.TimerValue>=30 then
          BarInfos.layout.content[1].content[1].props.TimerValue=0
        end
        print(BarInfos.layout.content[1].content[1].props.TimerValue)
        BarInfos.layout.content[1].content[1].props.resource=ui.texture { path = BarInfos.layout.content[1].content[1].props.TexturePath, 
                                                                          offset = util.vector2(512*BarInfos.layout.content[1].content[1].props.TimerValue, 0),
                                                                          size = util.vector2(512, 512), },

        BarInfos:update()
      end
  end




  
	DeltaT=core.getRealTime()

end


return {
  engineHandlers = {onUpdate=onUpdate, onFrame=onFrame,


  },
  eventHandlers={



  }
}