local function pre_process(msg)
  local mutealltime = 'unknown'
  local mutetime = redis:hget ('mutealltime', get_receiver(msg))
  local now = tonumber(os.time())
  local msg_type = 'ALL'
  if mutetime then    
    mutealltime = math.floor((tonumber(mutetime) - tonumber(now)) / 60) + 1
    if tonumber("0") > tonumber(mutealltime) and not is_momod(msg) then
    if is_muted(chat_id, msg_type..': yes') then
          unmute(chat_id, msg_type)
          return "Mute "..msg_type.."  has been disabled"
        else
          return "Mute "..msg_type.." is already disabled"
        end
         end
  if tonumber(mutealltime) == 60 then
    if redis:hget('timemute0',msg.to.id) then return msg end
    send_large_msg(get_receiver(msg), 'one minutes to end the (Mute all) Time !')
    redis:hset('timemute0',msg.to.id,'300')
  end
  if tonumber(mutealltime) == 300 then
    if redis:hget('expires1',msg.to.id) then return msg end
    send_large_msg(get_receiver(msg), 'Five minutes to end the (Mute all) Time !')
    redis:hset('timemute1',msg.to.id,'300')
  end
return msg
end
function run(msg, matches)
  if matches[1]:lower() == 'muteall' then
    if not is_sudo(msg) then return end
    local time = os.time()
    local msg_type = 'ALL'
    local buytime = tonumber(os.time())
    local timeemute = tonumber(buytime) + (tonumber(matches[2]) * 60)
  redis:hset('mutetime',get_receiver(msg),timeemute)
  mute(chat_id, msg_type)
  if not is_muted(chat_id, msg_type..': yes') then
      mute(chat_id, msg_type)
      return "Mute "..msg_type.."  has been enabled"
    else
      return "Mute "..msg_type.." is already on"
   end
  end
  if matches[1]:lower() == 'muteall time' and is_momod(msg) then
    local mutetime = redis:hget ('mutetime', get_receiver(msg))
    if not mutetime then return 'No Expire have been set !' else
      local now = tonumber(os.time())
      return (math.floor((tonumber(mutetime) - tonumber(now)) / 60) + 1) .. " Days letter !"
    end
  end
  
  return {
  patterns = {
    "^[!/]([Mm]uteall) (.*)$",
  "^[!/]([Mm]uteall time)$",
  },
  run = run,
  pre_process = pre_process
}