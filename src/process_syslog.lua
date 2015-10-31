local fun = require("fun")()

local logname = arg[1] or "/var/log/syslog.1"

local MON={jan=1,feb=2,mar=3,apr=4,may=5,jun=6,jul=7,aug=8,sep=9,oct=10,nov=11,dec=12}

local function nil_gen()
	return nil;
end

local function linesOfFile(filename)
	local fd = io.open(filename, "rb")
	
	local function line_gen(param, state)
		local line = param:read();
		
		if not line then return nil end

		return state, line, state;
	end

	return line_gen, fd, 1
end

-- a typical line in the log looks like this
-- Oct 29 15:10:20 azl-wiladams1 systemd[1]: Created slice system-lvm2\x2dpvscan.slice.
local function parseSyslogLine(line)
	local pat = "(%a+) (%d+) (%d+):(%d+):(%d+) (%g+) (%g+): (.+)"
	local runmonth, runday, runhour, runminute, runseconds, machine, area, comment = line:match(pat)
	local month = MON[runmonth:lower()]
	local day = tonumber(runday)
	local hour = tonumber(runhour)
	local minute = tonumber(runminute)
	local second = tonumber(runseconds)
	local timestamp = os.time({year = 2015, month = month, day = day, hour = hour, min = minute, sec = second})

	return timestamp, machine, area, comment
end

local uniqueAreas = {}

local function addToUniqueAreas(timestamp, machine, area, comment)
	if not uniqueAreas[area] then
		print(area, comment)
		uniqueAreas[area] = 1
	else
		uniqueAreas[area] = uniqueAreas[area]+1;
	end
end

each(addToUniqueAreas, map(parseSyslogLine, linesOfFile(logname)))

print(" == UNIQUE AREAS == ")
each(print, uniqueAreas)
