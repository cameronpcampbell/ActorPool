> **_NOTE:_**  The following instructions are for ActorPool_v3.

- - -

## Setting Up A Base Actor
1. Create a new `Actor`.
2. Add a `Script` to said `Actor`. *The code inside of the `Script` should follow the boilerplate below*.
3. Add a `BindableFunction` called `RunEvent` to the `Actor`,
4. (Optional) If you want to return data from your Actor then add a  `BindableFunction` called `ReturnEvent` to the `Actor`. **If `ReturnEvent` exists then you need to fire it at the end of your actors code.**

Script Code Boilerplate
```lua
local RunEvent, ReturnEvent = script.Parent.RunEvent, script.Parent.ReturnEvent

RunEvent.Event:ConnectParallel(function(...)
	-- Your code here
	
	-- To return data from an actor do:
	-- ReturnEvent:Fire(...)
end)
```
- - -

## Importing The Module
```lua
local ActorPool = require(game:GetService("ReplicatedStorage").ActorPool)
```

- - -

## Creating A Pool Of Actors
```lua
local myPool = ActorPool(baseActor:Actor, actorsFolder:Folder, amount:number)
```
`baseActor` = The actor of which all actors in your pool will be a clone of. **This actor will not be included in your pool**.

`actorsFolder` = The folder where all of your actors that are in your pool will be parented to. 

`amount` = The amount of actors to initially create. 

- - -

## Taking An Actor From The Pool
When using the method below you get returned a `connection` object.
```lua
local myActorFromPool = myPool:take(autoPutBack:boolean?)
```
`autoPutBack` = If this is `true` then after `:run` is called on the actor, said actor will automatically be returned to the pool.

- - -

## Running Code From The Actors Script
```lua
myActorFromPool:run(...)
```
`...` = the arguements to send to the `Script` inside of the actor from the pool.

- - -

## Running Code From The Actors Script (Promise)
```lua
myActorFromPool:runPromise(...)
```
`...` = the arguements to send to the `Script` inside of the actor from the pool.

- - -

## Returning An Actor To The Pool
```lua
myActorFromPool:putBack()
```

- - -

## Waiting For An Actor To Be Free
The below method waits until a specified Actor has finished with whatever work/task they were doing.
```lua
myActorFromPool:waitUntilFree()
```

- - -

## Waiting For An Actor To Be Free (Promise)
The below method waits until a specified Actor has finished with whatever work/task they were doing.
```lua
myActorFromPool:waitUntilFreePromise()
```

<details>
  <summary>Example</summary>
  
  ```lua
  pool:take(true):waitUntilFreePromise():andThen(function(self)
  	self:runPromise(1):andThen(print)
  end)
  ```
</details>

- - -

# Reusing Connections
Please note that in most circumstances using a different connection (actor) from the pool is preferred over using the same connection.

If you are not using promises then reusing actors is simple.
```lua
local conn = pool:take()

print(conn:run(1))
print(conn:run(2))
```

However if you are using promises then you need to make sure that you use the `:waitUntilFree()` method to make sure that the actor/connection is available to do more work.
```lua
local conn = pool:take()

conn:run(1))
print(conn:run(2))
```

A more sophisticated approach would be to use the `:waitUntilFreePromise()` method instead.
```lua
local conn = pool:take()

conn:runPromise(1):andThen(print)
conn:waitUntilFreePromise():andThen(function()
	conn:runPromise(2):andThen(print)
end)
```
