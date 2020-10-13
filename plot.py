"""=============================================================================
FILE:        plot.py
AUTHOR:      Mat Evans <mat.evans@york.ac.uk>
             Killian Murphy <killian.murphy@york.ac.uk>
DESCRIPTION: Plot DSMACC model outputs for presentation to students.
============================================================================="""

import sys

from matplotlib import pyplot as plt
from matplotlib.ticker import MaxNLocator
import pandas as pd
import pylab

data = pd.read_csv(sys.argv[1], delimiter=",", header=0)
data.columns = data.columns.str.strip()
for COLUMN in data.columns:
    data[COLUMN] = pd.to_numeric(data[COLUMN])

plt.figure(1, figsize=(12, 9))

plt.subplot(451)
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["O3"] / data["M"] * 1e9)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$O_{3} (ppbv)$")
plt.subplots_adjust(
    wspace=0.5, hspace=0.4, left=0.05, top=0.95, right=0.97, bottom=0.06
)
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(452)
max_x = max((data["NO"] + data["NO2"]) / data["M"])
if max_x < 1e-9:
    FACTOR = 1e12
else:
    FACTOR = 1e9

plt.plot(
    data["TIME"] / (24.0 * 60.0 * 60.0),
    (
        data["NO"]
        + data["NO2"]
        + data["NO3"]
        + data["N2O5"] * 2
        + data["HONO"]
        + data["HO2NO2"]
    )
    / data["M"]
    * FACTOR,
    "b",
    label="$NO_{x}$",
)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
if FACTOR == 1e12:
    plt.ylabel("$NO_{x} (pptv)$")
else:
    plt.ylabel("$NO_{x} (ppbv)$")

plt.plot(
    data["TIME"] / (24.0 * 60.0 * 60.0),
    data["NO2"] / data["M"] * FACTOR,
    "g",
    label="$NO_{2}$",
)
plt.plot(
    data["TIME"] / (24.0 * 60.0 * 60.0),
    data["NO"] / data["M"] * FACTOR,
    "r",
    label="$NO$",
)
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))

# ;plt.legend(loc=1,ncol=1)


plt.subplot(453)

max_x = max(data["HNO3"] / data["M"])
if max_x < 1e-9:
    FACTOR = 1e12
else:
    FACTOR = 1e9


plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["HNO3"] / data["M"] * FACTOR)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
if FACTOR == 1e9:
    plt.ylabel("$HNO_{3} (ppbv)$")
else:
    plt.ylabel("$HNO_{3} (pptv)$")

plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(454)
if max(data["PAN"] / data["M"]) > 1e-9:
    FACTOR = 1e9
else:
    FACTOR = 1e12

plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["PAN"] / data["M"] * FACTOR)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
if FACTOR == 1e9:
    plt.ylabel("$PAN (ppbv)$")
else:
    plt.ylabel("$PAN (pptv)$")

plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(455)
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["O"] / data["M"] * 1e9)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$CO (ppbv)$")

plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(456)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["C2H6"] / data["M"] * FACTOR)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$C_{2}H_{6} (ppbv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))

plt.subplot(457)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["C3H8"] / data["M"] * FACTOR)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$C_{3}H_{8} (ppbv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))

plt.subplot(458)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["C3H6"] / data["M"] * FACTOR)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$C_{3}H_{6} (ppbv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(459)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["C5H8"] / data["M"] * 1e9)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$Isoprene (ppbv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))

plt.subplot(4, 5, 10)
FACTOR = 1e9
plt.plot(
    data["TIME"] / (24.0 * 60.0 * 60.0), data["NC4H10"] / data["M"] * FACTOR
)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$C_{4}H_{10} (ppbv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 11)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["OH"] / 1e6)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$OHx10^{6} cm^{-3}$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 12)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["HO2"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$HO_{2} (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 13)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["RO2"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$RO_{2} (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 14)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["NO3"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$NO_{3} (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 15)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["N2O5"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$N_{2}O_{5} (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 16)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["HCHO"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$CH_{2}O (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 17)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["H2O2"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$H_{2}O_{2} (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 18)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["CH3OOH"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$CH_{3}OOH (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 19)
FACTOR = 1e9
plt.plot(data["TIME"] / (24.0 * 60.0 * 60.0), data["CH3CHO"] / data["M"] * 1e12)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("$CH_{3}CHO (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


plt.subplot(4, 5, 20)
FACTOR = 1e9
plt.plot(
    data["TIME"] / (24.0 * 60.0 * 60.0), data["CH3COCH3"] / data["M"] * 1e12
)
plt.xlabel("$Time (days)$")
plt.xticks([0, 1, 2, 3])
plt.ylabel("($CH_{3})_{2}CO (pptv)$")
plt.gca().yaxis.set_major_locator(MaxNLocator(nbins=4))


pylab.savefig(sys.argv[2], format="png", bbox_inches="tight")

plt.close()
