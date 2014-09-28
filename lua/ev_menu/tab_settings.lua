/*-------------------------------------------------------------------------------------------------------------------------
	Tab with settings
-------------------------------------------------------------------------------------------------------------------------*/

--[[
  @TODO: settings in general
  x Implement setting domains (server/client/shared -- do domain checks so that one user can't overwrite the settings of another with higher privs)
  x Bind settings to permissions.
  x Implement string validators.
  x Search feature by building a list of "searchable" text that references the tree node, will require buildcategories to make each setting and put it in the grave.
  x Better behavior for handling pre-existing settings when registering plugins. Delay the initial request for settings?
  x Either make evolve:SaveSettings() only available to the server or let the client have access to von so they can save a copy as well.
  x Make a server version of evolve:SetSetting()
  x Provide a TAB:Update() method that can rebuild the current view
  @TODO: framework overhaul
  * make autocomplete wrap spaces around a name with spaces in it
  * make FindPlayers match registered users that are offline
]]

local TAB = {}
TAB.Title = "Settings"
TAB.Description = "Manage evolution settings and preferences."
TAB.Icon = "page_edit"
TAB.Author = "EntranceJew"
TAB.Width = 520
TAB.Privileges = { "Settings", "Settings: Modify", "Settings: Send To Server" }

TAB.CatWidth = 166

TAB.Frame = nil
TAB.SearchBox = nil
TAB.SearchButton = nil
TAB.SettingsTree = nil
--[[
  this is mapped:
    global.nodes['category1'].nodes['category2']
  which references settings items by key:
    global.nodes['category1'].items['sbox_maxvehicles']
]]
TAB.Scroll = nil
TAB.Layout = nil
TAB.GraveYard = nil


TAB.Controls = {}
--[[
 this is mapped:
    global['num_corns']
]]

local testsettings = {
	category_general = {
		label = 'General',
		desc = 'This is for general evolve settings.',
		stype = 'category',
		icon = 'page_edit',
		value = {
			category_misc = {
				label = 'Misc',
				desc = 'Miscelaneous is hard to spell.',
				stype = 'category',
				icon = 'rainbow',
				value = {
					num_corns = {
					    label = 'No. Corns',
					    desc = 'How many corns? This many.',
					    stype = 'limit',
					    value = 50,
					    min = 25,
					    max = 75,
					    default = 30},
					num_horns = {
					    label = 'No. Horns',
					    desc = 'Remember, we are on a budget.',
					    stype = 'limit',
					    value = 1,
					    min = -3,
					    max = 30,
					    default = 2},
					resync_name = {
					    label = 'Sync Again Label',
					    desc = 'Can you not decide what to call it?',
					    stype = 'string',
					    value = 'reSync',
					    default = 'ReSync'},
					best_name = {
					    label = 'Best Name',
					    desc = 'Who is the best?',
					    stype = 'string',
					    value = 'Bungalo',
					    default = 'EntranceJew'},
					is_great = {
					    label = 'Is Great',
					    desc = 'Are you having trouble finding out?',
					    stype = 'bool',
					    value = true,
					    default = false},
				},
      },
      category_settings = {
				label = 'Settings',
				desc = "Control how your settings control other things.\nThis is going to get confusing fast.",
				stype = 'category',
				icon = 'wrench',
				value = {
					settings_overload_servercfg = {
					    label = 'Overload server.cfg',
					    desc = 'If enabled, this will the LoadSettings to execute after server.cfg -- overwriting any values defined there.',
					    stype = 'bool',
					    value = true,
					    default = false},
				},
			},
      category_hud = {
				label = 'HUD',
				desc = "Specially modify how your HUD controls.",
				stype = 'category',
				icon = 'overlays',
				value = {
					hud_noises = {
					    label = 'HUD Sounds',
					    desc = 'If enabled, this will play beepy noises when your hud monitors get dangerously low.',
					    stype = 'bool',
					    value = true,
					    default = true},
				},
			},
		},
	},
}
for i=1,16 do
	local set = {
		label = 'Test Setting #'..i,
    desc = 'Testing out item '..i..', huh?',
    stype = 'bool',
    value = true,
    default = false
	}
	
	testsettings.category_general.value.category_misc.value["test_set"..i]=set
end

evolve:RegisterSettings( testsettings )

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Settings" )
end

-- functions used by buildsettings
function TAB:CreateLimit( pnl, name, item )
  --@WARNING: This won't update properly if the element 
  if item.isconvar then
    if ConVarExists( name ) then
      --@TODO: Make it so that the server auto-executes these
      --item.value = GetConVarNumber( name )
      --evolve:GetSetting(name, 0)
    else
      -- no fake convars allowed
      return false
    end
  end
  local elm = vgui.Create( "DNumSlider", pnl )
  pnl:SetTall(32)
  elm:SetTall(32)
  elm:SetText( item.label )
  elm:SetWide( pnl:GetWide() )
  elm:SetTooltip( item.desc )
  elm:SetMin( item.min )
  elm:SetMax( item.max )
  elm:SetDecimals( 0 )
  elm:SetValue( item.value )
  elm.Label:SetDark(true)
  self:SetFocusCallbacks( elm.TextArea )
  elm.TextArea.OnEnter = mousereleased
  pnl.NumSlider = elm.TextArea
  
  -- boring handler overloading
  local function mousereleased(mousecode)
    evolve:SetSetting(name, math.Round(elm:GetValue()))
  end
  
  local scratch_released = elm.Scratch.OnMouseReleased
  local slider_released = elm.Slider.OnMouseReleased
  local knob_released = elm.Slider.Knob.OnMouseReleased

  function elm.Scratch:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    scratch_released(elm.Scratch, mousecode)
  end

  function elm.Slider:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    slider_released(elm.Slider, mousecode)
  end

  function elm.Slider.Knob:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    knob_released(elm.Slider.Knob, mousecode)
  end
  
  return pnl
end

function TAB:CreateString( pnl, name, item )
  if item.isconvar then
    if ConVarExists( name ) then
      --item.value = GetConVarString( name )
      --item already has value given from server
    else
      -- no fake convars allowed
      return false
    end
  end
  local helm = vgui.Create( "DLabel", pnl )
  helm:SetWide(135)
  helm:SetText( item.label )
  helm:SetTooltip( item.label )
  helm:SetDark(true)
  helm:Dock( LEFT )
  
  local elm = vgui.Create( "DTextEntry", pnl )
  --elm:SetSize( 227, 32 )
  elm:SetWide(193)
  elm:SetTooltip( item.desc )
  elm:SetValue( item.value )
  elm:Dock( RIGHT )
  self:SetFocusCallbacks( elm )
  pnl.Label = helm
  pnl.TextEntry = elm
  
  -- boring handler overloading
  local parent = self
  elm.OnEnter = function(self)
    evolve:SetSetting(name, self:GetValue())
  end
  
  return pnl
end

function TAB:CreateBool( pnl, name, item )
  --[[
    g_ragdoll_maxcount = {
      label = "Keep NPC bodies",
      desc = "Toggle.",
      stype = "bool",
      value = 0,
      default = 0,
      multiplier = 8,
      isconvar = true,
    },
  ]]
  if item.isconvar then
    if ConVarExists( name ) then
      --item.value = GetConVarNumber( name )
    else
      -- no fake convars allowed
      return false
    end
  end
  local helm = vgui.Create( "DLabel", pnl )
  helm:SetWide(135)
  helm:SetText( item.label )
  --helm:SetSize( 135, 32 )
  helm:SetTooltip( item.desc )
  helm:SetDark(true)
  helm:Dock( LEFT )
  
  elm = vgui.Create( "DCheckBox", pnl )
  elm:SetTall(16)
  --elm:SetSize( 32, 32 )
  elm:SetTooltip( item.desc )
  elm:SetValue( item.value )
  elm:Dock( LEFT )
  pnl.Label = helm
  pnl.CheckBox = elm
  
  -- boring handler overloading
  local parent = self
  elm.OnChange = function(self)
    evolve:SetSetting(name, self:GetChecked())
  end
  
  return pnl
end

--[[TAB:Update()]]

function TAB:BuildCategories( atree, aset, adepth )
  --[[ Mission:
    1) Create all the "self.SettingsTree" nodes.
    2) Set an event so that when the node is clicked it calls OpenToPath( tblPath )
    3) Expand "Categories" lookup table.
  ]]
  --self:BuildCategories2( self.SettingsTree, evolve.settings, self.Categories )
  --self:BuildCategories( self.SettingsTree, evolve.settings, self.Categories )
  --print("DEBUG: BuildCategories2 -- entering")
  
  local tree = atree
  local set = aset
  local path = {}
  --[[if type(apath)=="string" then
    path = string.Explode("\\", apath)
    if table.maxn(path) == 1 and path[1]==apath then
      print("DEBUG: BuildCategories2 -- 'apath' was a string but couldn't be exploded: '"..apath.."'")
    end
  elseif apath==nil then
    print("DEBUG: BuildCategories2 -- 'apath' was nil, leaving 'path' as empty table.")
  end]]
  local depth = adepth or 1
  if adepth~= nil then
    --print("DEBUG: BuildCategories2 -- 'adepth' wasn't nil, incrementing.")
    depth = adepth+1
  else
    --print("DEBUG: BuildCategories2 -- 'adepth' was nil, at entrypoint depth.")
  end
  
  
  assert(tree~=nil, "GOT NIL IN PLACE OF TREE NODE")
  --print("DEBUG: BuildCategories2 -- Investigating tree.")
  --PrintTable(tree)
	if tree.nodes==nil then
    --print("DEBUG: BuildCategories2 -- 1: Tree @ depth has no nodes, adding node stub.")
		tree.nodes={}
	else
    --print("DEBUG: BuildCategories2 -- 2: Tree @ depth has nodes, we must be in an item with multiple children.")
  end
  
  if tree.items==nil then
    tree.items={}
  else
    --same as above.
  end
  
  assert(istable(set), "GOT NON-TABLE SETTINGS")
  --print("DEBUG: BuildCategories2 -- Beginning settings iteration in table shaped like:")
  --PrintTable(set)
	for k,v in pairs(set) do
    if v.stype==nil then
      --print("DEBUG: BuildCategories2 -- Ignoring malformed element '"..k.."' ...")
    else
      --print("DEBUG: BuildCategories2 -- Inside setting '"..v.label.."' of type '"..v.stype.."'...")
      if v.stype == 'category' then
        local node = tree:AddNode( v.label )
        node:SetIcon( "icon16/"..v.icon..".png" )
        node:SetTooltip( v.desc )
        node.ej_parent = v.label
        
        local parent = self
        node.DoClick = function(self)
          --print("doclick: "..v.label.." got clicked on @ depth # "..depth)
          local dpath = {}
          local brk = true
          local work = self
          while brk do
            if work.ej_parent~= nil then
              --print("doclick: added '"..work.ej_parent.."' to stack")
              table.insert(dpath, 1, work.ej_parent)
            else
              --print("doclick: couldn't find attribute ej_parent, assumed done")
              brk = false
            end
            work = work:GetParentNode()
          end
          parent:BuildSettings( dpath )
        end
        
        -- add tree child
        tree.nodes[v.label] = node
        
        --print("DEBUG: BuildCategories2 -- Recursing!!!")
        self:BuildCategories( tree.nodes[v.label], v.value, depth )
        --print("DEBUG: BuildCategories2 -- Returned from recursion!!!")
      else
        table.insert(tree.items, k)
        --print("DEBUG: BuildCategories2 -- Ignoring non-category '"..v.label.."' of type '"..v.stype.."'.")
      end
    end
	end
  --print("DEBUG: BuildCategories2 -- Iterated over all items at current depth of '"..depth.."'")
end


function TAB:BuildSettings( tblPath )
  --print("DEBUG: BuildSettings -- entering...")
  for k,v in pairs(self.Controls) do
    if v:IsValid() then
      if v:GetParent() == self.Layout then
        --print("DEBUG: BuildSettings -- existing control '"..k.."' moved to grave.")
        v:SetParent(self.GraveYard)
      elseif v:GetParent() == self.GraveYard then
        --print("DEBUG: BuildSettings -- control '"..k.."' was already in the grave.")
      else
        assert(false, "RENEGADE CONTROL: "..k)
      end
    else
      --assert(false, "UNDEAD CONTROL ESCAPED GRAVEYARD: "..k)
      v=nil
      --print("DEBUG: BuildSettings -- invalid control '"..k.."' erased.")
    end
  end
  -- since we graved all the children, we should refresh the shape of our scrollbar
  self.Layout:SetSize(self.Scroll:GetSize())
  
  local settings = self.SettingsTree
	for _,v in pairs(tblPath) do
		if settings.nodes[v]==nil then
      --print("DEBUG: BuildSettings -- "..v.." NON-BREAK ("..table.concat(tblPath, "\\")..")")
		elseif v~='nodes' then
      -- we do not want to step into the 'sets' category by itself
      settings = settings.nodes[v]
    elseif v=='nodes' then
      assert(false, "UH OH, SOMEONE TOLD US TO STEP INTO THE 'nodes' CATEGORY, THEY'RE A BAD MAN.")
    end
    --print("DEBUG: BuildSettings -- settings=self.Categories."..v.."==nil; BREAK ("..table.concat(tblPath, "\\")..")")
	end
  --print("DEBUG: Dumping contents of 'settings'.")
  --PrintTable(settings)
	
	for k,v in pairs(settings.items) do
    if self.Controls[v]~=nil then
      --print("DEBUG: BuildSettings -- reassigned parent of existing element: '"..k.."'")
      self.Controls[v]:SetParent(self.Layout)
    else
      local item = evolve.settings[v]
      --print("DEBUG: BuildSettings -- created new element stub: '"..k.."'")
      local step = vgui.Create( "DPanel", self.Layout )
      step:SetWide( self.Layout:GetWide()-20 )
      step:SetTall(32)
      
      local temp = {}
      if item.stype == 'limit' then
        temp = self:CreateLimit( step, v, item )
      elseif item.stype == 'string' then
        temp = self:CreateString( step, v, item )
      elseif item.stype == 'bool' then
        print("CREATING A BOOL, HOO BABY!")
        PrintTable(item)
        temp = self:CreateBool( step, v, item )
      else
        -- the element wasn't what we wanted, so trash it
        step:Remove()
      end
      
      if !temp then
        -- Create* returned nothing so we should trash this
        step:Remove()
      else
        -- everything was fine so let's keep at it
        self.Controls[v] = temp
      end
      --print("DEBUG: BuildSettings -- finalized element: '"..k.."'")
    end
	end
end

function TAB:SetFocusCallbacks( elm )
  elm.OnGetFocus = function()
    self.Panel:GetParent():GetParent():SetKeyboardInputEnabled(true)
  end
  elm.OnLoseFocus = function()
    self.Panel:GetParent():GetParent():SetKeyboardInputEnabled(false)
  end
end

function TAB:OpenToPath( tblPath )
	local depth = self.SettingsTree.nodes
	for _,v in pairs(tblPath) do
		self.SettingsTree:SetSelectedItem(depth[v])
		if depth[v]==nil then
			break
		end
		depth[v]:SetExpanded(true, true)
		depth = depth[v].nodes
	end
	self:BuildSettings( tblPath )
end


function TAB:Initialize( pnl )
  glb = self
  -- [[ for shorthand reaching for sets via category { "General", "Misc" }
  
  self.SearchPanel = vgui.Create("DPanel", pnl)
  self.SearchPanel:SetSize( self.CatWidth, pnl:GetParent():GetTall() - 58 ) --@MAGIC
  self.SearchPanel:Dock(LEFT)
  --SetSize( 520, 490 )
  
  self.SearchBox = vgui.Create( "DTextEntry", self.SearchPanel )	-- create the form as a child of frame
  self.SearchBox:Dock(TOP)
  self.SearchBox:DockMargin( 4, 2, 4, 2 )
  self.SearchBox:SetTooltip( "Press enter to search settings." )
  self.SearchBox.OnEnter = function( self )
    --print( 'SETTINGS SEARCH: '..self:GetValue() )	-- print the form's text as server text
  end
  self:SetFocusCallbacks( self.SearchBox )

  self.SearchButton = self.SearchBox:Add( "DImageButton" )
  self.SearchButton:Dock( RIGHT )
  self.SearchButton:DockMargin( 0, 2, 0, 2 )
  --TAB.SearchButton:SetPos( 2+TAB.SearchBox:GetWide()-16, glob.constantHeight+2 )
  self.SearchButton:SetSize( 16, 16 )
  self.SearchButton:SetImage( "icon16/find.png" )
  self.SearchButton:SetText( "" )
  self.SearchButton:SetTooltip( "Press to search settings." )
  self.SearchButton.DoClick = function() 
    self.SearchBox:OnEnter()
  end

  self.SettingsTree = vgui.Create( "DTree", self.SearchPanel )
  --self.SettingsTree:SetPos( 0, self.SearchBox:GetTall()+2 )
  self.SettingsTree:Dock(TOP)
  self.SearchButton:DockMargin( 4, 2, 4, 2 )
  self.SettingsTree:SetPadding( 4 )
  --self.SettingsTree:SetTall(430)
  self.SettingsTree:SetSize( self.CatWidth, self.SearchPanel:GetTall()-4)
  --self.SettingsTree:SetSize( self.CatWidth, self.SearchPanel:GetTall()-self.SearchBox:GetTall()-4)
  
  self.Scroll = vgui.Create( "DScrollPanel", self.Panel )
	self.Scroll:Dock(RIGHT)
	self.Scroll:SetSize( self.Width-self.CatWidth-8, self.Panel:GetParent():GetTall()-3) --@MAGIC 3
	
	self.Layout = vgui.Create( "DIconLayout", self.Scroll )
  --self.Layout:SetSize( self.Scroll:GetSize() )
	self.Layout:SetTall(self.Scroll:GetTall())
	self.Layout:SetWide(self.Scroll:GetWide()-20)
	--self.Layout:SetPos(0, 0)
	self.Layout:SetSpaceX(0)
	self.Layout:SetSpaceY(5)
  
  -- WORKAROUND BECAUSE DERMA DOESN'T ALWAYS DELETE ITS CHILDREN
  self.GraveYard = vgui.Create( "DPanel" )
  self.GraveYard:SetSize( 0, 0 ) 
  self.GraveYard:SetPos(-1000, -1000)
  
  self:BuildCategories( self.SettingsTree, evolve.settingsStructure )
  self:OpenToPath( {"Plugins", "Sandbox"} )
end

evolve:RegisterTab( TAB )