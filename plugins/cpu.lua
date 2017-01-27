function run(msg, matches)
if not is_sudo(msg) then
return 
end
text = io.popen("cat /proc/cpuinfo"):read('*all')
  return text
end
return {
  patterns = {
    "^cpu$"
  },
  run = run,
  moderated = true
}