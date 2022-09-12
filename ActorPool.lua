local ActorPool = {}
ActorPool.__index = ActorPool

local ActorPoolInsts = {}
ActorPoolInsts.__index = ActorPoolInsts

-- optimisations
local TableCreate = table.create
local TableInsert = table.insert
local TableFind = table.find
local TableRemove = table.remove


local function createActor(pool)
	local newActor = pool.baseActor:Clone()
	newActor.Name = newActor.Name.."-"..pool.actorCount; pool.actorCount += 1
	newActor:SetAttribute("doingTask", false)
	
	newActor:GetAttributeChangedSignal("doingTask"):Connect(function()
		if not newActor:GetAttribute("doingTask") then
			table.insert(pool.available, newActor)
		end
	end)
	
	newActor.Parent = pool.folder
	return newActor
end

function ActorPool.New(actor, folder, amount)
	local pool =  setmetatable({
		available = nil,
		baseActor = actor,
		folder=folder,
		actorCount = 1
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

return ActorPool
