--!strict

local Pool = {}; Pool.__index = Pool
local Connection = {}; Connection.__index = Connection

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
		outOfPool = false,
		doingWork = false,
	}, Connection)

	return actorData
end

function Pool:take(autoPutBack: boolean)
	local actor = table.remove(self.available) or createActor(self.baseActor, self.folder, self.available)
	actor.autoPutBack = autoPutBack
	actor.outOfPool = true
	return actor
end

function Connection:run(...)
	assert(self.outOfPool, "You may not use this actor as it is not currently taken from the pool!")
	assert(not self.doingWork, "You may not use this actor as it is currently doing another task!")
	
	local runEvent, returnEvent = self.runEvent, self.returnEvent

	self.doingWork = true
	runEvent:Fire(...)
	local data = returnEvent and returnEvent.Event:Wait()
	self.doingWork = false

	if self.autoPutBack then self:putBack() end

	return data
end

function Connection:runPromise(...)
	assert(self.outOfPool, "You may not use this actor as it is not currently taken from the pool!")
	assert(not self.doingWork, "You may not use this actor as it is currently doing another task!")

	local runEvent, returnEvent = self.runEvent, self.returnEvent
	local args = { ... }
	
	self.doingWork = true
	return Promise.new(function(resolve, reject, onCancel)
		runEvent:Fire(table.unpack(args))
		local data = returnEvent and returnEvent.Event:Wait()
		resolve(data)
	end)
	:finally(function()
		self.doingWork = false
		if self.autoPutBack then self:putBack() end
	end)
end

function Connection:putBack()
	assert(not self.doingWork, "This actor is currently doing work so it may not be put back in the pool at this moment!")
	self.autoPutBack = false
	self.outOfPool = false
	table.insert(self.available, self)
end

function Connection:waitUntilFree()
	repeat task.wait() until self.doingWork == false
	
	assert(self.outOfPool, "You may not use this actor as it is not currently taken from the pool!")
end

function Connection:waitUntilFreePromise()
	return Promise.new(function(resolve, reject, onCancel)
		repeat task.wait() until self.doingWork == false
		
		if not self.outOfPool then reject("You may not use this actor as it is not currently taken from the pool!") end
		resolve(self)
	end)
end

return function(baseActor: Actor, actorsFolder: Folder, amount: number)
	local pool = setmetatable({ baseActor = baseActor, folder = actorsFolder }, Pool)

	local runEvent, returnEvent = baseActor:FindFirstChild("RunEvent"), baseActor:FindFirstChild("ReturnEvent")
	assert(runEvent, 'Your base actor needs a BindableEvent called "RunEvent" inside of it!')

	local available = table.create(amount)
	for count = 1, amount do
		table.insert(available, createActor(baseActor, actorsFolder, available))
	end
	pool.available = available

	return pool
end
