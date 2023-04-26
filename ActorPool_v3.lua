--!strict
local ActorPool = {}; ActorPool.__index = ActorPool
local ActorPoolInsts = {}; ActorPoolInsts.__index = ActorPoolInsts
local ActorInsts = {}; ActorInsts.__index = ActorInsts

local function createActor(poolBaseActor:Actor, poolFolder:Folder, poolAvailable)
	local newActor = poolBaseActor:Clone()
	newActor.Parent = poolFolder
	
	local actorData = setmetatable(
		{actor=newActor, available=poolAvailable, runFunc=newActor:FindFirstChildWhichIsA("BindableFunction")},
		ActorInsts
	)
	
	return actorData
end

function ActorPool.new(baseActor:Actor, folder:Folder, amount:number)
	local pool = setmetatable({baseActor=baseActor, folder=folder}, ActorPoolInsts)
	
	local actorScript = baseActor:FindFirstChildWhichIsA("BaseScript")
	assert(actorScript, "Your base actor needs a BaseScript inside of it!")
	if not actorScript.Enabled then warn("Its recommended for uour base actor's script to be be Disabled!") end
	assert(baseActor:FindFirstChildWhichIsA("BindableFunction"), "Your base actor needs a bindableFunction inside of it!")

	local available = table.create(amount)
	for count = 1,amount do table.insert(available, createActor(baseActor, folder, available)) end
	pool.available = available

	return pool
end

function ActorPoolInsts:take()
	return table.remove(self.available) or createActor(self.baseActor, self.folder, self.available)
end

function ActorInsts:run(...)
	local data = self.runFunc:Invoke(...)
	table.insert(self.available, self)
	
	return data
end

return ActorPool
