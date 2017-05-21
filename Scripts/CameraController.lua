local CameraController = {}

CameraController.Pitch = 0;
CameraController.Yaw = 0;

-- Make this a negative number to invert scrolling
CameraController.RotateSensitivity = -1/10;

local function vmul(a,b)
	return Vector3(b.x*a, b.y*a, b.z*a);
end

-- Direction should be an unit vector

function CameraController:Move(CamObj, Direction, slice)
	local pos = CamObj:getPosition();
	local alpha = CameraController.Pitch / 180 * math.pi;
	local beta = CameraController.Yaw / 180 * math.pi; 
	local sin, cos = math.sin, math.cos
	--local lookVec_x = Vector3(cos(beta), sin(beta)*cos(beta), -sin(beta));
	--local lookVec_y = Vector3(-sin(alpha), cos(alpha), 0);
	--local lookVec_z = Vector3(cos(alpha)*sin(beta), sin(alpha)*sin(beta), cos(beta));
	
	local lookVec_x = Vector3(cos(beta), 0, -sin(beta));
	local lookVec_y = Vector3(sin(beta)*sin(alpha), cos(alpha), cos(beta)*sin(alpha));
	local lookVec_z = Vector3(sin(beta)*cos(alpha), -sin(alpha), cos(beta)*cos(alpha));


	local MoveVec = vmul(Direction.x, lookVec_x) + vmul(Direction.y, lookVec_y) + vmul(Direction.z, lookVec_z);
	local MoveVec = vmul(slice, MoveVec);

	local newPos = pos + MoveVec;

	CamObj:setPosition(newPos.x, newPos.y, newPos.z)
	
end 

function CameraController:Rotate(CamObj, Delta)
	CameraController.Pitch = CameraController.Pitch + Delta[2] * self.RotateSensitivity;
	CameraController.Yaw = CameraController.Yaw + Delta[1] * self.RotateSensitivity;
	
	CamObj:setPitch(CameraController.Pitch);
	CamObj:setYaw(CameraController.Yaw);
end

return CameraController