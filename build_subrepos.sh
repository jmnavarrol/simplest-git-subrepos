#/bin/bash
# Creates a "git repos within git repos" structure.
#
# This file is under SCM control; do not edit in-place.

# GLOBALS
readonly SUBREPO_SCRIPT=`basename "$0"`  # the script's name to find deeperly nested repos
readonly REPOLIST='subrepos'             # the list of "subrepos" to clone



# Looks for deeper "subrepo scripts" and runs them
search_subrepos() {
# '-mindepth 2' excludes this script itself from the search results, so it doesn't run in an endless loop
	find . -depth -mindepth 2 -type f -name $SUBREPO_SCRIPT -execdir /bin/bash '{}' \;
}


# Checks out nested repos as needed
# it depends on the REPOLIST file existing and containing a hash, by name 'REPOS', with the list of dirs and repos
build() {
	if [ -r "$REPOLIST" ]; then
		source "$REPOLIST"
		for dir in "${!REPOS[@]}"; do
			echo "DIR: $dir: repo: ${REPOS[$dir]}.";
			if [ ! -d "$dir" ]; then
				echo "$dir doesn't exist: about to clone it..."
				git clone "${REPOS[$dir]}" "$dir" && search_subrepos
			fi
		done
	fi
}



#--
# MAIN
#--
# This script is recursive, so first find deeper instances and run them;
# then, source our own subrepos list and clone them as needed
search_subrepos && build
