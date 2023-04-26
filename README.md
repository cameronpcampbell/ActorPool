> **_NOTE:_**  The following instructions are for ActorPool_v3.

- - -

# Setting Up A Base Actor
1. Create a new `Actor`.
2. Add a `Script` to said `Actor`, and then disable the Script.
3. Add a `BindableEvent` to the `Actor`

- - -

# Importing The Module
```lua
local ActorPool = require(game:GetService("ReplicatedStorage").ActorPool)
```

- - -

# Creating A Pool Of Actors
```lua
local pool = ActorPool.new(baseActor, actorsFolder, amount)
```
`baseActor` = The actor of which all actors in your pool will be a clone of. **This actor will not be included in your pool**.

`actorsFolder` = The folder where all of your actors that are in your pool will be parented to. 

`amount` = The amount of actors to initially create. 

