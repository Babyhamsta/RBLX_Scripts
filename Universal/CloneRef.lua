-- Add cloneref support if the exploit doesn't have it or if it's really shit..
-- Credit to Showerhead (he succ on showers ya know)

local sample = Instance.new("Part")
for i,v in pairs(getreg()) do
	if type(v) == "table" and #v then
		if rawget(v, "__mode") == "kvs" then
			for i2,v2 in pairs(v) do
				if v2 == sample then
					getgenv().InstanceList = v
					break
				end
			end
		end
	end
end

function get_instance_key(instance)
	for i,v in pairs(InstanceList) do
		if v == instance then
			return i
		end
	end
end

function ghetto_cloneref(instance)
	local key = get_instance_key(instance)
	local old = InstanceList[key]
	InstanceList[key] = nil;
	local cloned = instance.Parent:GetService(tostring(instance))
	InstanceList[key] = old;    
end

if not cloneref then
	getgenv().cloneref = ghetto_cloneref;
end
