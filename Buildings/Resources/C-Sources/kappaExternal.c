#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int nSeg;
    int nTim;
    double* kappaFlat;
} KappaData;

void* kappaConstructor(const char* fileName, const char* matrixName, int nSeg, int nTim) {
    FILE* f;
    KappaData* data;
    int nRow;
    int nCol;
    int i;
    char line[1024];

    data = (KappaData*) malloc(sizeof(KappaData));
    data->nSeg = nSeg;
    data->nTim = nTim;
    data->kappaFlat = (double*) malloc(sizeof(double) * nSeg * nSeg * nTim);

    f = fopen(fileName, "r");
    if (!f) {
        printf("Could not open kappa file: %s\n", fileName);
        exit(1);
    }

    /* Read #1 */
    if (fgets(line, sizeof(line), f) == NULL) {
        printf("Could not read first line of kappa file.\n");
        exit(1);
    }

    /* Read matrix header */
    if (fgets(line, sizeof(line), f) == NULL) {
        printf("Could not read matrix header of kappa file.\n");
        exit(1);
    }

    if (sscanf(line, "double kappaFlat(%d,%d)", &nRow, &nCol) != 2) {
        printf("Could not parse kappa matrix header: %s\n", line);
        exit(1);
    }

    if (nRow != nSeg*nSeg || nCol != nTim) {
        printf("Wrong kappa matrix size. Expected (%d,%d), got (%d,%d)\n",
               nSeg*nSeg, nTim, nRow, nCol);
        exit(1);
    }

    for (i = 0; i < nSeg*nSeg*nTim; i++) {
        if (fscanf(f, "%lf", &(data->kappaFlat[i])) != 1) {
            printf("Could not read kappa value %d\n", i);
            exit(1);
        }
    }

    fclose(f);

    return (void*) data;
}

void kappaDestructor(void* obj) {
    KappaData* data = (KappaData*) obj;

    if (data) {
        if (data->kappaFlat) {
            free(data->kappaFlat);
        }
        free(data);
    }
}

void kappaGetDiag1(void* obj, int nSeg, double* diag) {
    KappaData* data = (KappaData*) obj;
    int s;
    int row;
    int col;
    int index;

    col = 0;

    for (s = 0; s < nSeg; s++) {
        row = s*nSeg + s;
        index = row*data->nTim + col;
        diag[s] = data->kappaFlat[index];
    }
}

void kappaTemporalSuperposition(
    void* obj,
    int nTim,
    int nSeg,
    const double* QAgg_flow,
    int curCel,
    double* deltaTb) {

    KappaData* data = (KappaData*) obj;
    int receiver;
    int source;
    int k;
    int row;
    int kappaIndex;
    int qIndex;

    for (receiver = 0; receiver < nSeg; receiver++) {
        deltaTb[receiver] = 0.0;
    }

    for (k = 0; k < curCel; k++) {
        for (receiver = 0; receiver < nSeg; receiver++) {
            for (source = 0; source < nSeg; source++) {
                row = receiver*nSeg + source;

                /*
                   kappaFlat[row, k] in row-major storage:
                   index = row*nTim + k
                */
                kappaIndex = row*nTim + k;

                /*
                   Modelica passes arrays in column-major order.
                   QAgg_flow[source+1, k+1] index:
                   source + k*nSeg
                */
                qIndex = source + k*nSeg;

                deltaTb[receiver] +=
                    data->kappaFlat[kappaIndex] * QAgg_flow[qIndex];
            }
        }
    }
}
