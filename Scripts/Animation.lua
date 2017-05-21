local Animation = {}

function Animation:SetAxisAlpha(scn, alpha)
	for i,v in pairs(scn.AxisContainer) do
		local OldColor = v.Color;
		v:setColor(0,0,0, alpha)
	end
end

return Animation