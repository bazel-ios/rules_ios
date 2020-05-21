#!/bin/python
import sys, json; 
j = json.load(sys.stdin)
queue = [j]

# Print all leaf nodes of a given json via stdin
while len(queue) > 0:
    entry = queue.pop(0)
    if isinstance(entry, dict):
      for key, value in entry.items():
        queue.append(value)
    else:
      print entry
