-- Add cloneref support if the exploit doesn't have it or if it's really shit..
-- Credit to Showerhead (he succ on showers ya know)

local a=Instance.new("Part")for b,c in pairs(getreg())do if type(c)=="table"and#c then if rawget(c,"__mode")=="kvs"then for d,e in pairs(c)do if e==a then getgenv().InstanceList=c;break end end end end end;function get_instance_key(f)for b,c in pairs(InstanceList)do if c==f then return b end end end;function ghetto_cloneref(f)local g=get_instance_key(f)local h=InstanceList[g]InstanceList[g]=nil;local i=f.Parent:GetService(tostring(f))InstanceList[g]=h end;if not cloneref or IsElectron then getgenv().cloneref=ghetto_cloneref end
