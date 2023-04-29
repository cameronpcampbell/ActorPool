--!strict
local ActorPool = {}
ActorPool.__index = ActorPool
local ActorPoolInsts = {}
ActorPoolInsts.__index = ActorPoolInsts
local ActorInsts = {}
ActorInsts.__index = ActorInsts

local Promise = require(script.Promise)

local function createActor(poolBaseActor: Actor, poolFolder: Folder, poolAvailable)
	local newActor: Actor = poolBaseActor:Clone()
	newActor.Parent = poolFolder

	local actorData = setmetatable({
		actor = newActor,
		available = poolAvailable,
		runEvent = newActor.RunEvent,
		returnEvent = newActor:FindFirstChild("ReturnEvent"),
		autoPutBack = false,
		inUse = false,
		doingWork = false,
	}, ActorInsts)

	return actorData
end

function ActorPool.new(baseActor: Actor, actorsFolder: Folder, amount: number)
	local pool = setmetatable({ baseActor = baseActor, folder = actorsFolder }, ActorPoolInsts)

	local runEvent, returnEvent = baseActor:FindFirstChild("RunEvent"), baseActor:FindFirstChild("ReturnEvent")
	assert(runEvent, 'Your base actor needs a BindableEvent called "RunEvent" inside of it!')

	local available = table.create(amount)
	for count = 1, amount do
		table.insert(available, createActor(baseActor, actorsFolder, available))
	end
	pool.available = available

	return pool
end

function ActorPoolInsts:take(autoPutBack: boolean)
	local actor = table.remove(self.available) or createActor(self.baseActor, self.folder, self.available)
	actor.autoPutBack = autoPutBack
	actor.inUse = true
	return actor
end

function ActorInsts:run(...)
	assert(self.inUse, "You may not use this actor as it is not currently taken from the pool!")
	local runEvent, returnEvent = self.runEvent, self.returnEvent

	self.doingWork = true

	runEvent:Fire(...)
	local data = returnEvent and returnEvent.Event:Wait()

	if self.autoPutBack then
		self.autoPutBack = false
		self.inUse = false
		table.insert(self.available, self)
	end

	self.doingWork = false

	return data
end

function ActorInsts:runPromise(...)
	assert(self.inUse, "You may not use this actor as it is not currently taken from the pool!")
	self.doingWork = true

	local runEvent, returnEvent = self.runEvent, self.returnEvent
	local args = { ... }

	return Promise.new(function(resolve, reject, onCancel)
		runEvent:Fire(table.unpack(args))
		local data = returnEvent and returnEvent.Event:Wait()
		resolve(data)
	end):finally(function()
		if self.autoPutBack then
			self.autoPutBack = false
			self.inUse = false
			table.insert(self.available, self)
		end

		self.doingWork = false
	end)
end

function ActorInsts:putBack()
	assert(
		not self.doingWork,
		"This actor is currently doing work so it may not be put back in the pool at this moment!"
	)
	self.autoPutBack = false
	self.inUse = false
	table.insert(self.available, self)
end

return ActorPool
