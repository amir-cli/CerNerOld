do function run(msg, matches)

   if matches[1]:lower() == 'ربات' then
	  local text ="<i>خرابتم😏</i>"
      return reply_msg(msg.id, text, ok_cb, false)
    end
end
  return {
  description = "",
  usage = "",
  patterns = {
  "^(ربات)$"
    },
  run = run
}
end

--By CerNer Team
