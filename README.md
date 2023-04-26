> **_NOTE:_**  The following instructions are for ActorPool_v3.

- - -

## Setting Up A Base Actor
1. Create a new `Actor`.
2. Add a `Script` to said `Actor`, and then disable the Script. *The code inside of the `Script` should follow the boilerplate below*.
3. Add a `BindableFunction` called `RunEvent` to the `Actor`,
4. (Optional) If you want to return data from your Actor then add a  `BindableFunction` called `ReturnEvent` to the `Actor`,

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
local pool = ActorPool.new(baseActor:Actor, actorsFolder:Folder, amount:number)
```
`baseActor` = The actor of which all actors in your pool will be a clone of. **This actor will not be included in your pool**.

`actorsFolder` = The folder where all of your actors that are in your pool will be parented to. 

`amount` = The amount of actors to initially create. 

- - -

## Taking An Actor From The Pool
```lua
local actorFromPool = myPool:take(autoPutBack:boolean?)
```
`autoPutBack` = If this is `true` then after `:run` is called on the actor, said actor will automatically be returned to the pool.

- - -

## Running Code Inside An Actor
```lua
actorFromPool:run(...)
```
`...` = the arguements to send to the `Script` inside of the actor from the pool.
- - -

## Returning An Actor To The Pool
```lua
actorFromPool:putBack()
```
