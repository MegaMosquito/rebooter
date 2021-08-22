#
# This is the code for my autmoatic rebooter.
#
# Written by mosquito@darlingevil.com, 2021-8-21
#

import os
import sys
import schedule
import time

def get_from_env(v, d):
  if v in os.environ and '' != os.environ[v]:
    return os.environ[v]
  else:
    return d

# Default reboot time is 3AM. For a different time, set WHEN in the environment
when = get_from_env('WHEN', '03:00')

def reboot():
  print("Rebooting...")
  sys.stdout.flush() 
  # Reboot immediately without checking whether operations are in progress
  os.system('systemctl reboot -i')

schedule.every().day.at(when).do(reboot)

while True:
  schedule.run_pending()
  time.sleep(60)

