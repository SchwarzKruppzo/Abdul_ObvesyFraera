m_tTools = {}
m_tTools["Claymore"] = 6

local meta = FindMetaTable("Player")

function meta:GetToolsLimit( name )
	if not m_tTools[ name ] then return 0 end
	return self:GetNWInt( name )
end
function meta:GetToolsLimitMax( name )
	if not m_tTools[ name ] then return 0 end
	return m_tTools[ name ]
end
function meta:IsToolsLimit( name )
	if not m_tTools[ name ] then return end
	if self:GetToolsLimit( name ) < m_tTools[ name ] then
		return true
	end
end
if SERVER then
	function meta:ResetToolsLimit()
		for k,v in pairs(m_tTools) do
			self:SetNWInt( k, 0 )
		end
	end
	function meta:AddToolsLimit( name )
		if not m_tTools[ name ] then return end
		if self:IsToolsLimit( name ) then
			self:SetNWInt( name, self:GetToolsLimit( name ) + 1 )
		end
	end
	function meta:RemToolsLimit( name )
		if not m_tTools[ name ] then return end
		local var = self:GetToolsLimit( name ) - 1 
		var = math.Clamp( var, 0, 1337 )
		self:SetNWInt( name, var )
	end
end