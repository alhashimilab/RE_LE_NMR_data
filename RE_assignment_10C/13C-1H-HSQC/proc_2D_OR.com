#!/bin/csh

bruk2pipe -verb -in ./ser \
  -bad 0.0 -ext -aswap -AMX -decim 2080 -dspfvs 20 -grpdly 67.9842071533203  \
  -xN              2048  -yN               256  \
  -xT              1024  -yT               128  \
  -xMODE            DQD  -yMODE  Echo-AntiEcho  \
  -xSW         9615.385  -ySW         4528.986  \
  -xOBS         600.133  -yOBS         150.924  \
  -xCAR           4.697  -yCAR         145.364  \
  -xLAB              1H  -yLAB             13C  \
  -ndim               2  -aq2D         Complex  \
| nmrPipe -fn MULT -c 1.95312e-01 \
  -out ./test.fid -ov



nmrPipe -in test.fid                                    \
| nmrPipe  -fn POLY -time                                    \
| nmrPipe  -fn EXT -xn 512 -sw					\
| nmrPipe  -fn SP -off 0.5 -end 0.98 -pow 2 -c 0.5            \
| nmrPipe  -fn ZF -auto                                  \
| nmrPipe  -fn FT                                            \
| nmrPipe  -fn PS -p0 120 -p1 0 -di                          \
| nmrPipe  -fn EXT -xn 15.0ppm -x1 0.0ppm -sw                   \
| nmrPipe  -fn TP                                             \
| nmrPipe  -fn LP -fb -ord 16                                        \
| nmrPipe  -fn SP -off 0.5 -end 1.0 -pow 2 -c 1.0            \
| nmrPipe  -fn ZF -auto                                 \
| nmrPipe  -fn FT                                             \
| nmrPipe  -fn PS -p0 90 -p1 -25 -di                         \
#| nmrPipe  -fn CS -ls 0.813ppm -sw -neg                         \
#| nmrPipe  -fn REV -sw                                        \
| nmrPipe  -fn TP                                             \
| nmrPipe  -fn POLY -auto                                     \
   -out test.ft2 -verb -ov

sleep 2
pipe2ucsf test.ft2 RE22_10C_chsqc.ucsf
ucsfdata -a1 13C RE22_10C_chsqc.ucsf
