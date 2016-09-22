import numpy as np

import lasagne
import lasagne.layers
from lasagne.utils import floatX
from voxnet import isovox

import voxnet
import theano
import theano.tensor as T
from voxnet import npytar
lr_schedule = { 0: 0.001,
                60000: 0.0001,
                400000: 0.00005,
                600000: 0.00001,
                }

cfg = {'batch_size' : 10, # previous 32
       'learning_rate' : lr_schedule,
       'reg' : 0.001,
       'momentum' : 0.9,
       'dims' : (32, 32, 32),
       'n_channels' : 1,
       'n_classes' : 2,# previous 10
       'batches_per_chunk': 1, # previous 64
       'max_epochs' : 600,  #previous 80
       'max_jitter_ij' : 2,
       'max_jitter_k' : 2,
       'n_rotations' : 1, # previous 12
       'checkpoint_every_nth' : 4000,
       }

dims, n_channels, n_classes = tuple(cfg['dims']), cfg['n_channels'], cfg['n_classes']
shape = (None, n_channels)+dims

l_in = lasagne.layers.InputLayer(shape=shape)
l_conv1 = voxnet.layers.Conv3dMMLayer(
        input_layer = l_in,
        num_filters = 1, # previously 32
        filter_size = [5,5,5],
        border_mode = 'valid',
        strides = [2,2,2],
        # W = voxnet.init.Prelu(),
        W = voxnet.init.Ones(),
        nonlinearity = voxnet.activations.leaky_relu_01,
        name =  'conv1',
        b = floatX(np.zeros(l_in.shape[1]))
    )
l_conv2 = voxnet.layers.Conv3dMMLayer(
    input_layer = l_conv1,
    num_filters = 1, # previously 32
    filter_size = [3,3,3],
    border_mode = 'valid',
    # W = voxnet.init.Prelu(),
    W=voxnet.init.Ones(),
    nonlinearity = voxnet.activations.leaky_relu_01,
    name = 'conv2',
    b = floatX(np.zeros(l_conv1.output_shape[1]))
)
l_pool2 = voxnet.layers.MaxPool3dLayer(
    input_layer = l_conv2,
    pool_shape = [2,2,2],
    name = 'pool2',
    )
l_fc1 = lasagne.layers.DenseLayer(
    incoming = l_pool2,
    num_units = 10, # previously 128
    W = lasagne.init.Normal(std=0.01),
    name =  'fc1'
    )
l_fc2 = lasagne.layers.DenseLayer(
    incoming = l_fc1,
    num_units = n_classes,
    W = lasagne.init.Normal(std = 0.01),
    nonlinearity = None,
    name = 'fc2'
    )

def data_loader(cfg, fname):
    dims = cfg['dims']
    chunk_size = cfg['n_rotations']
    xc = np.zeros((chunk_size, cfg['n_channels'],)+dims, dtype=np.float32)
    reader = npytar.NpyTarReader(fname)
    yc = []
    for ix, (x, name) in enumerate(reader):
        cix = ix % chunk_size
        xc[cix] = x.astype(np.float32)
        yc.append(int(name.split('.')[0])-1)
        if len(yc) == chunk_size:
            yield (2.0*xc - 1.0, np.asarray(yc, dtype=np.float32))
            yc = []
            xc.fill(0)
    assert(len(yc)==0)


layers = [l_in, l_conv1, l_conv2, l_pool2, l_fc1, l_fc2]
# layers = [l_conv1, l_pool2, l_fc1, l_fc2]

l_out = layers[1]
X = T.TensorType('float32', [False] * 5)('X')
act = lasagne.layers.get_output(l_out, X, deterministic=True)
tt = theano.function([X], act)

loader = (data_loader(cfg, '../../more_data_sal/shapenet10_test.tar'))
for x_shared, y_shared in loader:
    rr = tt(x_shared)
    # print(np.argmax(np.sum(rr1,0)), np.argmax(np.sum(rr2,0)))
    print(rr)

size = 32
w = rr[0, 0]
# centerize the plot
fz = len(w)
xd = np.zeros((size,size,size))
pad = (size-fz)/2
xd[pad:pad+fz,pad:pad+fz,pad:pad+fz] = w
# only visualize the largest value
t = 0
xd[xd<t]=0
# store as png
iv = isovox.IsoVox()
img = iv.render(xd, as_html=True, name='../act/l1')