/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  10/7/2019
 */

#include "OutputVariableFree.h"
#include "EnergyPlusFMU.c"

#include <stdlib.h>

void OutputVariableFree(void* object){
  if (FMU_EP_VERBOSITY >= MEDIUM)
    writeLog("Entered OutputVariableFree.\n");
  if ( object != NULL ){
    FMUOutputVariable* com = (FMUOutputVariable*) object;

    /* Check if there in another Modelica instance that uses this output variable */
    com->count = com->count - 1;
    if (com->count > 0){
      return;
    }

    /* The building may not have been instanciated yet if there was an error during instantiation */
    if (com->ptrBui != NULL){
      com->ptrBui->nOutputVariables--;
      FMUBuildingFree(com->ptrBui);
    }
    if (FMU_EP_VERBOSITY >= MEDIUM)
      writeLog("Calling free in OutputVariableFree.\n");
    free(com);
  }
  if (FMU_EP_VERBOSITY >= MEDIUM)
    writeLog("Leaving OutputVariableFree.c.\n");
}
