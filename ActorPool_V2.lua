local ActorPool = {}; ActorPool.__index = ActorPool
local ActorPoolInsts = {}; ActorPoolInsts.__index = ActorPoolInsts
local ActorInsts = {}; ActorInsts.__index = ActorInsts

-- optimisations
local TableCreate = table.create
local TableInsert = table.insert
local TableFind = table.find
local TableRemove = table.remove

local function createActor(pool, addToPool)
	local newActor = pool.baseActor:Clone()
	newActor.Name = newActor.Name.."-"..pool.actorCount+1; pool.actorCount += 1
	newActor:SetAttribute("doingTask", false)
	newActor:FindFirstChildOfClass("Script").Disabled = false
	newActor.Parent = pool.folder
	
	local actorData = setmetatable({actor=newActor, returnEvent=newActor.ReturnEvent.Event}, ActorInsts)

	newActor.ReturnEvent.Event:Connect(function()
		TableInsert(pool.available, actorData)
	end)

	return actorData
end

function ActorPool.New(actor, folder, amount)
	local pool =  setmetatable({
		available = nil,
		baseActor = actor,
		folder=folder,
		actorCount = 0
	}, ActorPoolInsts)

	local actors = TableCreate(amount)
	for count = 1,amount do
		local newActor = createActor(pool)
		TableInsert(actors, newActor)
	end

	pool.available = actors

	return pool
end

function ActorPoolInsts:Take()
	return table.remove(self.available) or createActor(self)
end

function ActorInsts:Run(...)
	self.actor:SetAttribute("doingTask", true)
	return self.actor.RunEvent:Fire(...)
end

return ActorPool
