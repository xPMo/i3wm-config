#!/usr/bin/env sh
IFS="
" # IFS=$'\n'
#Arguments: program, program's WM_CLASS lookup

# class in $2, else try program name ($1)
class="${2:-$1}"
# root.workspace.container.(nodes+floating_nodes)
con_id=$( i3-msg -t get_tree | jq -f /dev/fd/3 3<<- EOF |
.nodes[].nodes[].nodes[] | (.nodes + .floating_nodes)[] | recurse(.nodes[]) |
select(.window_properties | type=="object") | select(
	(.window_properties.class | contains("$class"))
	or (.window_properties.instance | contains("$class"))
).id
EOF
head -n1 )
if [ -n "${con_id:-}" ]; then
	i3-msg "[con_id=${con_id%% }]" focus
else i3-msg exec exec "$1"; fi
