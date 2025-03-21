#!/bin/csh

bruk2pipe -in ./ser \
  -bad 0.0 -ext -aswap -AMX -decim 1512 -dspfvs 20 -grpdly 67.9875183105469  \
  -xN              2048  -yN               128  \
  -xT              1024  -yT                64  \
  -xMODE            DQD  -yMODE    States-TPPI  \
  -xSW        13227.513  -ySW         1520.681  \
  -xOBS         600.133  -yOBS          60.820  \
  -xCAR           4.697  -yCAR         155.216  \
  -xLAB              HN  -yLAB             15N  \
  -ndim               2  -aq2D         Complex  \
  -out ./test.fid -verb -ov



nmrPipe -in test.fid                                    \
| nmrPipe  -fn POLY -time                                    \
| nmrPipe  -fn EXT -xn 512 -sw					\
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5            \
| nmrPipe  -fn ZF -auto                                  \
| nmrPipe  -fn FT -auto                                           \
| nmrPipe  -fn PS -p0 -22 -p1 0 -di                          \
| nmrPipe  -fn EXT -xn 15.0ppm -x1 0.0ppm -sw                   \
| nmrPipe  -fn TP                                             \
| nmrPipe  -fn LP -fb -ord 16                                        \
| nmrPipe  -fn SP -off 0.5 -end 1.0 -pow 2 -c 1.0            \
| nmrPipe  -fn ZF -auto                                 \
| nmrPipe  -fn FT -auto                                            \
| nmrPipe  -fn PS -p0 -270 -p1 180 -di                         \
#| nmrPipe  -fn CS -ls 0.813ppm -sw -neg                         \
#| nmrPipe  -fn REV -sw                                        \
| nmrPipe  -fn TP                                             \
| nmrPipe  -fn POLY -auto                                     \
   -out test.ft2 -verb -ov

sleep 2
pipe2ucsf test.ft2 LE26_10C_nhsqc.ucsf
ucsfdata -a1 13C LE26_10C_nhsqc.ucsf
