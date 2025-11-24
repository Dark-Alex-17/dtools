if ! (command -v feedgnuplot > /dev/null 2>&1); then
  wget https://raw.githubusercontent.com/dkogan/feedgnuplot/master/bin/feedgnuplot
  chmod +x feedgnuplot
  sudo mv feedgnuplot /usr/local/bin/
fi

 feedgnuplot --lines --stream --xlen ${1:-30} --xlabel 'Second' --terminal 'dumb 180,40' 2> /dev/null
