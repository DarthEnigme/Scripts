local reader = peripheral.wrap("Coté ou se trouve le magcard reader")
while true do
reader.beginWrite("#le code que vous désirez","le nom affiché sur la carte")
local event,arg1,arg2,arg3 = os.pullEvent()
if event == "mag_write_done" then
  print("card made")
end
end
