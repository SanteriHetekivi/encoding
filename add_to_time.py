import re
import sys
from datetime import datetime
from datetime import timedelta

# Get hours, minutes and seconds from input.
match = re.search(r'([0-9]*)h([0-9]*)m([0-9]*)s', '\n'.join(sys.stdin))
# If it can't parse.
if match is None:
    exit(1)
# Get capture groups from the input.
groups = match.groups()
# If there are not exactly 3 groups.
if len(groups) != 3:
    exit(1)
# Make interval from the capture groups.
interval = timedelta(
    hours=int(groups[0]),
    minutes=int(groups[1]),
    seconds=int(groups[2])
)
if(interval is None):
    exit(1)
time_now = datetime.now()
if(time_now is None):
    exit(1)
complete_time = datetime.now() + interval
if(complete_time is None):
    exit(1)
# Print out current time + interval formatted.
print(complete_time.strftime('%A (%d.%m.%Y) klo %H:%M'))
exit(0)
