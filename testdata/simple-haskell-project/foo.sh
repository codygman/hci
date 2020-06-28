stty -nl echo rows 100 columns 100 sane 2>/dev/null;\
if [ $1 = .. ]; then shift; fi; exec "ghcid"
