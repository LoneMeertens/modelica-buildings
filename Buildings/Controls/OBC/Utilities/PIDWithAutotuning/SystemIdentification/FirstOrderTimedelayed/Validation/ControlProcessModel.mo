within Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.Validation;
model ControlProcessModel "Test model for ControlProcessModel"
  extends Modelica.Icons.Example;
  Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.ControlProcessModel
    controlProcessModel(yLow=0.1, deaBan=0.05)
    "Calculates the parameters of the system model for the control process"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  CDL.Continuous.Sources.TimeTable ReferenceData(table=[0,1,1,1,0.3,1,1; 0.002,
        1,1,1,0.3,1,1; 0.004,1,1,1,0.3,1,1; 0.006,1,1,1,0.3,1,1; 0.008,1,1,1,
        0.3,1,1; 0.01,1,1,1,0.3,1,1; 0.012,1,1,1,0.3,1,1; 0.014,1,1,1,0.3,1,1;
        0.016,1,1,1,0.3,1,1; 0.018,1,1,1,0.3,1,1; 0.02,1,1,1,0.3,1,1; 0.022,1,1,
        1,0.3,1,1; 0.024,1,1,1,0.3,1,1; 0.026,1,1,1,0.3,1,1; 0.028,1,1,1,0.3,1,
        1; 0.03,1,1,1,0.3,1,1; 0.032,1,1,1,0.3,1,1; 0.034,1,1,1,0.3,1,1; 0.036,
        1,1,1,0.3,1,1; 0.038,1,1,1,0.3,1,1; 0.04,1,1,1,0.3,1,1; 0.042,1,1,1,0.3,
        1,1; 0.044,1,1,1,0.3,1,1; 0.046,1,1,1,0.3,1,1; 0.048,1,1,1,0.3,1,1;
        0.05,1,1,1,0.3,1,1; 0.052,1,1,1,0.3,1,1; 0.054,1,1,1,0.3,1,1; 0.056,1,1,
        1,0.3,1,1; 0.058,1,1,1,0.3,1,1; 0.06,1,1,1,0.3,1,1; 0.062,1,1,1,0.3,1,1;
        0.064,1,1,1,0.3,1,1; 0.066,1,1,1,0.3,1,1; 0.068,1,1,1,0.3,1,1; 0.07,1,1,
        1,0.3,1,1; 0.072,1,1,1,0.3,1,1; 0.074,1,1,1,0.3,1,1; 0.076,1,1,1,0.3,1,
        1; 0.078,1,1,1,0.3,1,1; 0.08,1,1,1,0.3,1,1; 0.082,1,1,1,0.3,1,1; 0.084,
        1,1,1,0.3,1,1; 0.086,1,1,1,0.3,1,1; 0.088,1,1,1,0.3,1,1; 0.09,1,1,1,0.3,
        1,1; 0.092,1,1,1,0.3,1,1; 0.094,1,1,1,0.3,1,1; 0.096,1,1,1,0.3,1,1;
        0.098,1,1,1,0.3,1,1; 0.1,1,1,1,0.3,1,1; 0.1,0.5,1,1,0.5,1,1; 0.1,0.5,1,
        1,0.5,1,1; 0.102,0.5,1,1,0.5,1,1; 0.104,0.5,1,1,0.5,1,1; 0.106,0.5,1,1,
        0.5,1,1; 0.108,0.5,1,1,0.5,1,1; 0.11,0.5,1,1,0.5,1,1; 0.112,0.5,1,1,0.5,
        1,1; 0.114,0.5,1,1,0.5,1,1; 0.116,0.5,1,1,0.5,1,1; 0.118,0.5,1,1,0.5,1,
        1; 0.12,0.5,1,1,0.5,1,1; 0.122,0.5,1,1,0.5,1,1; 0.124,0.5,1,1,0.5,1,1;
        0.126,0.5,1,1,0.5,1,1; 0.128,0.5,1,1,0.5,1,1; 0.13,0.5,1,1,0.5,1,1;
        0.132,0.5,1,1,0.5,1,1; 0.134,0.5,1,1,0.5,1,1; 0.136,0.5,1,1,0.5,1,1;
        0.138,0.5,1,1,0.5,1,1; 0.14,0.5,1,1,0.5,1,1; 0.142,0.5,1,1,0.5,1,1;
        0.144,0.5,1,1,0.5,1,1; 0.146,0.5,1,1,0.5,1,1; 0.148,0.5,1,1,0.5,1,1;
        0.15,0.5,1,1,0.5,1,1; 0.152,0.5,1,1,0.5,1,1; 0.154,0.5,1,1,0.5,1,1;
        0.156,0.5,1,1,0.5,1,1; 0.158,0.5,1,1,0.5,1,1; 0.16,0.5,1,1,0.5,1,1;
        0.162,0.5,1,1,0.5,1,1; 0.164,0.5,1,1,0.5,1,1; 0.166,0.5,1,1,0.5,1,1;
        0.168,0.5,1,1,0.5,1,1; 0.17,0.5,1,1,0.5,1,1; 0.172,0.5,1,1,0.5,1,1;
        0.174,0.5,1,1,0.5,1,1; 0.176,0.5,1,1,0.5,1,1; 0.178,0.5,1,1,0.5,1,1;
        0.18,0.5,1,1,0.5,1,1; 0.182,0.5,1,1,0.5,1,1; 0.184,0.5,1,1,0.5,1,1;
        0.186,0.5,1,1,0.5,1,1; 0.188,0.5,1,1,0.5,1,1; 0.19,0.5,1,1,0.5,1,1;
        0.192,0.5,1,1,0.5,1,1; 0.194,0.5,1,1,0.5,1,1; 0.196,0.5,1,1,0.5,1,1;
        0.198,0.5,1,1,0.5,1,1; 0.2,0.5,1,1,0.5,1,1; 0.202,0.5,1,1,0.5,1,1;
        0.204,0.5,1,1,0.5,1,1; 0.206,0.5,1,1,0.5,1,1; 0.208,0.5,1,1,0.5,1,1;
        0.21,0.5,1,1,0.5,1,1; 0.212,0.5,1,1,0.5,1,1; 0.214,0.5,1,1,0.5,1,1;
        0.216,0.5,1,1,0.5,1,1; 0.218,0.5,1,1,0.5,1,1; 0.22,0.5,1,1,0.5,1,1;
        0.222,0.5,1,1,0.5,1,1; 0.224,0.5,1,1,0.5,1,1; 0.226,0.5,1,1,0.5,1,1;
        0.228,0.5,1,1,0.5,1,1; 0.23,0.5,1,1,0.5,1,1; 0.232,0.5,1,1,0.5,1,1;
        0.234,0.5,1,1,0.5,1,1; 0.236,0.5,1,1,0.5,1,1; 0.238,0.5,1,1,0.5,1,1;
        0.24,0.5,1,1,0.5,1,1; 0.242,0.5,1,1,0.5,1,1; 0.244,0.5,1,1,0.5,1,1;
        0.246,0.5,1,1,0.5,1,1; 0.248,0.5,1,1,0.5,1,1; 0.25,0.5,1,1,0.5,1,1;
        0.252,0.5,1,1,0.5,1,1; 0.254,0.5,1,1,0.5,1,1; 0.256,0.5,1,1,0.5,1,1;
        0.258,0.5,1,1,0.5,1,1; 0.26,0.5,1,1,0.5,1,1; 0.262,0.5,1,1,0.5,1,1;
        0.264,0.5,1,1,0.5,1,1; 0.266,0.5,1,1,0.5,1,1; 0.268,0.5,1,1,0.5,1,1;
        0.27,0.5,1,1,0.5,1,1; 0.272,0.5,1,1,0.5,1,1; 0.274,0.5,1,1,0.5,1,1;
        0.276,0.5,1,1,0.5,1,1; 0.278,0.5,1,1,0.5,1,1; 0.28,0.5,1,1,0.5,1,1;
        0.282,0.5,1,1,0.5,1,1; 0.284,0.5,1,1,0.5,1,1; 0.286,0.5,1,1,0.5,1,1;
        0.288,0.5,1,1,0.5,1,1; 0.29,0.5,1,1,0.5,1,1; 0.292,0.5,1,1,0.5,1,1;
        0.294,0.5,1,1,0.5,1,1; 0.296,0.5,1,1,0.5,1,1; 0.298,0.5,1,1,0.5,1,1;
        0.3,0.5,1,1,0.5,1,1; 0.3,0.5,1,1,0.1,1,1; 0.3,0.5,1,1,0.1,1,1; 0.302,
        0.5,1,1,0.1,1,1; 0.304,0.5,1,1,0.1,1,1; 0.306,0.5,1,1,0.1,1,1; 0.308,
        0.5,1,1,0.1,1,1; 0.31,0.5,1,1,0.1,1,1; 0.312,0.5,1,1,0.1,1,1; 0.314,0.5,
        1,1,0.1,1,1; 0.316,0.5,1,1,0.1,1,1; 0.318,0.5,1,1,0.1,1,1; 0.32,0.5,1,1,
        0.1,1,1; 0.322,0.5,1,1,0.1,1,1; 0.324,0.5,1,1,0.1,1,1; 0.326,0.5,1,1,
        0.1,1,1; 0.328,0.5,1,1,0.1,1,1; 0.33,0.5,1,1,0.1,1,1; 0.332,0.5,1,1,0.1,
        1,1; 0.334,0.5,1,1,0.1,1,1; 0.336,0.5,1,1,0.1,1,1; 0.338,0.5,1,1,0.1,1,
        1; 0.34,0.5,1,1,0.1,1,1; 0.342,0.5,1,1,0.1,1,1; 0.344,0.5,1,1,0.1,1,1;
        0.346,0.5,1,1,0.1,1,1; 0.348,0.5,1,1,0.1,1,1; 0.35,0.5,1,1,0.1,1,1;
        0.352,0.5,1,1,0.1,1,1; 0.354,0.5,1,1,0.1,1,1; 0.356,0.5,1,1,0.1,1,1;
        0.358,0.5,1,1,0.1,1,1; 0.36,0.5,1,1,0.1,1,1; 0.362,0.5,1,1,0.1,1,1;
        0.364,0.5,1,1,0.1,1,1; 0.366,0.5,1,1,0.1,1,1; 0.368,0.5,1,1,0.1,1,1;
        0.37,0.5,1,1,0.1,1,1; 0.372,0.5,1,1,0.1,1,1; 0.374,0.5,1,1,0.1,1,1;
        0.376,0.5,1,1,0.1,1,1; 0.378,0.5,1,1,0.1,1,1; 0.38,0.5,1,1,0.1,1,1;
        0.382,0.5,1,1,0.1,1,1; 0.384,0.5,1,1,0.1,1,1; 0.386,0.5,1,1,0.1,1,1;
        0.388,0.5,1,1,0.1,1,1; 0.39,0.5,1,1,0.1,1,1; 0.392,0.5,1,1,0.1,1,1;
        0.394,0.5,1,1,0.1,1,1; 0.396,0.5,1,1,0.1,1,1; 0.398,0.5,1,1,0.1,1,1;
        0.4,0.5,1,1,0.1,1,1; 0.402,0.5,1,1,0.1,1,1; 0.404,0.5,1,1,0.1,1,1;
        0.406,0.5,1,1,0.1,1,1; 0.408,0.5,1,1,0.1,1,1; 0.41,0.5,1,1,0.1,1,1;
        0.412,0.5,1,1,0.1,1,1; 0.414,0.5,1,1,0.1,1,1; 0.416,0.5,1,1,0.1,1,1;
        0.418,0.5,1,1,0.1,1,1; 0.42,0.5,1,1,0.1,1,1; 0.422,0.5,1,1,0.1,1,1;
        0.424,0.5,1,1,0.1,1,1; 0.426,0.5,1,1,0.1,1,1; 0.428,0.5,1,1,0.1,1,1;
        0.43,0.5,1,1,0.1,1,1; 0.432,0.5,1,1,0.1,1,1; 0.434,0.5,1,1,0.1,1,1;
        0.436,0.5,1,1,0.1,1,1; 0.438,0.5,1,1,0.1,1,1; 0.44,0.5,1,1,0.1,1,1;
        0.442,0.5,1,1,0.1,1,1; 0.444,0.5,1,1,0.1,1,1; 0.446,0.5,1,1,0.1,1,1;
        0.448,0.5,1,1,0.1,1,1; 0.45,0.5,1,1,0.1,1,1; 0.452,0.5,1,1,0.1,1,1;
        0.454,0.5,1,1,0.1,1,1; 0.456,0.5,1,1,0.1,1,1; 0.458,0.5,1,1,0.1,1,1;
        0.46,0.5,1,1,0.1,1,1; 0.462,0.5,1,1,0.1,1,1; 0.464,0.5,1,1,0.1,1,1;
        0.466,0.5,1,1,0.1,1,1; 0.468,0.5,1,1,0.1,1,1; 0.47,0.5,1,1,0.1,1,1;
        0.472,0.5,1,1,0.1,1,1; 0.474,0.5,1,1,0.1,1,1; 0.476,0.5,1,1,0.1,1,1;
        0.478,0.5,1,1,0.1,1,1; 0.48,0.5,1,1,0.1,1,1; 0.482,0.5,1,1,0.1,1,1;
        0.484,0.5,1,1,0.1,1,1; 0.486,0.5,1,1,0.1,1,1; 0.488,0.5,1,1,0.1,1,1;
        0.49,0.5,1,1,0.1,1,1; 0.492,0.5,1,1,0.1,1,1; 0.494,0.5,1,1,0.1,1,1;
        0.496,0.5,1,1,0.1,1,1; 0.498,0.5,1,1,0.1,1,1; 0.5,0.5,1,1,0.1,1,1;
        0.502,0.5,1,1,0.1,1,1; 0.504,0.5,1,1,0.1,1,1; 0.506,0.5,1,1,0.1,1,1;
        0.508,0.5,1,1,0.1,1,1; 0.51,0.5,1,1,0.1,1,1; 0.512,0.5,1,1,0.1,1,1;
        0.514,0.5,1,1,0.1,1,1; 0.516,0.5,1,1,0.1,1,1; 0.518,0.5,1,1,0.1,1,1;
        0.52,0.5,1,1,0.1,1,1; 0.522,0.5,1,1,0.1,1,1; 0.524,0.5,1,1,0.1,1,1;
        0.526,0.5,1,1,0.1,1,1; 0.528,0.5,1,1,0.1,1,1; 0.53,0.5,1,1,0.1,1,1;
        0.532,0.5,1,1,0.1,1,1; 0.534,0.5,1,1,0.1,1,1; 0.536,0.5,1,1,0.1,1,1;
        0.538,0.5,1,1,0.1,1,1; 0.54,0.5,1,1,0.1,1,1; 0.542,0.5,1,1,0.1,1,1;
        0.544,0.5,1,1,0.1,1,1; 0.546,0.5,1,1,0.1,1,1; 0.548,0.5,1,1,0.1,1,1;
        0.55,0.5,1,1,0.1,1,1; 0.552,0.5,1,1,0.1,1,1; 0.554,0.5,1,1,0.1,1,1;
        0.556,0.5,1,1,0.1,1,1; 0.558,0.5,1,1,0.1,1,1; 0.56,0.5,1,1,0.1,1,1;
        0.562,0.5,1,1,0.1,1,1; 0.564,0.5,1,1,0.1,1,1; 0.566,0.5,1,1,0.1,1,1;
        0.568,0.5,1,1,0.1,1,1; 0.57,0.5,1,1,0.1,1,1; 0.572,0.5,1,1,0.1,1,1;
        0.574,0.5,1,1,0.1,1,1; 0.576,0.5,1,1,0.1,1,1; 0.578,0.5,1,1,0.1,1,1;
        0.58,0.5,1,1,0.1,1,1; 0.582,0.5,1,1,0.1,1,1; 0.584,0.5,1,1,0.1,1,1;
        0.586,0.5,1,1,0.1,1,1; 0.588,0.5,1,1,0.1,1,1; 0.59,0.5,1,1,0.1,1,1;
        0.592,0.5,1,1,0.1,1,1; 0.594,0.5,1,1,0.1,1,1; 0.596,0.5,1,1,0.1,1,1;
        0.598,0.5,1,1,0.1,1,1; 0.6,0.5,1,1,0.1,1,1; 0.602,0.5,1,1,0.1,1,1;
        0.604,0.5,1,1,0.1,1,1; 0.606,0.5,1,1,0.1,1,1; 0.608,0.5,1,1,0.1,1,1;
        0.61,0.5,1,1,0.1,1,1; 0.612,0.5,1,1,0.1,1,1; 0.614,0.5,1,1,0.1,1,1;
        0.616,0.5,1,1,0.1,1,1; 0.618,0.5,1,1,0.1,1,1; 0.62,0.5,1,1,0.1,1,1;
        0.622,0.5,1,1,0.1,1,1; 0.624,0.5,1,1,0.1,1,1; 0.626,0.5,1,1,0.1,1,1;
        0.628,0.5,1,1,0.1,1,1; 0.63,0.5,1,1,0.1,1,1; 0.632,0.5,1,1,0.1,1,1;
        0.634,0.5,1,1,0.1,1,1; 0.636,0.5,1,1,0.1,1,1; 0.638,0.5,1,1,0.1,1,1;
        0.64,0.5,1,1,0.1,1,1; 0.642,0.5,1,1,0.1,1,1; 0.644,0.5,1,1,0.1,1,1;
        0.646,0.5,1,1,0.1,1,1; 0.648,0.5,1,1,0.1,1,1; 0.65,0.5,1,1,0.1,1,1;
        0.652,0.5,1,1,0.1,1,1; 0.654,0.5,1,1,0.1,1,1; 0.656,0.5,1,1,0.1,1,1;
        0.658,0.5,1,1,0.1,1,1; 0.66,0.5,1,1,0.1,1,1; 0.662,0.5,1,1,0.1,1,1;
        0.664,0.5,1,1,0.1,1,1; 0.666,0.5,1,1,0.1,1,1; 0.668,0.5,1,1,0.1,1,1;
        0.67,0.5,1,1,0.1,1,1; 0.672,0.5,1,1,0.1,1,1; 0.674,0.5,1,1,0.1,1,1;
        0.676,0.5,1,1,0.1,1,1; 0.678,0.5,1,1,0.1,1,1; 0.68,0.5,1,1,0.1,1,1;
        0.682,0.5,1,1,0.1,1,1; 0.684,0.5,1,1,0.1,1,1; 0.686,0.5,1,1,0.1,1,1;
        0.688,0.5,1,1,0.1,1,1; 0.69,0.5,1,1,0.1,1,1; 0.692,0.5,1,1,0.1,1,1;
        0.694,0.5,1,1,0.1,1,1; 0.696,0.5,1,1,0.1,1,1; 0.698,0.5,1,1,0.1,1,1;
        0.7,0.5,1,1,0.1,1,1; 0.7,0.5,1,3,0.5,0.762,0.762; 0.7,0.5,1,3,0.5,0.762,
        0.762; 0.702,0.5,1,3,0.5,0.762,0.762; 0.704,0.5,1,3,0.5,0.762,0.762;
        0.706,0.5,1,3,0.5,0.762,0.762; 0.708,0.5,1,3,0.5,0.762,0.762; 0.71,0.5,
        1,3,0.5,0.762,0.762; 0.712,0.5,1,3,0.5,0.762,0.762; 0.714,0.5,1,3,0.5,
        0.762,0.762; 0.716,0.5,1,3,0.5,0.762,0.762; 0.718,0.5,1,3,0.5,0.762,
        0.762; 0.72,0.5,1,3,0.5,0.762,0.762; 0.722,0.5,1,3,0.5,0.762,0.762;
        0.724,0.5,1,3,0.5,0.762,0.762; 0.726,0.5,1,3,0.5,0.762,0.762; 0.728,0.5,
        1,3,0.5,0.762,0.762; 0.73,0.5,1,3,0.5,0.762,0.762; 0.732,0.5,1,3,0.5,
        0.762,0.762; 0.734,0.5,1,3,0.5,0.762,0.762; 0.736,0.5,1,3,0.5,0.762,
        0.762; 0.738,0.5,1,3,0.5,0.762,0.762; 0.74,0.5,1,3,0.5,0.762,0.762;
        0.742,0.5,1,3,0.5,0.762,0.762; 0.744,0.5,1,3,0.5,0.762,0.762; 0.746,0.5,
        1,3,0.5,0.762,0.762; 0.748,0.5,1,3,0.5,0.762,0.762; 0.75,0.5,1,3,0.5,
        0.762,0.762; 0.752,0.5,1,3,0.5,0.762,0.762; 0.754,0.5,1,3,0.5,0.762,
        0.762; 0.756,0.5,1,3,0.5,0.762,0.762; 0.758,0.5,1,3,0.5,0.762,0.762;
        0.76,0.5,1,3,0.5,0.762,0.762; 0.762,0.5,1,3,0.5,0.762,0.762; 0.764,0.5,
        1,3,0.5,0.762,0.762; 0.766,0.5,1,3,0.5,0.762,0.762; 0.768,0.5,1,3,0.5,
        0.762,0.762; 0.77,0.5,1,3,0.5,0.762,0.762; 0.772,0.5,1,3,0.5,0.762,
        0.762; 0.774,0.5,1,3,0.5,0.762,0.762; 0.776,0.5,1,3,0.5,0.762,0.762;
        0.778,0.5,1,3,0.5,0.762,0.762; 0.78,0.5,1,3,0.5,0.762,0.762; 0.782,0.5,
        1,3,0.5,0.762,0.762; 0.784,0.5,1,3,0.5,0.762,0.762; 0.786,0.5,1,3,0.5,
        0.762,0.762; 0.788,0.5,1,3,0.5,0.762,0.762; 0.79,0.5,1,3,0.5,0.762,
        0.762; 0.792,0.5,1,3,0.5,0.762,0.762; 0.794,0.5,1,3,0.5,0.762,0.762;
        0.796,0.5,1,3,0.5,0.762,0.762; 0.798,0.5,1,3,0.5,0.762,0.762; 0.8,0.5,1,
        3,0.5,0.762,0.762; 0.802,0.5,1,3,0.5,0.762,0.762; 0.804,0.5,1,3,0.5,
        0.762,0.762; 0.806,0.5,1,3,0.5,0.762,0.762; 0.808,0.5,1,3,0.5,0.762,
        0.762; 0.81,0.5,1,3,0.5,0.762,0.762; 0.812,0.5,1,3,0.5,0.762,0.762;
        0.814,0.5,1,3,0.5,0.762,0.762; 0.816,0.5,1,3,0.5,0.762,0.762; 0.818,0.5,
        1,3,0.5,0.762,0.762; 0.82,0.5,1,3,0.5,0.762,0.762; 0.822,0.5,1,3,0.5,
        0.762,0.762; 0.824,0.5,1,3,0.5,0.762,0.762; 0.826,0.5,1,3,0.5,0.762,
        0.762; 0.828,0.5,1,3,0.5,0.762,0.762; 0.83,0.5,1,3,0.5,0.762,0.762;
        0.83,1,1,3,0.8,0.762,0.762; 0.83,1,1,3,0.8,0.762,0.762; 0.832,1,1,3,0.8,
        0.762,0.762; 0.834,1,1,3,0.8,0.762,0.762; 0.836,1,1,3,0.8,0.762,0.762;
        0.838,1,1,3,0.8,0.762,0.762; 0.84,1,1,3,0.8,0.762,0.762; 0.842,1,1,3,
        0.8,0.762,0.762; 0.844,1,1,3,0.8,0.762,0.762; 0.846,1,1,3,0.8,0.762,
        0.762; 0.848,1,1,3,0.8,0.762,0.762; 0.85,1,1,3,0.8,0.762,0.762; 0.85,1,
        2,3,0.5,0.762,0.762; 0.85,1,2,3,0.5,0.762,0.762; 0.852,1,2,3,0.5,0.762,
        0.762; 0.854,1,2,3,0.5,0.762,0.762; 0.856,1,2,3,0.5,0.762,0.762; 0.858,
        1,2,3,0.5,0.762,0.762; 0.86,1,2,3,0.5,0.762,0.762; 0.862,1,2,3,0.5,
        0.762,0.762; 0.864,1,2,3,0.5,0.762,0.762; 0.866,1,2,3,0.5,0.762,0.762;
        0.868,1,2,3,0.5,0.762,0.762; 0.87,1,2,3,0.5,0.762,0.762; 0.872,1,2,3,
        0.5,0.762,0.762; 0.874,1,2,3,0.5,0.762,0.762; 0.876,1,2,3,0.5,0.762,
        0.762; 0.878,1,2,3,0.5,0.762,0.762; 0.88,1,2,3,0.5,0.762,0.762; 0.882,1,
        2,3,0.5,0.762,0.762; 0.884,1,2,3,0.5,0.762,0.762; 0.886,1,2,3,0.5,0.762,
        0.762; 0.888,1,2,3,0.5,0.762,0.762; 0.89,1,2,3,0.5,0.762,0.762; 0.892,1,
        2,3,0.5,0.762,0.762; 0.894,1,2,3,0.5,0.762,0.762; 0.896,1,2,3,0.5,0.762,
        0.762; 0.898,1,2,3,0.5,0.762,0.762; 0.9,1,2,3,0.5,0.762,0.762; 0.902,1,
        2,3,0.5,0.762,0.762; 0.904,1,2,3,0.5,0.762,0.762; 0.906,1,2,3,0.5,0.762,
        0.762; 0.908,1,2,3,0.5,0.762,0.762; 0.91,1,2,3,0.5,0.762,0.762; 0.912,1,
        2,3,0.5,0.762,0.762; 0.914,1,2,3,0.5,0.762,0.762; 0.916,1,2,3,0.5,0.762,
        0.762; 0.918,1,2,3,0.5,0.762,0.762; 0.92,1,2,3,0.5,0.762,0.762; 0.922,1,
        2,3,0.5,0.762,0.762; 0.924,1,2,3,0.5,0.762,0.762; 0.926,1,2,3,0.5,0.762,
        0.762; 0.928,1,2,3,0.5,0.762,0.762; 0.93,1,2,3,0.5,0.762,0.762; 0.932,1,
        2,3,0.5,0.762,0.762; 0.934,1,2,3,0.5,0.762,0.762; 0.936,1,2,3,0.5,0.762,
        0.762; 0.938,1,2,3,0.5,0.762,0.762; 0.94,1,2,3,0.5,0.762,0.762; 0.942,1,
        2,3,0.5,0.762,0.762; 0.944,1,2,3,0.5,0.762,0.762; 0.946,1,2,3,0.5,0.762,
        0.762; 0.948,1,2,3,0.5,0.762,0.762; 0.95,1,2,3,0.5,0.762,0.762; 0.952,1,
        2,3,0.5,0.762,0.762; 0.954,1,2,3,0.5,0.762,0.762; 0.956,1,2,3,0.5,0.762,
        0.762; 0.958,1,2,3,0.5,0.762,0.762; 0.96,1,2,3,0.5,0.762,0.762; 0.962,1,
        2,3,0.5,0.762,0.762; 0.964,1,2,3,0.5,0.762,0.762; 0.966,1,2,3,0.5,0.762,
        0.762; 0.968,1,2,3,0.5,0.762,0.762; 0.97,1,2,3,0.5,0.762,0.762; 0.972,1,
        2,3,0.5,0.762,0.762; 0.974,1,2,3,0.5,0.762,0.762; 0.976,1,2,3,0.5,0.762,
        0.762; 0.978,1,2,3,0.5,0.762,0.762; 0.98,1,2,3,0.5,0.762,0.762; 0.982,1,
        2,3,0.5,0.762,0.762; 0.984,1,2,3,0.5,0.762,0.762; 0.986,1,2,3,0.5,0.762,
        0.762; 0.988,1,2,3,0.5,0.762,0.762; 0.99,1,2,3,0.5,0.762,0.762; 0.992,1,
        2,3,0.5,0.762,0.762; 0.994,1,2,3,0.5,0.762,0.762; 0.996,1,2,3,0.5,0.762,
        0.762; 0.998,1,2,3,0.5,0.762,0.762; 1,1,2,3,0.5,0.762,0.762],
      extrapolation=Buildings.Controls.OBC.CDL.Types.Extrapolation.HoldLastPoint)
    "Data for validating the controlProcessModel block"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  CDL.Logical.Sources.TimeTable ReferenceBoolData(table=[0,0,0; 0.002,0,0;
        0.004,0,0; 0.006,0,0; 0.008,0,0; 0.01,0,0; 0.012,0,0; 0.014,0,0; 0.016,
        0,0; 0.018,0,0; 0.02,0,0; 0.022,0,0; 0.024,0,0; 0.026,0,0; 0.028,0,0;
        0.03,0,0; 0.032,0,0; 0.034,0,0; 0.036,0,0; 0.038,0,0; 0.04,0,0; 0.042,0,
        0; 0.044,0,0; 0.046,0,0; 0.048,0,0; 0.05,0,0; 0.052,0,0; 0.054,0,0;
        0.056,0,0; 0.058,0,0; 0.06,0,0; 0.062,0,0; 0.064,0,0; 0.066,0,0; 0.068,
        0,0; 0.07,0,0; 0.072,0,0; 0.074,0,0; 0.076,0,0; 0.078,0,0; 0.08,0,0;
        0.082,0,0; 0.084,0,0; 0.086,0,0; 0.088,0,0; 0.09,0,0; 0.092,0,0; 0.094,
        0,0; 0.096,0,0; 0.098,0,0; 0.1,0,0; 0.1,0,0; 0.1,0,0; 0.102,0,0; 0.104,
        0,0; 0.106,0,0; 0.108,0,0; 0.11,0,0; 0.112,0,0; 0.114,0,0; 0.116,0,0;
        0.118,0,0; 0.12,0,0; 0.122,0,0; 0.124,0,0; 0.126,0,0; 0.128,0,0; 0.13,0,
        0; 0.132,0,0; 0.134,0,0; 0.136,0,0; 0.138,0,0; 0.14,0,0; 0.142,0,0;
        0.144,0,0; 0.146,0,0; 0.148,0,0; 0.15,0,0; 0.152,0,0; 0.154,0,0; 0.156,
        0,0; 0.158,0,0; 0.16,0,0; 0.162,0,0; 0.164,0,0; 0.166,0,0; 0.168,0,0;
        0.17,0,0; 0.172,0,0; 0.174,0,0; 0.176,0,0; 0.178,0,0; 0.18,0,0; 0.182,0,
        0; 0.184,0,0; 0.186,0,0; 0.188,0,0; 0.19,0,0; 0.192,0,0; 0.194,0,0;
        0.196,0,0; 0.198,0,0; 0.2,0,0; 0.202,0,0; 0.204,0,0; 0.206,0,0; 0.208,0,
        0; 0.21,0,0; 0.212,0,0; 0.214,0,0; 0.216,0,0; 0.218,0,0; 0.22,0,0;
        0.222,0,0; 0.224,0,0; 0.226,0,0; 0.228,0,0; 0.23,0,0; 0.232,0,0; 0.234,
        0,0; 0.236,0,0; 0.238,0,0; 0.24,0,0; 0.242,0,0; 0.244,0,0; 0.246,0,0;
        0.248,0,0; 0.25,0,0; 0.252,0,0; 0.254,0,0; 0.256,0,0; 0.258,0,0; 0.26,0,
        0; 0.262,0,0; 0.264,0,0; 0.266,0,0; 0.268,0,0; 0.27,0,0; 0.272,0,0;
        0.274,0,0; 0.276,0,0; 0.278,0,0; 0.28,0,0; 0.282,0,0; 0.284,0,0; 0.286,
        0,0; 0.288,0,0; 0.29,0,0; 0.292,0,0; 0.294,0,0; 0.296,0,0; 0.298,0,0;
        0.3,0,0; 0.3,1,0; 0.3,1,0; 0.302,1,0; 0.304,1,0; 0.306,1,0; 0.308,1,0;
        0.31,1,0; 0.312,1,0; 0.314,1,0; 0.316,1,0; 0.318,1,0; 0.32,1,0; 0.322,1,
        0; 0.324,1,0; 0.326,1,0; 0.328,1,0; 0.33,1,0; 0.332,1,0; 0.334,1,0;
        0.336,1,0; 0.338,1,0; 0.34,1,0; 0.342,1,0; 0.344,1,0; 0.346,1,0; 0.348,
        1,0; 0.35,1,0; 0.352,1,0; 0.354,1,0; 0.356,1,0; 0.358,1,0; 0.36,1,0;
        0.362,1,0; 0.364,1,0; 0.366,1,0; 0.368,1,0; 0.37,1,0; 0.372,1,0; 0.374,
        1,0; 0.376,1,0; 0.378,1,0; 0.38,1,0; 0.382,1,0; 0.384,1,0; 0.386,1,0;
        0.388,1,0; 0.39,1,0; 0.392,1,0; 0.394,1,0; 0.396,1,0; 0.398,1,0; 0.4,1,
        0; 0.402,1,0; 0.404,1,0; 0.406,1,0; 0.408,1,0; 0.41,1,0; 0.412,1,0;
        0.414,1,0; 0.416,1,0; 0.418,1,0; 0.42,1,0; 0.422,1,0; 0.424,1,0; 0.426,
        1,0; 0.428,1,0; 0.43,1,0; 0.432,1,0; 0.434,1,0; 0.436,1,0; 0.438,1,0;
        0.44,1,0; 0.442,1,0; 0.444,1,0; 0.446,1,0; 0.448,1,0; 0.45,1,0; 0.452,1,
        0; 0.454,1,0; 0.456,1,0; 0.458,1,0; 0.46,1,0; 0.462,1,0; 0.464,1,0;
        0.466,1,0; 0.468,1,0; 0.47,1,0; 0.472,1,0; 0.474,1,0; 0.476,1,0; 0.478,
        1,0; 0.48,1,0; 0.482,1,0; 0.484,1,0; 0.486,1,0; 0.488,1,0; 0.49,1,0;
        0.492,1,0; 0.494,1,0; 0.496,1,0; 0.498,1,0; 0.5,1,0; 0.502,1,0; 0.504,1,
        0; 0.506,1,0; 0.508,1,0; 0.51,1,0; 0.512,1,0; 0.514,1,0; 0.516,1,0;
        0.518,1,0; 0.52,1,0; 0.522,1,0; 0.524,1,0; 0.526,1,0; 0.528,1,0; 0.53,1,
        0; 0.532,1,0; 0.534,1,0; 0.536,1,0; 0.538,1,0; 0.54,1,0; 0.542,1,0;
        0.544,1,0; 0.546,1,0; 0.548,1,0; 0.55,1,0; 0.552,1,0; 0.554,1,0; 0.556,
        1,0; 0.558,1,0; 0.56,1,0; 0.562,1,0; 0.564,1,0; 0.566,1,0; 0.568,1,0;
        0.57,1,0; 0.572,1,0; 0.574,1,0; 0.576,1,0; 0.578,1,0; 0.58,1,0; 0.582,1,
        0; 0.584,1,0; 0.586,1,0; 0.588,1,0; 0.59,1,0; 0.592,1,0; 0.594,1,0;
        0.596,1,0; 0.598,1,0; 0.6,1,0; 0.602,1,0; 0.604,1,0; 0.606,1,0; 0.608,1,
        0; 0.61,1,0; 0.612,1,0; 0.614,1,0; 0.616,1,0; 0.618,1,0; 0.62,1,0;
        0.622,1,0; 0.624,1,0; 0.626,1,0; 0.628,1,0; 0.63,1,0; 0.632,1,0; 0.634,
        1,0; 0.636,1,0; 0.638,1,0; 0.64,1,0; 0.642,1,0; 0.644,1,0; 0.646,1,0;
        0.648,1,0; 0.65,1,0; 0.652,1,0; 0.654,1,0; 0.656,1,0; 0.658,1,0; 0.66,1,
        0; 0.662,1,0; 0.664,1,0; 0.666,1,0; 0.668,1,0; 0.67,1,0; 0.672,1,0;
        0.674,1,0; 0.676,1,0; 0.678,1,0; 0.68,1,0; 0.682,1,0; 0.684,1,0; 0.686,
        1,0; 0.688,1,0; 0.69,1,0; 0.692,1,0; 0.694,1,0; 0.696,1,0; 0.698,1,0;
        0.7,1,0; 0.7,1,1; 0.7,1,1; 0.702,1,1; 0.704,1,1; 0.706,1,1; 0.708,1,1;
        0.71,1,1; 0.712,1,1; 0.714,1,1; 0.716,1,1; 0.718,1,1; 0.72,1,1; 0.722,1,
        1; 0.724,1,1; 0.726,1,1; 0.728,1,1; 0.73,1,1; 0.732,1,1; 0.734,1,1;
        0.736,1,1; 0.738,1,1; 0.74,1,1; 0.742,1,1; 0.744,1,1; 0.746,1,1; 0.748,
        1,1; 0.75,1,1; 0.752,1,1; 0.754,1,1; 0.756,1,1; 0.758,1,1; 0.76,1,1;
        0.762,1,1; 0.764,1,1; 0.766,1,1; 0.768,1,1; 0.77,1,1; 0.772,1,1; 0.774,
        1,1; 0.776,1,1; 0.778,1,1; 0.78,1,1; 0.782,1,1; 0.784,1,1; 0.786,1,1;
        0.788,1,1; 0.79,1,1; 0.792,1,1; 0.794,1,1; 0.796,1,1; 0.798,1,1; 0.8,1,
        1; 0.802,1,1; 0.804,1,1; 0.806,1,1; 0.808,1,1; 0.81,1,1; 0.812,1,1;
        0.814,1,1; 0.816,1,1; 0.818,1,1; 0.82,1,1; 0.822,1,1; 0.824,1,1; 0.826,
        1,1; 0.828,1,1; 0.83,1,1; 0.83,1,1; 0.83,1,1; 0.832,1,1; 0.834,1,1;
        0.836,1,1; 0.838,1,1; 0.84,1,1; 0.842,1,1; 0.844,1,1; 0.846,1,1; 0.848,
        1,1; 0.85,1,1; 0.85,1,1; 0.85,1,1; 0.852,1,1; 0.854,1,1; 0.856,1,1;
        0.858,1,1; 0.86,1,1; 0.862,1,1; 0.864,1,1; 0.866,1,1; 0.868,1,1; 0.87,1,
        1; 0.872,1,1; 0.874,1,1; 0.876,1,1; 0.878,1,1; 0.88,1,1; 0.882,1,1;
        0.884,1,1; 0.886,1,1; 0.888,1,1; 0.89,1,1; 0.892,1,1; 0.894,1,1; 0.896,
        1,1; 0.898,1,1; 0.9,1,1; 0.902,1,1; 0.904,1,1; 0.906,1,1; 0.908,1,1;
        0.91,1,1; 0.912,1,1; 0.914,1,1; 0.916,1,1; 0.918,1,1; 0.92,1,1; 0.922,1,
        1; 0.924,1,1; 0.926,1,1; 0.928,1,1; 0.93,1,1; 0.932,1,1; 0.934,1,1;
        0.936,1,1; 0.938,1,1; 0.94,1,1; 0.942,1,1; 0.944,1,1; 0.946,1,1; 0.948,
        1,1; 0.95,1,1; 0.952,1,1; 0.954,1,1; 0.956,1,1; 0.958,1,1; 0.96,1,1;
        0.962,1,1; 0.964,1,1; 0.966,1,1; 0.968,1,1; 0.97,1,1; 0.972,1,1; 0.974,
        1,1; 0.976,1,1; 0.978,1,1; 0.98,1,1; 0.982,1,1; 0.984,1,1; 0.986,1,1;
        0.988,1,1; 0.99,1,1; 0.992,1,1; 0.994,1,1; 0.996,1,1; 0.998,1,1; 1,1,1],
      period=1) "Boolean Data for validating the controlProcessModel block"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
equation
  connect(ReferenceData.y[1], controlProcessModel.u) annotation (Line(points={{
          -58,0},{-20,0},{-20,8},{-12,8}}, color={0,0,127}));
  connect(controlProcessModel.tOn, ReferenceData.y[2]) annotation (Line(points=
          {{-12,4},{-18,4},{-18,0},{-58,0}}, color={0,0,127}));
  connect(controlProcessModel.tOff, ReferenceData.y[3]) annotation (Line(points=
         {{-12,-4},{-16,-4},{-16,0},{-58,0}}, color={0,0,127}));
  connect(controlProcessModel.tau, ReferenceData.y[4]) annotation (Line(points=
          {{-12,-8},{-18,-8},{-18,0},{-58,0}}, color={0,0,127}));
  connect(ReferenceBoolData.y[1], controlProcessModel.triggerStart)
    annotation (Line(points={{-58,-50},{-6,-50},{-6,-12}}, color={255,0,255}));
  connect(controlProcessModel.triggerEnd, ReferenceBoolData.y[2])
    annotation (Line(points={{6,-12},{6,-50},{-58,-50}}, color={255,0,255}));
  annotation (
      experiment(
      StopTime=1.0,
      Tolerance=1e-06),
    __Dymola_Commands(
      file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/Utilities/PIDWithAutotuning/SystemIdentification/FirstOrderTimedelayed/Validation/ControlProcessModel.mos" "Simulate and plot"),
      Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 1, 2022, by Sen Huang:<br/>
First implementation<br/>
</li>
</ul>
</html>", info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.ControlProcessModel\">
Buildings.Controls.OBC.Utilities.PIDWithAutotuning.SystemIdentification.FirstOrderTimedelayed.ControlProcessModel</a>.
</p>
</html>"));
end ControlProcessModel;
