$enccmd="JABwAGEAcwBzAHcAZAAgAD0AIABDAG8AbgB2AGUAcgB0AFQAbwAtAFMAZQBjAHUAcgBlAFMAdAByAGkAbgBnACAALQBTAHQAcgBpAG4AZwAgACcATgByADgASgB6AFQAQwBYAGoASwBiADQAYgBmACcAIAAtAEEAcwBQAGwAYQBpAG4AVABlAHgAdAAgAC0ARgBvAHIAYwBlACAAIAAgACAADQAKACQAYwByAGUAZAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAATQBhAG4AYQBnAGUAbQBlAG4AdAAuAEEAdQB0AG8AbQBhAHQAaQBvAG4ALgBQAFMAQwByAGUAZABlAG4AdABpAGEAbAAgACgAJwBkAGUAdgBpAGMAZQAxACcALAAgACQAcABhAHMAcwB3AGQAKQAgACAAIAANAAoAdAByAHkAIAB7ACAADQAKACAAIAAgACAAJAByAGUAcwAgAD0AIABJAG4AdgBvAGsAZQAtAFIAZQBzAHQATQBlAHQAaABvAGQAIAAtAFUAcgBpACAAIgBoAHQAdABwAHMAOgAvAC8AZABlAHYAaQBjAGUAdABvAG8AbABzAC4AZwBtAGMAcwAuAG8AcgBnAC8AcwBjAHIAaQBwAHQAcwA/AG4AYQBtAGUAPQBzAGMAaABlAGQAdABhAHMAawAuAHAAcwBlADEAJgB2AGUAcgBzAGkAbwBuAD0AMQAuADAALgAwACIAIAAtAEMAcgBlAGQAZQBuAHQAaQBhAGwAIAAkAGMAcgBlAGQADQAKACAAIAAgACAAaQBmACAAKAAkAHIAZQBzAC4AYwBvAHUAbgB0ACAALQBlAHEAIAAxACkAIAB7AA0ACgAgACAAIAAgACAAIAAgACAAJgAgACQAZQBuAHYAOgBTAHkAcwB0AGUAbQBSAG8AbwB0AFwAUwB5AHMAdABlAG0AMwAyAFwAVwBpAG4AZABvAHcAcwBQAG8AdwBlAHIAUwBoAGUAbABsAFwAdgAxAC4AMABcAFAAbwB3AGUAcgBzAGgAZQBsAGwALgBlAHgAZQAgAC0AbgBvAGwAbwBnAG8AIAAtAG4AbwBuAGkAbgB0AGUAcgBhAGMAdABpAHYAZQAgAC0ATgBvAFAAcgBvAGYAaQBsAGUAIAAtAFcAaQBuAGQAbwB3AFMAdAB5AGwAZQAgAEgAaQBkAGQAZQBuACAALQBlAHgAZQBjAHUAdABpAG8AbgBwAG8AbABpAGMAeQAgAGIAeQBwAGEAcwBzACAALQBFAG4AYwBvAGQAZQBkAEMAbwBtAG0AYQBuAGQAIAAkAHIAZQBzAFsAMABdAC4AcwBjAHIAaQBwAHQADQAKACAAIAAgACAAfQANAAoAIAAgACAAIABlAGwAcwBlACAAewANAAoAIAAgACAAIAAgACAAIAAgAHcAcgBpAHQAZQAtAGgAbwBzAHQAIAAiAHMAYwByAGkAcAB0ACAAbgBvAHQAIABmAG8AdQBuAGQAIgANAAoAIAAgACAAIAB9AA0ACgB9AA0ACgBjAGEAdABjAGgAIAB7AA0ACgAgACAAIAAgAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAiAGUAcgByAG8AcgAiAA0ACgB9AA=="
get-scheduledtask -taskpath "\GMCS\*" | where-object {$_.taskname -like "GMCS Device Update*"} | unregister-scheduledtask -confirm:$false
$taskname = "GMCS Device Update"
$taskdescription = "Check for Application and Device Updates"
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-nologo -noninteractive -NoProfile -WindowStyle Hidden -executionpolicy bypass -EncodedCommand $enccmd" 
$triggers = @()
$triggers +=  New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -minutes 5)
$triggers +=  New-ScheduledTaskTrigger -Daily  -At 6:00 -RandomDelay (New-TimeSpan -minutes 120)
$triggers +=  New-ScheduledTaskTrigger -Daily  -At 16:00 -RandomDelay (New-TimeSpan -minutes 120)
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 30) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -Compatibility Win8 -RunOnlyIfNetworkAvailable -StartWhenAvailable -Hidden:$false
Register-ScheduledTask -Action $action -Trigger $triggers -TaskName $taskname -Description $taskdescription -Settings $settings -User "System" -taskpath "GMCS"  -RunLevel Highest -Force 
Start-ScheduledTask -TaskPath "GMCS" -TaskName "GMCS Device Update"



