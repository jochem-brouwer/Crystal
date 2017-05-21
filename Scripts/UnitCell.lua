local UnitCell = {};

function UnitCell:new()
	return setmetatable({Atoms = {}, Colors={}}, {__index=self});
end

function UnitCell:AddAtom(AtomType, Pos, Radius)
	local Input = {};
	Input.Pos = Pos;
	Input.Type = AtomType;
	Input.Radius = Radius or 0.2
	table.insert(self.Atoms, Input)
end

function UnitCell:SetLatticeVectors(Vec1, Vec2, Vec3)
	self.LatticeVectors = {
		a = Vec1;
		b = Vec2;
		c = Vec3;
	} -- Units are in Angstrom.
end

function UnitCell:SetColor(Atom, r,g,b,a)
	self.Colors[Atom] = {r,g,b,a};
end

local function vmul(a,b)
	return Vector3(b.x*a, b.y*a, b.z*a);
end

local function erot(entity, lookVector)
	local yaw = math.atan2(lookVector.x, -lookVector.y);
	local sx = math.sqrt(lookVector.x^2 + lookVector.y^2); 
	local pitch = math.atan2(sx, lookVector.z);
	entity:setYaw(yaw/math.pi*180);
	entity:setPitch(pitch/math.pi*180);
end

function UnitCell:CountAtoms()
	local amt = {};
	for i,v in pairs(self.Atoms) do
		if not amt[v.Type] then
			amt[v.Type] = 1;
		else
			amt[v.Type] = amt[v.Type] + 1;
		end
	end
	for ind, val in pairs(amt) do
		print(ind..": " .. val)
	end
end

local function MouseDown(what, ...)
	print("woo down")
end

-- scn is scene.
function UnitCell:DrawCell(OffsetX, OffsetY, OffsetZ, scn)
	local base = ScenePrimitive(ScenePrimitive.TYPE_BOX, 0,0,0)
	
	if self.PostDraw then
		self:PostDraw(base)
	end

	local a,b,c = self.LatticeVectors.a, self.LatticeVectors.b, self.LatticeVectors.c
	local OffsetVec = vmul(OffsetX,a) + vmul(OffsetY,b) + vmul(OffsetZ,c);
	for _, Atom in pairs(self.Atoms) do
		local Pos = vmul(Atom.Pos.x, a) + vmul(Atom.Pos.y, b) + vmul(Atom.Pos.z, c);
		local WPos = Pos + OffsetVec;
		
		local Sphere = ScenePrimitive(ScenePrimitive.TYPE_SPHERE, Atom.Radius, 10, 10)
		Sphere:setParentEntity(base);
		--box:setPitch(25)
		--box:setPosition(7, -1, 0)
		--box:setColor(0.5, 0.5, 1,1)
		-- y axis is up in drawing. sure.

		Sphere:setPosition(WPos.x, WPos.z, -WPos.y);
		if self.Colors[Atom.Type] then
			Sphere:setColor(unpack(self.Colors[Atom.Type]));
		else
			Sphere:setColor(1, 0, 0, 1);
		end
		-- Doesn't work.
		--[[Sphere.processInputEvents=true;
		local function mdown() print('xd') MouseDown(Sphere, Atom) end
		Sphere:addEventListener(nil, mdown,InputEvent.EVENT_MOUSEDOWN);--]]
		scn:addEntity(Sphere);
	end

	local A_Axis = ScenePrimitive(ScenePrimitive.TYPE_CYLINDER, a:length(), 0.05, 6);
	local pos = OffsetVec + vmul(0.5, a);
	A_Axis:setPosition(pos.x,pos.z, -pos.y);
	A_Axis:setColor(1,0,0,1);
	--A_Axis:setRoll(90);
	erot(A_Axis, vmul(1/(a:length()), a))
	scn:addEntity(A_Axis);

	local B_Axis = ScenePrimitive(ScenePrimitive.TYPE_CYLINDER, b:length(), 0.05, 6);
	local pos = OffsetVec + vmul(0.5, b);
	B_Axis:setPosition(pos.x,pos.z, -pos.y);
	B_Axis:setColor(0,1,0,1);
	--B_Axis:setPitch(90);
	erot(B_Axis, vmul(1/(b:length()), b))
	scn:addEntity(B_Axis);


	local C_Axis = ScenePrimitive(ScenePrimitive.TYPE_CYLINDER, c:length(), 0.05, 6);
	local pos = OffsetVec + vmul(0.5, c);
	C_Axis:setPosition(pos.x,pos.z, -pos.y);
	C_Axis:setColor(0,0,1,1);
	erot(C_Axis, vmul(1/(c:length()), c))
	--C_Axis:setPitch(90);
	scn:addEntity(C_Axis);

	table.insert(scn.AxisContainer, A_Axis);
	table.insert(scn.AxisContainer, B_Axis);
	table.insert(scn.AxisContainer, C_Axis);

	A_Axis:setParentEntity(base);
	B_Axis:setParentEntity(base);
	C_Axis:setParentEntity(base);
end

return UnitCell;