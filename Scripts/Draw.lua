local Draw = {}

-- Might need to edit the atom colors here.
function Draw.ShowOverlap(Rutile, Monoclinic, scene)
--Rutile:DrawCell(0,0,0, scene);
Monoclinic:DrawCell(0,0,0,scene)
--Monoclinic:DrawCell(0,0,1, scene);
--Monoclinic:DrawCell(0,1,1, scene);
--Monoclinic:DrawCell(0,1, 0, scene);

Rutile:DrawCell(0,-1,-1.5,scene);
Rutile:DrawCell(0,-1,-0.5,scene);
end

-- List with objects;
-- {Entity, Pos_Monoclinic, Pos_Rutile};
local Linked = {};
-- List of Axis:
-- Axis.Monoclinic: axis to show @ Monoclinic.
-- Axis.Rutile: axis to show @ Rutile.
local AxisList = {};
AxisList.Monoclinic = {};
AxisList.Rutile = {};


function Draw.ShowTransition(Rutile, Monoclinic, scene)

-- Generates an "unit cell" of monoclinic VO2. This isn't an actual unit cell. It will setup the atoms in such way that 
-- They can transform to the rutile type.
-- (There is a V atom moved and a oxygen atom moved to the upper cell)
local function GenMonoclinicRutileCell(ox, oy, oz)
	local Atoms, Axis = Monoclinic:DrawCell(ox,oy,oz,scene);

	-- Remove the first Vanadium atom.

	for i,v in pairs(Atoms) do
		if v.Type == "Vanadium" then
			scene:removeEntity(v.Entity)
			v.Removed=true;
			break
		end
	end
	
	-- Remove the second oxygen atom.
	local counter = 0;
	for ind, val in pairs(Atoms) do
		if val.Type == "Oxygen" then 
			counter = counter + 1;
			if counter == 2 then
				scene:removeEntity(val.Entity)
				val.Removed=true;
				break
			end
		end
	end
	local Atoms2, Axis2 = Monoclinic:DrawCell(ox+1,oy,oz,scene);

	-- Remove everything except the second oxygen.
	local counter = 0;
	local oxygen
	for ind, val in pairs(Atoms2) do
		if val.Type == "Oxygen" then 
			counter = counter + 1;
			if counter ~= 2 then
				scene:removeEntity(val.Entity)
				val.Removed=true;
			else
				oxygen = val;
			end
		else
			scene:removeEntity(val.Entity)
		end
	end
	
	for i,ax in pairs(Axis2) do
		scene:removeEntity(ax)
	end
	
	-- remove all but first vandium
	local Atoms3, Axis3 = Monoclinic:DrawCell(ox+1,oy-1,oz+1,scene);
	local found = false;
	local vanadium
	for i,v in pairs(Atoms3) do
		if v.Type == "Vanadium" then
			if not found then
				found = true;
				vanadium = v;
			else
				scene:removeEntity(v.Entity)
			end
		else 
			scene:removeEntity(v.Entity);
		end
	end
	
	for i,ax in pairs(Axis3) do
		scene:removeEntity(ax)
	end

	local Atoms_Mono = {};
	
	for i,v in pairs(Atoms) do
		if not v.Removed then 
			table.insert(Atoms_Mono,v);
		end
	end
	
	table.insert(Atoms_Mono, oxygen);
	table.insert(Atoms_Mono, vanadium);

-- Uncomment for debug visual check
	local AtomsR1, AxisR1 = Rutile:DrawCell(ox,oy-1,oz-1.5,scene);
	local AtomsR2, AxisR2 = Rutile:DrawCell(ox,oy-1,oz-0.5,scene);

	local Atoms_Rutile = {};
	for i,v in pairs(AtomsR1) do
		table.insert(Atoms_Rutile, v);
	end
	for i,v in pairs(AtomsR2) do
		table.insert(Atoms_Rutile, v)
	end

	local function AddLink(Entity, Mn_pos, Ru_pos)
		table.insert(Linked, {Entity, Mn_pos, Ru_pos});
	end

	for _, Atom in pairs(Atoms_Mono) do
		-- find closest neighbour @ Rutile...
		local min = math.huge;
		local pos = Atom.Pos;
		local cur = nil;
		for _, R_Atom in pairs(Atoms_Rutile) do
			local mag = (R_Atom.Pos - pos):length();
			if mag < min then
				cur = R_Atom;
				min=mag;
			end
		end
		assert(cur, "something went wrong");
		if min > 1 then
			Atom.Entity:setColor(1,1,1,1);
			cur.Entity:setColor(1,1,1,1);
		end
		AddLink(Atom.Entity, Atom.Pos, cur.Pos);

		--Atom.Entity:setColor(min,min,min,1)

		-- Print out the magnitude of displacement.
		print(Atom.Type..": ".. min)
	end
	-- Remove all rutile atoms (we don't want them drawn, we move the monoclinic ones around)
	
	for i,v in pairs(Atoms_Rutile) do
		scene:removeEntity(v.Entity)
	end
	-- Add axis
	for ind, ax in pairs(Axis) do 
		table.insert(AxisList.Monoclinic, ax)
	end

	for ind, ax in pairs(AxisR1) do
		table.insert(AxisList.Rutile, ax)
	end

	for ind, ax in pairs(AxisR2) do
		table.insert(AxisList.Rutile, ax)
	end
end


-- Generate a cell and put everything in place for anim:
GenMonoclinicRutileCell(0,0,0)
--[[GenMonoclinicRutileCell(1,0,0)
GenMonoclinicRutileCell(0,1,0)
GenMonoclinicRutileCell(0,0,1)--]]
-- Actual ANIM function to return;

local Time_Elapsed = 0;
local Period = 10;


local cval = 0;
local sgn_now = 1;
local vlast = 0;

local function Update(elapsed)
	--do return end
	Time_Elapsed = Time_Elapsed + elapsed;
	
	-- Init @ 0
	-- Value between 0 and 1. cosine interpolation... nice
	local Interpolate_Val = (math.cos(Time_Elapsed/Period * 2 * math.pi - math.pi)+1)/2;
--	print(Interpolate_Val)
	local delta = Interpolate_Val - vlast;
	vlast = Interpolate_Val;
	
	local sgn_last = sgn_now;
	local sgn_now = delta/math.abs(delta);

--[[
	if sgn_now == 1 then
		-- SHOW MONOCLINIC AXIS
		if sgn_now ~= sgn_last then
			-- REMOVE RUTILE AXIS
		end

		for _, ax in pairs(AxisList.Monoclinic) do
			local color = ax.color
			local newColor = Color(color.r, color.g, color.b, 1-Interpolate_Val);
			ax:setColor(newColor.r, newColor.g, newColor.b, newColor.a)
		end
	else
		-- SHOW RUTILE AXIS
		if sgn_now ~= sgn_last then
			-- REMOVE MONOCLINIC AXIS
		end

		for _, ax in pairs(AxisList.Rutile) do
			local color = ax.color
			local newColor = Color(color.r, color.g, color.b, Interpolate_Val);
			ax:setColor(newColor.r, newColor.g, newColor.b, newColor.a)
		end
	end
--]]
		for _, ax in pairs(AxisList.Rutile) do
			local color = ax.color
			local newColor = Color(color.r, color.g, color.b, Interpolate_Val);
			ax:setColor(newColor.r, newColor.g, newColor.b, newColor.a)
		end

		for _, ax in pairs(AxisList.Monoclinic) do
			local color = ax.color
			local newColor = Color(color.r, color.g, color.b, 1-Interpolate_Val);
			ax:setColor(newColor.r, newColor.g, newColor.b, newColor.a)
		end


	local function vmul(a,b)
		return Vector3(b.x*a, b.y*a, b.z*a);
	end
	
	for _, Data in pairs(Linked) do
		local Entity = Data[1];
		local StartPos = Data[2];
		local EndPos = Data[3];
		
		local DiffVec = EndPos - StartPos;
		local NewPos = StartPos + vmul(Interpolate_Val, DiffVec);
		Entity:setPosition(NewPos.x, NewPos.z, -NewPos.y);
	end
end

return Update
end


return Draw