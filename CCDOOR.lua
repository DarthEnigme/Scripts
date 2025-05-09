local status = {"<Enter Card>","<Rejected>","<Granted>"}
local current = 1
local combo = "#2077"
local lastTimer
while true do
local event,arg1,arg2,arg3 = os.pullEvent()
if event == "timer" and arg1 == lastTimer then
  current = 1
  lastTimer = nil
  rs.setOutput("top",false)
elseif event == "mag_swipe" then
  if arg1 == combo then
   lastTimer = os.startTimer(5)
   current = 3
   rs.setOutput("top",true)
  else
   lastTimer = os.startTimer(5)
   current = 2
  end
end
end
