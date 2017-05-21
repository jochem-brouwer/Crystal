local PATH = os.getenv("HOME").."/Documents/Polycode/Crystal/Scripts/"

-- Hack require because this framework fails to provide a normal way of requiring modules (*sigh*)

local function require(modname)
	local out = dofile(PATH..modname..".lua")
	return out 
end

--Hack the vector class because we apparently did not get addition and substraction operations, while we can do dot and cross products. Yeah right.

Vector3.__sub = function(a,b)
	return Vector3(a.x-b.x,a.y-b.y,a.z-b.z);
end

Vector3.__add = function(a,b)
	return Vector3(a.x+b.x,a.y+b.y,a.z+b.z);
end

Vector3.__unm = function(a)
	return Vector3(-a.x, -a.y, -a.z)
end

--Scalar multiplication
Vector3.__mul = function(a,b)
	
	return Vector3(b.x*a, b.y*a, b.z*a);
end

Vector3.__tostring=function(a)
	return a.x .. ", " .. a.y .. ", " .. a.z
end

local scene = Scene(Scene.SCENE_3D);
scene.AxisContainer = {};

local UnitCell = require 'UnitCell';
local Animation = require 'Animation'
local CameraController = require 'CameraController'

local Rutile = UnitCell:new();
local Monoclinic = UnitCell:new();

--Data from "Structural Relations between the VO2 phases"

local ar = Vector3(-4.5546, 0, 0);
local br = Vector3(0, 4.5546, 0);
local cr = Vector3(0, 0, -2.8514);

--[[local am = Vector3(5.743,0,0);
local bm = Vector3(0,4.517,0);
local angle = 122.61; 
local lambda = 5.375;
local cmx = math.cos(angle/180*math.pi)*lambda*am:length()/am.x;
local cmy = 0;
local cmz = math.sqrt(lambda^2 - cmx^2);
local cm = Vector3(cmx, cmy, cmz);--]]

-- Rotate lattice vectors so they fit the source description so we can actually start to animate this...
local am = Vector3(0,0,5.743);
local bm = Vector3(4.517,0,0);
local angle = 122.61;
local lambda = 5.375;

local cmz = math.cos(angle/180*math.pi)*lambda*am:length()/am.z;
local cmx = 0;
local cmy = math.sqrt(lambda^2 - cmz^2);
local cm = Vector3(cmx,-cmy,cmz);

print(cm)

local VRadius = 0.4;
local ORadius = 0.2;

Rutile:SetLatticeVectors(ar,br,cr);
Monoclinic:SetLatticeVectors(am,bm,cm);

function Monoclinic:PostDraw(base)
	base:setRoll(90)
	base:setYaw(90)
	print("hi")
end

Rutile:SetColor("Vanadium", 0,1,0,0.8);
Rutile:SetColor("Oxygen", 0,0,1,0.8);

Monoclinic:SetColor("Vanadium", 0,1,0,0.8);
Monoclinic:SetColor("Oxygen", 0,0,1,0.8);

-- Add Vanadium atoms; the one at the origin and the one in the middle of the unit cell.
Rutile:AddAtom("Vanadium", Vector3(0,0,0), VRadius);
Rutile:AddAtom("Vanadium", Vector3(0.5,0.5,0.5), VRadius);

-- Add the bottom row oxygen atoms. Data from source provided above.
Rutile:AddAtom("Oxygen", Vector3(0.3, 0.3, 0), ORadius);
Rutile:AddAtom("Oxygen", Vector3(1-0.3, 1-0.3,0), ORadius);

-- Add the top row 
-- This is done from finally understanding how those crystal group positions work. 
-- x = 0.3
-- Use wychoff positions for P4_2/mnm 
-- For verification see: Mott 1975, Bruckner 1981, Andersson 1956,  McWhan 1974.
Rutile:AddAtom("Oxygen", Vector3(0.2, 0.8, 0.5), ORadius);
Rutile:AddAtom("Oxygen", Vector3(0.8, 0.2, 0.5), ORadius);

-- Add Atom to UnitC at the 4f Wyckoff positions for x y z
-- B is the unique axis here (these naming conventions are HORRIBLE)
-- C is the axis with the angle... B is the axis to slide the symmetry down, so this is the unique axis. Yeah right.

-- Actually the general function here.
-- Checks all cells around it to figure out if this super inconvenient naming scheme also pops up atoms in our unit cell, if so, add them.
function GenerateUnitCell(UnitC, AtomName, RuleFunc,x,y,z,rad)
	-- This is insane but has to be done.
	local List = RuleFunc(x,y,z);
	for cubex = -1, 1, 1 do
		for cubey = -1, 1, 1 do
			for cubez = -1, 1 ,1 do
				for _, Pos in pairs(List) do 
					local New = Pos + Vector3(cubex,cubey,cubez);
					if New.x <= 1 and New.x >= 0 and New.y <= 1 and New.y >= 0 and New.z <= 1 and New.z >= 0 then 
						UnitC:AddAtom(AtomName,New,rad);
					end
				end
			end
		end
	end
end 

-- Return P2_1_c with b as unique axis.
local function P2_1_c(x,y,z)
	local List = {};
	List[1] = Vector3(x,y,z);
	List[2] = Vector3(-x, y+0.5, -z+0.5);
	List[3] = Vector3(-x, -y, -z);
	List[4] = Vector3(x,-y+0.5,z+0.5);
	return List
end

GenerateUnitCell(Monoclinic, "Vanadium", P2_1_c, 0.242, 0.975, 0.025, VRadius);
GenerateUnitCell(Monoclinic, "Oxygen", P2_1_c, 0.1, 0.21, 0.2, ORadius);
GenerateUnitCell(Monoclinic, "Oxygen", P2_1_c, 0.39, 0.69, 0.29, ORadius);

--[[
for cellx = 0,2 do 
for celly = 0,2 do 
for cellz = 0,2 do 
Monoclinic:DrawCell(cellx,celly,cellz ,scene);
end
end
end--]]
--Rutile:DrawCell(0,1,0 ,scene);
--Rutile:DrawCell(0,0,1 ,scene);
--Rutile:DrawCell(0,1,1 ,scene);

--Rutile:DrawCell(0,0,0, scene);
Monoclinic:DrawCell(0,0,0,scene)
--Monoclinic:DrawCell(0,0,1, scene);
--Monoclinic:DrawCell(0,1,1, scene);
--Monoclinic:DrawCell(0,1, 0, scene);

Rutile:DrawCell(-1,-3,-1,scene);
Rutile:DrawCell(-1,-3,0,scene)

print("Monoclinic content: ");
Monoclinic:CountAtoms();

print("Rutile content: ")
Rutile:CountAtoms();


---- START DRAWING FUNCTIONS ----

local Cam =scene:getDefaultCamera()

local State = false;

local MousePos = {0,0}

local function MouseDown(t, event)
	local evt = safe_cast(event, InputEvent);
	local mButton = evt.mouseButton
	if mButton == 0 then
		State = true;
		MousePos = {evt.mousePosition.x, evt.mousePosition.y};
	end
end

local function MouseUp(t, event)
	local evt = safe_cast(event, InputEvent);
	local mButton = evt.mouseButton
	if mButton == 0 then
		State = false;
	end
end

local function MouseMove(t,event)
	local evt = safe_cast(event, InputEvent);
	if State then 
		local newx = evt.mousePosition.x;
		local newy = evt.mousePosition.y;
		local Delta = {newx - MousePos[1], newy - MousePos[2]};		

		MousePos = {newx, newy};
		
		CameraController:Rotate(scene:getDefaultCamera(), Delta)
	end
end

local function ScrollUp()
	CameraController:Move(Cam, Vector3(0,0,1), 1);
end

local function ScrollDown()
	CameraController:Move(Cam, Vector3(0,0, 1), -1);
end

local down = {w=false, a=false, d = false, s = false};
local cvt = {}

local function ProcessKeyDown(key)
	local dir = {w=Vector3(0,0,-1), s=Vector3(0,0,1), a = Vector3(-1,0,0), d = Vector3(1,0,0)};
	CameraController:Move(Cam, dir[key], (math.sqrt(down[key] or 0) + 1)/10);
end


--cvt[KEY_W] = "w";
--cvt[KEY_A] = "a";
--cvt[KEY_S] = "s";
--cvt[KEY_D] = "d";

cvt[97] = "a";
cvt[115] = "s";
cvt[100] = "d";
cvt[119] = "w"


local function keyDown(t, event)
	local evt = safe_cast(event, InputEvent);
	local kcode = evt:keyCode();
	local kcode = cvt[kcode or 1];
	if kcode and down[kcode] ~= nil then
		down[kcode] = 0;
		--ProcessKeyDown(down);
	end
end

local function keyUp(t, event)
	local evt = safe_cast(event, InputEvent);
	local kcode = evt:keyCode();
	local kcode = cvt[kcode or 1];
	if kcode and down[kcode] ~= nil then
		down[kcode] = false;
	end
end

Services.Input:addEventListener(nil, MouseDown, InputEvent.EVENT_MOUSEDOWN);
Services.Input:addEventListener(nil, MouseUp, InputEvent.EVENT_MOUSEUP);
Services.Input:addEventListener(nil, MouseMove, InputEvent.EVENT_MOUSEMOVE);

Services.Input:addEventListener(nil, ScrollUp, InputEvent.EVENT_MOUSEWHEEL_UP);
Services.Input:addEventListener(nil, ScrollDown, InputEvent.EVENT_MOUSEWHEEL_DOWN);

Services.Input:addEventListener(nil, keyDown, InputEvent.EVENT_KEYDOWN);
Services.Input:addEventListener(nil, keyUp, InputEvent.EVENT_KEYUP);

t = 0;

function Update(elapsed)
	t = t + elapsed;

	for i,v in pairs(down) do
		if v then 
			down[i] = down[i] + elapsed
			ProcessKeyDown(i)
		end
	end
	--scene:getDefaultCamera():setPosition(-10*math.sin(t) ,10,-10*math.cos(t))
	--scene:getDefaultCamera():setPosition(0,10,t)
	--scene:getDefaultCamera():setPosition(-10,0,0);
	--scene:getDefaultCamera():lookAt(Vector3(0, 0, 0), Vector3(0, 1, 0))

	alpha_val = (math.cos(t)+1)/2;

	--Animation:SetAxisAlpha(scene,alpha_val)
end