local white = Color.new(255,255,255)
local url = "http://astronautlevel2.github.io/Luma3DS/latest.zip"
local zip_path = "/latest.zip"
local config_path = "/updater.cfg"
local a9lh_path = "/arm9loaderhax.bin"
local backup_path = a9lh_path..".bak"

function loadConfig()
	if System.doesFileExist(config_path) then
		local configFile = io.open(config_path, FREAD)
		a9lh_path = io.read(configFile, 0, io.size(configFile))
		backup_path = a9lh_path..".bak"
		io.close(configFile)
	end
end

function unicodify(str)
	local new_str = ""
	for i = 1, #str,1 do
		new_str = new_str..string.sub(str,i,i)..string.char(00)
	end
	return new_str
end

function path_changer()
	local file = io.open(a9lh_path, FREAD)
	local a9lh_data = io.read(file, 0, io.size(file))
	io.close(file)
	local offset = string.find(a9lh_data, "%"..unicodify("arm9loaderhax.bin"))
	local new_path = unicodify(string.sub(a9lh_path,2,-1))
	if #new_path < 74 then
		for i = 1,74-#new_path,1 do
			new_path = new_path..string.char(00)
		end
		local file = io.open(a9lh_path, FWRITE)
		io.write(file, offset-1, new_path, 74)
		io.close(file)
	end
end

function main()
	Screen.refresh()
	Screen.debugPrint(5,5, "Welcome to the Luma3DS updater!", white, TOP_SCREEN)
	Screen.debugPrint(5,20, "Press A to update Luma3DS", white, TOP_SCREEN)
	Screen.debugPrint(5,35, "Press B to restore a Luma3DS backup", white, TOP_SCREEN)
	Screen.debugPrint(5,50, "Press START to go back to HBL/Home menu", white, TOP_SCREEN)
	Screen.debugPrint(5,155, "Thanks to:", white, TOP_SCREEN)
	Screen.debugPrint(5,170, "astronautlevel2 for the builds", white, TOP_SCREEN)
	Screen.debugPrint(5,185, "AuroraWright for her amazing CFW", white, TOP_SCREEN)
	Screen.debugPrint(5,200, "Rinnegatamante for lpp-3ds", white, TOP_SCREEN)
	Screen.debugPrint(5,215, "Hamcha for the idea", white, TOP_SCREEN)
	Screen.waitVblankStart()
	Screen.flip()
	while true do
		pad = Controls.read()
		if pad ~= oldPad then
			oldPad = pad
			if Controls.check(pad,KEY_START) then
				Screen.waitVblankStart()
				Screen.flip()
				System.exit()
			elseif Controls.check(pad,KEY_A) then
				Screen.refresh()
				Screen.clear(TOP_SCREEN)
				if Network.isWifiEnabled() then
					Screen.debugPrint(5,5, "Downloading latest.zip...", white, TOP_SCREEN)
					Network.downloadFile(url, zip_path)
					Screen.debugPrint(5,20, "File downloaded!", white, TOP_SCREEN)
					Screen.debugPrint(5,35, "Backing up arm9loaderhax.bin...", white, TOP_SCREEN)
					System.renameFile(a9lh_path, backup_path)
					Screen.debugPrint(5,50, "Extracting arm9loaderhax.bin from latest.zip", white, TOP_SCREEN)
					System.extractFromZIP(zip_path, "out/arm9loaderhax.bin", a9lh_path)
					Screen.debugPrint(5,65, "Deleting latest.zip...", white, TOP_SCREEN)
					System.deleteFile(zip_path)
					Screen.debugPrint(5,80, "Changing path for reboot patch", white, TOP_SCREEN)
					path_changer()
					Screen.debugPrint(5,95, "Done!", white, TOP_SCREEN)
					Screen.debugPrint(5,110, "Press START to go back to HBL/Home menu", white, TOP_SCREEN)
					while true do
						pad = Controls.read()
						if pad ~= oldPad then
							oldPad = pad
							if Controls.check(pad,KEY_START) then
								Screen.waitVblankStart()
								Screen.flip()
								System.exit()
							end
						end
					end
				else
					Screen.debugPrint(5,5, "WiFi is off! Please turn it on and retry!", white, TOP_SCREEN)
					Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", white, TOP_SCREEN)
					while true do
						pad = Controls.read()
						if pad ~= oldPad then
							oldPad = pad
							if Controls.check(pad,KEY_START) then
								Screen.waitVblankStart()
								Screen.flip()
								System.exit()
							end
						end
					end
				end
			elseif Controls.check(pad,KEY_B) then
				Screen.refresh()
				Screen.clear(TOP_SCREEN)
				if System.doesFileExist(backup_path) then
					Screen.debugPrint(5,5, "Deleting new arm9loaderhax.bin...", white, TOP_SCREEN)
					System.deleteFile(a9lh_path)
					Screen.debugPrint(5,20, "Renaming backup to arm9loaderhax.bin...", white, TOP_SCREEN)
					System.renameFile(backup_path, a9lh_path)
					Screen.debugPrint(5,35, "Press START to go back to HBL/Home menu", white, TOP_SCREEN)
					while true do
						pad = Controls.read()
						if pad ~= oldPad then
							oldPad = pad
							if Controls.check(pad,KEY_START) then
								Screen.waitVblankStart()
								Screen.flip()
								System.exit()
							end
						end
					end
				else
					Screen.debugPrint(5,5, "You don't have a backup to restore", white, TOP_SCREEN)
					Screen.debugPrint(5,20, "Press START to go back to HBL/Home menu", white, TOP_SCREEN)
					while true do
						pad = Controls.read()
						if pad ~= oldPad then
							oldPad = pad
							if Controls.check(pad,KEY_START) then
								Screen.waitVblankStart()
								Screen.flip()
								System.exit()
							end
						end
					end
				end
			end
		end
	end
end

loadConfig()
main()