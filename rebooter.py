#
# This is the code for my autmoatic rebooter.
#
# Written by mosquito@darlingevil.com, 2021-8-21
#

import os
import sys
import schedule
import time
from datetime import datetime

def get_from_env(v, d):
  if v in os.environ and '' != os.environ[v]:
    return os.environ[v]
  else:
    return d

# Default reboot time is 3AM. For a different time, set WHEN in the environment
WHEN = get_from_env('WHEN', '03:00')

# Interface to watch and flip down/up fi/when it goes offline (default "wlan0")
INTERFACE = get_from_env('INTERFACE', 'wlan0')

# Local router gateway address (the address used to check connectivity)
GATEWAY = get_from_env('GATEWAY', '10.10.10.10')

def reboot():
  print('(' + datetime.now().strftime('%Y-%b-%d %H:%M:%S') + ') Rebooting...')
  sys.stdout.flush() 
  # Reboot immediately without checking whether operations are in progress
  os.system('/bin/systemctl reboot -i')

def reset(interface):
  print('(' + datetime.now().strftime('%Y-%b-%d %H:%M:%S') + ') Network down! Resetting "' + interface + '"...')
  os.system('/usr/sbin/ifdown ' + interface)
  time.sleep(5)
  os.system('/usr/sbin/ifup --force ' + interface)
  time.sleep(5)

schedule.every().day.at(WHEN).do(reboot)

while True:
  result = os.system('/usr/bin/ping -c 4 ' + GATEWAY + ' > /dev/null')
  if 0 != result:
    reset(INTERFACE)
  schedule.run_pending()
  time.sleep(60)

