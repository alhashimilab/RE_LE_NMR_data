#!/bin/csh

bruk2pipe -verb -in ./ser \
  -bad 0.0 -ext -aswap -AMX -decim 1512 -dspfvs 20 -grpdly 67.9875183105469  \
  -xN              3072  -yN              1024  \
  -xT              1409  -yT               512  \
  -xMODE            DQD  -yMODE        Complex  \
  -xSW        13227.513  -ySW        13192.612  \
  -xOBS         600.133  -yOBS         600.133  \
  -xCAR           4.706  -yCAR           4.706  \
  -xLAB             1Hx  -yLAB             1Hy  \
  -ndim               2  -aq2D         Complex  \
| nmrPipe -fn MULT -c 1.95312e-01 \
  -out ./test.fid -ov

nmrPipe -in test.fid                                    \
| nmrPipe  -fn POLY -time                                    \
| nmrPipe  -fn SP -off 0.4 -end 0.98 -pow 2 -c 0.5            \
#| nmrPipe  -fn ZF -size 6144                                  \
| nmrPipe  -fn ZF -auto                                  \
| nmrPipe  -fn FT                                            \
| nmrPipe  -fn PS -p0 135 -p1 0 -di                          \
| nmrPipe  -fn EXT -xn 15.0ppm -x1 1.0ppm -sw                   \
| nmrPipe  -fn TP                                             \
#| nmrPipe  -fn LP -fb -ord 16                                        \
| nmrPipe  -fn SP -off 0.45 -end 1.0 -pow 2 -c 1.0            \
| nmrPipe  -fn ZF -auto                                 \
| nmrPipe  -fn FT -alt                                           \
| nmrPipe  -fn PS -p0 -88 -p1 180 -di                         \
#| nmrPipe  -fn CS -ls 0.813ppm -sw -neg                         \
#| nmrPipe  -fn REV -sw                                        \
| nmrPipe  -fn EXT -xn 15.0ppm -x1 0.0ppm -sw                   \
| nmrPipe  -fn TP                                             \
#| nmrPipe  -fn POLY -auto                                     \
   -out test.ft2 -verb -ov

sleep 2
pipe2ucsf test.ft2 LE_10C_NOESY.ucsf
