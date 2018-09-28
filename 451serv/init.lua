print("init.lua - 2018-09-14")
majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
print("NodeMCU "..majorVer.."."..minorVer.."."..devVer)
print("ChipID "..chipid.." FlashID "..flashid)
print("Flash: Size "..flashsize.." Mode "..flashmode.." Speed "..flashspeed)
print("-----------------------------------------------------------------------")

stacfg={}
stacfg.ssid="TANGO"
stacfg.pwd="kilo alfa"
wifi.setmode(wifi.STATION)
wifi.sta.config(stacfg)

t = loadfile("tempServ.lua")
t()
-- needs some time to take effect :(
ip = wifi.sta.getip()
print(ip)
