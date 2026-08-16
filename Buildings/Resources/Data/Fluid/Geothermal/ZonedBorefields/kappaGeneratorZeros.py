import numpy as np
import os

nZon = 15
nSegBor = 8
nSegTot = nZon * nSegBor
nTim = 38

file_name = "/home/jovyan/impact/local_projects/Modelica-buildings_7/Buildings/Resources/Data/Fluid/Geothermal/ZonedBorefields/kappaFlat.txt"

kappaFlat = np.zeros((nSegTot*nSegTot, nTim))

os.makedirs(os.path.dirname(file_name), exist_ok=True)

with open(file_name, "w") as f:
    f.write("#1\n")
    f.write(f"double kappaFlat({nSegTot*nSegTot},{nTim})\n")
    np.savetxt(f, kappaFlat, fmt="%.17e")
