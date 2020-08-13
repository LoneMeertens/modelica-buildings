/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  10/7/19
 */
#ifndef Buildings_OutputVariableAllocate_h
#define Buildings_OutputVariableAllocate_h

#include "EnergyPlusFMU.h"
#include "EnergyPlusUtil.h"

/* Create the structure and return a pointer to its address. */
void* OutputVariableAllocate(
  const char* modelicaNameBuilding,
  const char* modelicaNameOutputVariable,
  const char* idfName,
  const char* weaName,
  const char* variableName,
  const char* componentKey,
  int usePrecompiledFMU,
  const char* fmuName,
  const char* spawnLinuxExecutable,
  const int verbosity,
  int printUnit);

#endif
