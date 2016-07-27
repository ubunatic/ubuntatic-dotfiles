#!/bin/bash
youtube-dl -o "%(title)s.%(ext)s" -x --audio-format mp3 $@

