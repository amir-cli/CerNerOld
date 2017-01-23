function reload_plugins( ) 
  plugins = {} 
  load_plugins() 
end 
   function run(msg, matches) 
    if tonumber (msg.from.id) == 317391435 then--expample 123456789 
       if matches[1]:lower() == "setsudo" then 
          table.insert(_config.sudo_users, tonumber(matches[2])) 
      print(matches[2]..' added to sudo users') 
     save_config() 
     reload_plugins(true) 
      return matches[2]..' <b>added to sudo users</b>' 
   elseif matches[1]:lower() == "remsudo" then 
      table.remove(_config.sudo_users, tonumber(matches[2])) 
      print(matches[2]..' removed from sudo users') 
     save_config() 
     reload_plugins(true) 
      return matches[2]..' <b>removed from sudo users</b>' 
      end 
   end 
end 
return { 
patterns = { 
"^([Ss]etsudo) (%d+)$", 
"^([Rr]emsudo) (%d+)$" 
}, 
run = run 
} 
--By amir 
--Channel @CerNerCH
