function run(msg, matches)
		local text1 = matches[2]
        local text2 = matches[3]
		local text3 = matches[4]
		local url = "http://www.keepcalmstudio.com/-/p.php?t=%EE%BB%AA%0D%0AKEEP%0D%0ACALM%0D%0A"..text1.."%0D%0A"..text2.."%0D%0A"..text3.."&bc=E31F17&tc=FFFFFF&cc=FFFFFF&uc=true&ts=true&ff=PNG&w=500&ps=sq"
		 local  file = download_to_file(url,'keep.webp')
			send_document(get_receiver(msg), file, ok_cb, false)

        
end


return {
  description = "تبدیل متن به لوگو",
  usage = {
    "/keep calm font text: ساخت لوگو",
  },
  patterns = {
   "^[/!]([Kk][Ee][Ee][Pp] [Cc][Aa][Ll][Mm]) (.+) (.+) (.+)$",
  },
  run = run
}

