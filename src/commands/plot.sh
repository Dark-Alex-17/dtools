# shellcheck disable=SC2154
declare file="${args[--file]}"
declare type="${args[--type]}"
declare use_gui="${args[--gui]}"
declare stack_vertically="${args[--stack-vertically]}"
declare use_multiplot="${args[--multiplot]}"
declare use_loki="${args[--loki]}"

trap 'rm /dev/shm/tempPlotFile' EXIT

if [[ -z $file ]]; then
  file='-'
fi

cat "$file" > /dev/shm/tempPlotFile
if [[ $use_loki == "1" ]]; then
 loki -m claude:claude-sonnet-4-5-20250929 -e Create a plot of the given values using gnuplot < /dev/shm/tempPlotFile
 exit
fi

multiplot=$(if [[ $(head -1 /dev/shm/tempPlotFile) =~ [0-9]+.+[0-9]+ ]]; then echo "true"; else echo "false"; fi)

if [[ $use_multiplot == 1 && $multiplot != "true" ]]; then
  red_bold "Multiple columns of data are required when using '--multiplot'"
  exit 1
fi

if [[ $type == "line" ]]; then
  if [[ $use_gui == 1 ]]; then
    gnuplot -e "set yrange [0:]; plot '/dev/shm/tempPlotFile' with lines" --persist
  else
    gnuplot -e "set terminal dumb; set yrange [0:]; plot '/dev/shm/tempPlotFile' with lines"
  fi
elif [[ $type == "bar" ]]; then
  if [[ $use_gui == 1 ]]; then
    if [[ $use_multiplot == 1 ]]; then
        if [[ $stack_vertically == 1 ]]; then
          gnuplot -e "set multiplot layout 2,1; set style fill solid; set boxwidth 0.5; set yrange [0:]; plot '/dev/shm/tempPlotFile' using 1 with boxes; plot '/dev/shm/tempPlotFile' using 2 with boxes; unset multiplot" --persist
        else
          gnuplot -e "set style fill solid; set boxwidth 0.5; set yrange [0:]; plot '/dev/shm/tempPlotFile' using (\$0-0.25):1 with boxes ls 1, '/dev/shm/tempPlotFile' using (\$0+0.25):2 with boxes ls 2" --persist
        fi
    else
      gnuplot -e "set style fill solid; set boxwidth 0.5; set yrange [0:]; plot '/dev/shm/tempPlotFile' with boxes" --persist
    fi
  else
    gnuplot -e "set terminal dumb; set yrange [0:]; plot '/dev/shm/tempPlotFile' with boxes"
  fi
fi
rm /dev/shm/tempPlotFile
