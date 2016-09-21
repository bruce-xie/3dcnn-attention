import numpy as np

import lasagne
import lasagne.layers

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

def get_model():
    dims, n_channels, n_classes = tuple(cfg['dims']), cfg['n_channels'], cfg['n_classes']
    shape = (None, n_channels)+dims

    l_in = lasagne.layers.InputLayer(shape=shape)
    l_conv1 = voxnet.layers.Conv3dMMLayer(
            input_layer = l_in,
            num_filters = 1, # previously 32
            filter_size = [5,5,5],
            border_mode = 'valid',
            strides = [2,2,2],
            W = voxnet.init.Prelu(),
            nonlinearity = voxnet.activations.leaky_relu_01,
            name =  'conv1'
        )

    l_drop1 = lasagne.layers.DropoutLayer(
        incoming = l_conv1,
        p = 0.2,
        name = 'drop1'
        )
    l_conv2 = voxnet.layers.Conv3dMMLayer(
        input_layer = l_drop1,
        num_filters = 1, # previously 32
        filter_size = [3,3,3],
        border_mode = 'valid',
        W = voxnet.init.Prelu(),
        nonlinearity = voxnet.activations.leaky_relu_01,
        name = 'conv2'
        )

    # Hope added. out put filter for visualization
    visualize_filter = 0
    if visualize_filter:
        W1 = np.array(l_conv1.W.eval())
        np.save('W1.npy',W1)
        W2 = np.array(l_conv2.W.eval())
        np.save('W2.npy', W2)
        import sys
        sys.exit("filters written done")

    l_pool2 = voxnet.layers.MaxPool3dLayer(
        input_layer = l_conv2,
        pool_shape = [2,2,2],
        name = 'pool2',
        )
    l_drop2 = lasagne.layers.DropoutLayer(
        incoming = l_pool2,
        p = 0.3,
        name = 'drop2',
        )
    l_fc1 = lasagne.layers.DenseLayer(
        incoming = l_drop2,
        num_units = 1, # previously 128
        W = lasagne.init.Normal(std=0.01),
        name =  'fc1'
        )
    l_drop3 = lasagne.layers.DropoutLayer(
        incoming = l_fc1,
        p = 0.4,
        name = 'drop3',
        )
    l_fc2 = lasagne.layers.DenseLayer(
        incoming = l_drop3,
        num_units = n_classes,
        W = lasagne.init.Normal(std = 0.01),
        nonlinearity = None,
        name = 'fc2'
        )
    return {'l_in':l_in, 'l_out':l_fc2}

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


model = get_model()
l_out = model['l_out']
X = T.TensorType('float32', [False] * 5)('X')
dout = lasagne.layers.get_output(l_out, X, deterministic=True)
tt=theano.function([X], dout)
loader = (data_loader(cfg, '../../more_data_sal/shapenet10_test.tar'))
for x_shared, y_shared in loader:
    xx=x_shared
    rr = tt(xx)
    print(np.argmax(np.sum(rr,0)))