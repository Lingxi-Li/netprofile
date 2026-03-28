# Use in gnuplot shell
# call 'plot.gp' '{path-1} {path-2} ...'

set autoscale fix
set offsets graph 0.05, graph 0.05, graph 0.05, graph 0.05

list = ARG1
p for [ts in list] \
  ts u 1:2 w lp t ts, '' u 1:2:2 w labels off 0,1 not