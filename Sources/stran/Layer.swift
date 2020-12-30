public class Layer {
    static func get_linear_weight(model: Model, scope: String) -> StorageView {
        return model.get_variable(name: scope + "/weight")!
    }
}

public class Embeddings : Layer {
    // const ops::Gather _gather_op;
    // var _embeddings: StorageView
    // var _qscale: StorageView
    // var _scale: StorageView

    // lazy var _embeddings: StorageView? = Optional.none
    var _embeddings: StorageView = StorageView(shape: [])
    // とりあえずベンチモデルだけ対応するため以下は不要
    // lazy var _qscale: StorageView? = Optional.none
    // lazy var _scale: StorageView? = Optional.none

    // const StorageView& _embeddings;
    // const StorageView* _qscale;
    // const std::unique_ptr<const StorageView> _scale;

    // override init () {
    //     self._embeddings = StorageView(shape: [])
    //     self._qscale = StorageView(shape: [])
    //     self._scale = StorageView(shape: [])
    // }

    init(model: Model, scope: String) {
        self._embeddings = model.get_variable(name: scope + "/weight")!
        // とりあえずベンチモデルだけ対応するため以下は不要
        // self._qscale = model.get_variable(scope + "/weight_scale")
        // self._scale = model.get_variable(scope + "/multiply_by_sqrt_depth")
    }
}

public class Dense : Layer {
    // bool _packed_weight;
    // const StorageView& _weight;
    // const StorageView* _bias;
    // const StorageView* _qscale;
    // const StorageView* _u8_shift_compensation;
    // StorageView _partial_weight;
    // StorageView _partial_bias;
    // StorageView _partial_qscale;
    // StorageView _partial_u8_shift_compensation;
    // const ops::Gemm _gemm_op;
    // const ops::Quantize _quantize_op;
    // const ops::Dequantize _dequantize_op;

    var _weight: StorageView = StorageView(shape: [])
    var _bias: StorageView = StorageView(shape: [])
    // TODO
    // const ops::Gemm _gemm_op;

    override init() {}
    init(model: Model, scope: String) {
        self._weight = model.get_variable(name: scope + "/weight")!
        self._bias = model.get_variable(name: scope + "/bias")!
    }

    // TODO Gather
    // void Dense::mask_weights(const StorageView& index) {
    //   if (_packed_weight)
    //     throw std::runtime_error("Can't mask pre-packed weight");
    //   ops::Gather()(_weight, index, _partial_weight);
    //   if (_u8_shift_compensation)
    //     ops::Gather()(*_u8_shift_compensation, index, _partial_u8_shift_compensation);
    //   if (_bias)
    //     ops::Gather()(*_bias, index, _partial_bias);
    //   if (_qscale && !_qscale->is_scalar())
    //     ops::Gather()(*_qscale, index, _partial_qscale);
    // }

    // void Dense::reset_mask() {
    //   _partial_weight.clear();
    //   _partial_bias.clear();
    //   _partial_qscale.clear();
    //   _partial_u8_shift_compensation.clear();
    // }
    func reset_mask() {

    }

}

public class LayerNorm : Layer {
    var _beta: StorageView = StorageView(shape: [])
    var _gamma: StorageView = StorageView(shape: [])

    // TODO
    // const ops::LayerNorm _norm_op;

    override init() {}
    init(model: Model, scope: String) {
        self._beta = model.get_variable(name: scope + "/beta")!
        self._gamma = model.get_variable(name: scope + "/gamma")!
    }
}

public class Encoder : Layer {}
