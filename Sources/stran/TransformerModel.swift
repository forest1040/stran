public class TransformerModel : Model {
    static let shared_vocabulary_file = "shared_vocabulary.txt";
    static let source_vocabulary_file = "source_vocabulary.txt";
    static let target_vocabulary_file = "target_vocabulary.txt";
    // static let vmap_file = "vmap.txt";

    // var _source_vocabulary: Vocabulary
    // var _target_vocabulary: Vocabulary
    var _shared_vocabulary: Vocabulary = Vocabulary()
    // var _vocabulary_map: VocabularyMap

    // TODO: spec:TransformerSpecの場合、_num_headsは、0でよい?
    var _num_heads = 0
    var _with_relative_position = true

    init(model_reader: ModelReader, spec_revision: Int) {
        if let shared_vocabulary = model_reader.get_file(filename: Self.shared_vocabulary_file) {
            self._shared_vocabulary = Vocabulary(fin: shared_vocabulary)
        }
        // TODO:_source_vocabulary/_target_vocabulary
        // if let vmap = model_reader.get_file(filename: Self.vmap_file) {
        //   self._vocabulary_map = VocabularyMap(vmap, self._shared_vocabulary)
        // }
    }

    func num_heads() -> Int {
        return self._num_heads
    }

    func with_relative_position() -> Bool {
        return self._with_relative_position
    }

    func current_spec_revision() -> Int {
        return 3
    }

    func make_encoder() -> Encoder {
        return TransformerEncoder(self, "encoder")
    }

    func make_decoder() -> Decoder {
        return TransformerDecoder(self, "decoder")
    }

    // register_variable
    // finalize
}

// TODO: 
    // enum class LayerNormStrategy {
    //   Input,
    //   Output,
    // };

class MultiHeadAttention {
    init(model: TransformerModel, scope: String, num_heads: Int, self_attention: Bool, ) {
        // self._model_encoding = model.get_variable(name: scope + "/encodings")!
    }

}

class PositionEncoder {
    var _model_encoding: StorageView = StorageView(shape: [])
    // var _generated_encoding: StorageView = StorageView()

    init(model: TransformerModel, scope: String) {
        self._model_encoding = model.get_variable(name: scope + "/encodings")!
    }

    // private func get_position_encoding(max_time: dim_t, depth: dim_t) -> StorageView {
    private func get_position_encoding() -> StorageView {
        return self._model_encoding
    }

    // TODO: operator()
    //   const dim_t max_time = input.dim(1);
    //   const dim_t depth = input.dim(-1);
    //   const StorageView& encodings = get_position_encoding(max_time,
    //                                                        depth,
    //                                                        input.device(),
    //                                                        input.dtype());
    // primitives<D>::add_batch_broadcast(encodings.data<T>() + index * depth,
    //                                 input.data<T>(),
    //                                 max_time * depth,
    //                                 input.size())));

}

class TransformerFeedForward {
    var _layer_norm: LayerNorm
    var _ff1: Dense
    var _ff2: Dense

    init() {
        self._layer_norm = LayerNorm()
        self._ff1 = Dense()
        self._ff2 = Dense()
    }

    init(model: TransformerModel, scope: String) {
        // self._model_encoding = model.get_variable(name: scope + "/encodings")!
        self._layer_norm = LayerNorm(model: model, scope: scope + "/layer_norm")
        self._ff1 = Dense(model: model, scope: scope + "/linear_0")
        self._ff2 = Dense(model: model, scope: scope + "/linear_1")
    }

    // TODO: operator()
    // void TransformerFeedForward::operator()(const StorageView& input, StorageView& output) const {
    //   StorageView inner(input.dtype(), input.device());
    //   _layer_norm(input, output);
    //   _ff1(output, inner);
    //   ops::ReLU()(inner, inner);
    //   _ff2(inner, output);
    //   ops::Add()(input, output, output);
    // }

}

class TransformerEncoderLayer {
    var _self_attention: MultiHeadAttention
    var _ff: TransformerFeedForward

    init() {
        self._self_attention = MultiHeadAttention()
        self._ff = TransformerFeedForward()
    }

    init(model: TransformerModel, scope: String) {
        self._self_attention = 
            MultiHeadAttention(model: model, scope: scope + "/self_attention", 
                num_heads: model.num_heads(), self_attention: true)
        self._ff = TransformerFeedForward(model: model, scope: scope + "/ffn")
    }

    // TODO: operator()
    // void TransformerEncoderLayer::operator()(const StorageView& input,
    //                                          const StorageView& lengths,
    //                                          StorageView& output,
    //                                          const Padder* padder) const {
    //   PROFILE("TransformerEncoderLayer");
    //   StorageView context(input.dtype(), input.device());
    //   _self_attention(input, nullptr, &lengths, context, nullptr, nullptr, nullptr, padder);
    //   _ff(context, output);
    // }
}


