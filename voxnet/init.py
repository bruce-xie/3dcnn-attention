#
# @author  Daniel Maturana
# @year    2015
#
# @attention Copyright (c) 2015
# @attention Carnegie Mellon University
# @attention All rights reserved.
#
# @=

import numpy as np

import lasagne
from lasagne.utils import floatX

class Prelu(lasagne.init.Initializer):
    def __init__(self):
        pass

    def sample(self, shape):
        # eg k^2 for conv2d
        receptive_field_size = np.prod(shape[2:])
        c = shape[1] # input channels
        nl = c*receptive_field_size
        std = np.sqrt(2.0/(nl))
        return floatX(np.random.normal(0, std, size=shape))


class Ones(lasagne.init.Initializer):
    def __init__(self):
        pass

    def sample(self, shape):
        return floatX(np.ones(shape))

class fcwt(lasagne.init.Initializer):
    def __init__(self):
        pass

    def sample(self, shape):
        W = np.ones(shape);
        loc = [38,39,44,45, 74,75,80,81, 110,111,116,117, 146,147,152,153, 182,183,188,189]
        W[loc, :] = 10 * W[loc, :]
        return floatX(W)
