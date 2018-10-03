#!/usr/bin/env python

# -*- coding: utf-8 -*-

import json,sys



with open("/opt/setup/hello-world-task-def.json", "r+") as jsonFile:
    data = json.load(jsonFile)
    tmp = data["containerDefinitions"][0]["image"]
    data["containerDefinitions"][0]["image"] = sys.argv[1]

    jsonFile.seek(0)  # rewind
    json.dump(data, jsonFile)
    jsonFile.truncate()
