# Use in gnuplot shell
# call 'plot.gp' '{path-1} {path-2} ...'

set autoscale fix
set offsets graph 0.05, graph 0.05, graph 0.05, graph 0.05

list = ARG1
plot for [ts in list] \
  ts using 1:2 with lines title ts

# '' using 1:2:2 with labels offset 0,1 notitle