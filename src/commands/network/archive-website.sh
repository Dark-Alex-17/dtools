# shellcheck disable=SC2154
declare url="${args[--url]}"
# shellcheck disable=SC2154
declare name="${args[--name]}"
# shellcheck disable=SC2154
declare output="${args[--output]}"
# shellcheck disable=SC2154
declare limit="${args[--limit]}"
# shellcheck disable=SC2154
declare behaviors="${args[--behaviors]}"
# shellcheck disable=SC2154
declare exclude="${args[--exclude]}"
# shellcheck disable=SC2154
declare workers="${args[--workers]}"
# shellcheck disable=SC2154
declare wait_until="${args[--wait-until]}"
# shellcheck disable=SC2154
declare keep="${args[--keep]}"
# shellcheck disable=SC2154
declare shm_size="${args[--shm-size]}"

docker run \
  --rm \
  --shm-size="$shm_size" \
  -v "$output":/output \
  ghcr.io/openzim/zimit zimit \
  --url "$url" \
  --name "$name" \
  --output "$output" \
  "${limit:+--limit "$limit"}" \
  --behaviors "$behaviors" \
  "${exclude:+--exclude "$exclude"}" \
  "${workers:+--workers "$workers"}" \
  --wait-until "$wait_until" \
  "${keep:+--keep}"
