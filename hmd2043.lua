-- HIT_HMD2043  Harold Media Drive
--
--                               __    __
--                                ||  ||
--                                ||==|| I T
--                               _||  ||_
--
--                    Harold Innovation Technologies
--                "If it ain't a HIT, it's a piece of..."

-- Note:	Hardware Delay has been ignored in this implementation. 
--			Someone can implement it if they really want to, but I
--			Didn't think it made too much of a difference. -NC

-- TODO:	Implement the reading/writing.. haha

-- Interrupt Constants
local I_QUERY_MEDIA_PRESENT = 0x0000
local I_QUERY_MEDIA_PARAMETERS = 0x0001
local I_QUERY_DEVICE_FLAGS = 0x0002
local I_UPDATE_DEVICE_FLAGS = 0x0003
local I_QUERY_INTERRUPT_TYPE = 0x0004
local I_SET_INTERRUPT_MESSAGE = 0x0005
local I_READ_SECTORS = 0x0010
local I_WRITE_SECTORS = 0x0011
local I_QUERY_MEDIA_QUALITY = 0xFFFF
-- Status Constants
local S_ERROR_NONE = 0x0000
local S_ERROR_NO_MEDIA = 0x0001
local S_ERROR_INVALID_SECTOR = 0x0002
local S_ERROR_PENDING = 0x0003
local S_ERROR_WRITELOCKED = 0x0004
-- Device Interrupt types
local D_NONE = 0x0000
local D_MEDIA_STATUS = 0x0001
local D_READ_COMPLETE = 0x0002
local D_WRITE_COMPLETE = 0x0003
-- State variables
local MEDIAINFO = {	-- Until module configuration is available. It's hardcoded
	MediaLoaded = true,
	SectorCount = 1440,			-- As per HMU1440 Harold Media Unit
	WordsPerSector = 512,
	WriteLocked = false,
	MediaFile = "floppy.dimg16",
	IsCompliant = true
};
local DEVICEINFO = {
	NonBlockingMode = false,
	StatusInterrupt = false,
	LastInterrupt = D_NONE,
	LastError = S_ERROR_NONE,
	InterruptMessage = 0xFFFF
};

function interrupt(cpu)
	local command = cpu.registers.A
	if(command == I_QUERY_MEDIA_PRESENT) then
		if(MEDIAINFO.MediaLoaded) then
			cpu.registers.B = 1
		else
			cpu.registers.B = 0
		end
		cpu.registers.A = S_ERROR_NONE
		return
	elseif(command == I_QUERY_MEDIA_PARAMETERS) then
		cpu.registers.B = MEDIAINFO.WordsPerSector
		cpu.registers.C = MEDIAINFO.SectorCount
		if(MEDIAINFO.WriteLocked) then
			cpu.registers.X = 1
		else
			cpu.registers.X = 0
		end
		cpu.registers.A = S_ERROR_NONE
	elseif(command == I_QUERY_DEVICE_FLAGS) then
		local b = 0
		if(DEVICEINFO.NonBlockingMode) then
			b = b + 1
		end
		if(DEVICEINFO.StatusInterrupt) then
			b = b + 2
		end
		cpu.registers.B = b
		cpu.registers.A = S_ERROR_NONE
	elseif(command == I_UPDATE_DEVICE_FLAGS) then
		local setting = cpu.register.B
		if(setting == 0) then
			DEVICEINFO.NonBlockingMode = false
			DEVICEINFO.StatusInterrupt = false
		elseif(setting == 1) then
			DEVICEINFO.NonBlockingMode = true
			DEVICEINFO.StatusInterrupt = false
		elseif(setting == 2) then
			DEVICEINFO.NonBlockingMode = false
			DEVICEINFO.StatusInterrupt = true
		elseif(setting == 3) then
			DEVICEINFO.NonBlockingMode = true
			DEVICEINFO.StatusInterrupt = true
		end
		cpu.registers.A = S_ERROR_NONE
	elseif(command == I_QUERY_INTERRUPT_TYPE) then
		cpu.registers.B = DEVICEINFO.LastInterrupt
		cpu.registers.A = DEVICEINFO.LastError
	elseif(command == I_SET_INTERRUPT_MESSAGE) then
		DEVICEINFO.InterruptMessage = cpu.registers.B
		cpu.registers.A = S_ERROR_NONE
	elseif(command == I_READ_SECTORS) then
		readSectors(cpu.registers.B, cpu.registers.C, cpu.registers.X)
	elseif(command == I_WRITE_SECTORS) then
		writeSectors(cpu.registers.B, cpu.registers.C, cpu.registers.X)
	elseif(command == I_QUERY_MEDIA_QUALITY) then
		if(MEDIAINFO.IsCompliant) then
			cpu.registers.B = 0x7FFF
		else
			cpu.registers.B = 0xFFFF
		end
		cpu.registers.A = S_ERROR_NONE
	end
end

-- TODO
function readSectors(offset, count, destination)
end
-- TODO
function writeSectors(offset, count, source)
end

MODULE = {
	Type = "Hardware",
	Name = "HMD2043",
	Version = "1.1",
	SDescription = "Deprecated HMD2043 hardware device",
	URL = "http://dcputoolcha.in/docs/modules/list/hmd2043.html"
};

HARDWARE = {
	ID = 0x74fa4cae,
	Version = 0x07c2,
	Manufacturer = 0x21544948 -- HAROLD_IT 
};
