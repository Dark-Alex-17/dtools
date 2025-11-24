# shellcheck disable=SC2154
declare min="${args[--min]}"
declare max="${args[--max]}"
declare precision="${args[--precision]}"

awk -v min="$min" -v max="$max" -v precision="$precision" -f - <<-EOF
	BEGIN {
		srand();
		printf "%1.*f\n", precision, min + (max-min) * rand()
	}
	EOF
