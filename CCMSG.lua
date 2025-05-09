p = peripheral.wrap("top")
p.clear()
p.setTextScale(5)

text = {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G"
}
     
while true do
	p.clear()
	for k,v in ipairs(text) do
		p.setCursorPos(1,8)
		p.write(v)
		os.sleep(0.5)
		p.scroll(1)
	end
	os.sleep(0.5)
	for i=1,7 do
		p.scroll(1)
		os.sleep(0.5)
	end
end
