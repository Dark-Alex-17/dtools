repo-doesnt-have-uncommitted-changes() {
		git diff --quiet && \
		git diff --cached --quiet && \
		git rev-list @{u}..HEAD --quiet
}
