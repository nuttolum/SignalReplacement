--[[

                __  __        __              
   ____  __  __/ /_/ /_____  / /_  ______ ___ 
  / __ \/ / / / __/ __/ __ \/ / / / / __ `__ \
 / / / / /_/ / /_/ /_/ /_/ / / /_/ / / / / / /
/_/ /_/\__,_/\__/\__/\____/_/\__,_/_/ /_/ /_/ 
                                              

RBXScriptSignal Replacement

functionally identical!

~EXCEPT~

this can pass metatables too

not SUPER useful but maybe you might find a use for it

to install:

put somewhere you can use it (usually ReplicatedStorage is the best place for this)

use:
	local signalClass = require(game.ReplicatedStorage.signalClass)
	
make a new signal:
	local itHappenedSignal = signalClass.new()
	
wait for the signal to fire:
	itHappenedSignal:Wait()
	print("it happened!")
	
wait returns arguments:

	itHappenedSignal:Fire("hi")
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	print(itHappenedSignal:Wait())
	
	(will print "hi")
	
connect and disconnect:
	
	function happen()
		print("it happened")
	end
	
	local con = itHappenedSignal:Connect(happen)

	con:Disonnect()


the main use for this is for things like OOP classes:
	
	function Car.new()
		return setmetatable){
			Stopped = signalClass.new()
		}, Car)
	
	
	end
	
	function Car:Stop()
		self.Stopped:Fire()
	end
	
	~~~~~~~~~~~~~~~~~~~~~~~~~
	
	myCar.Stopped:Connect(function()
		print("my car stopped!")
	end)


]]

local Signal = {}
Signal.__index = Signal

local Connection = require(script.Connection)

function Signal.new()
	return setmetatable({
		_Connections = {},
		_Yielding = {},
		Firing = false
	}, Signal)
end

function Signal:Fire(...)
	for i,Connection in ipairs(self._Connections) do
		if Connection._Callback == nil then table.remove(self._Connections,i) else
			spawn(function(...)
				Connection:Fire(...)
			end)(...)
		end
	end
	for i,thread in pairs(self._Yielding) do
		table.remove(self._Yielding, i)
		task.spawn(thread, ...)
	end
end

function Signal:Wait(duration)
	local Running = coroutine.running()
	table.insert(self._Yielding, Running)
	if duration then
		task.delay(duration, function()
			local index = table.find(self._Yielding, Running)
			if index then
				table.remove(self._Yielding, index)
				task.spawn(Running)
			end
		end)
	end
	return coroutine.yield()
end

function Signal:Connect(callback)
	local connection = Connection.new(callback)
	table.insert(self._Connections, connection)
	return connection
end

function Signal:Destroy()

	self._Connections = nil
	self._Yielding = nil
	self.Firing = nil
	setmetatable(self,{__index = function() return nil end})

end


return Signal
