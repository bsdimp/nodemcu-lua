--
-- DS18B20 is a 1 wire device. Pin 1 is connected to ground, pin 3 to Vcc
-- pin 2 is connected to ow_pin. There's a 4.7k resistor between pins 2 and 3
-- You can connect as many DS18B20 devices as you'd like with each of their
-- pin 2's connected together with only one resistor.
-- 

local ow_pin = 3		-- D3 / GPIO0 on NodeMCU
ds18b20.setup(ow_pin)
maxIdx = -1
-- Prime the pump for temperature sensors to set maxIdx
-- ds18d20 doesn't have a last one callback or indication
-- so we look at how many are there on startup.
ds18b20.read(function(ind,rom,res,temp,tdec,par)
	if ind > maxIdx then
		maxIdx = ind
	end
	print("Priming the pump: ", ind, temp * 9 / 5 + 32, "F", maxIdx)
end, {})

-- Create a server listening at port 451
sv = net.createServer(net.TCP, 60)
sv:listen(451, function(conn)
	local curIdx, data
	local function done(c)
		c:close()
	end
	local function dumpTemps(c)
		if curIdx < maxIdx then
			c:send(data[curIdx], dumpTemps)
		else
			c:send(data[curIdx], done)
		end
		curIdx = curIdx + 1
	end
	-- Read in the temps when we get a connection. When we see the
	-- last one, send off the accumulated data.
	data = {}
	conn:on("sent", dumpTemps)
	ds18b20.read(function(ind,rom,res,temp,tdec,par)
		data[ind] = string.format("%d %2.2f F\r\n", ind, temp * 9 / 5 + 32)
		if ind == maxIdx then
			curIdx = 1
			dumpTemps(conn)
		end
	end, {})
end)
print("Server is running")
