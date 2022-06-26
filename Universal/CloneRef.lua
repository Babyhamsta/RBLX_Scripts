-- Add cloneref support if the exploit doesn't have it or if it's really shit..

-- Credit to Alex | JJsploit Support
local a=Instance.new("Part")for b,c in pairs(getreg())do if type(c)=="table"and#c then if rawget(c,"__mode")=="kvs"then for d,e in pairs(c)do if e==a then getgenv().InstanceList=c;break end end end end end;local f={}function f.invalidate(g)if not InstanceList then return end;for b,c in pairs(InstanceList)do if c==g then InstanceList[b]=nil;return g end end end;if not cloneref then getgenv().cloneref=f.invalidate end
