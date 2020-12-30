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
        return TransformerEncoder(model: self, scope: "encoder")
    }

    func make_decoder() -> Decoder {
        return TransformerDecoder(model: self, scope: "decoder")
    }

    // register_variable
    // finalize
}

enum LayerNormStrategy{
    case Input
    case Output
}

class MultiHeadAttention {
    var _num_heads: Int
    var _self_attention: Bool
    var _linear: [Dense]
    var _layer_norm_strategy: LayerNormStrategy
    var _layer_norm: LayerNorm

    var _relative_position_keys: StorageView?
    var _relative_position_values: StorageView?
    // var _maximum_relative_position: dim_t
    // var _queries_scale: Float

    // TODO
    // const ops::Transpose _transpose_op;

    init(model: TransformerModel, scope: String, num_heads: Int, self_attention: Bool, layer_norm_strategy: LayerNormStrategy = LayerNormStrategy.Output) {
        self._num_heads = num_heads
        self._self_attention = self_attention
        self._linear = Self.make_linear_layers(model: model, scope: scope, self_attention: self_attention)
        self._layer_norm_strategy = layer_norm_strategy
        self._layer_norm = LayerNorm(model: model, scope: scope + "/layer_norm")
        self._relative_position_keys = model.get_variable(name: scope + "/relative_position_keys")
        self._relative_position_values = model.get_variable(name: scope + "/relative_position_values")
        // self._maximum_relative_position = 
        //     self._relative_position_keys ? (self._relative_position_keys.dim(0) - 1) / 2 : 0)
        // , _queries_scale(1.f / std::sqrt(static_cast<float>(_layer_norm.output_size() / num_heads)))

        // TODO
        // , _transpose_op({0, 2, 1, 3})
    }

    static func make_linear_layers(model: Model, scope: String, self_attention: Bool) -> [Dense] {
        let num_linear_layers = self_attention ? 2 : 3;
        var layers:[Dense] = []
        for i in 0..<num_linear_layers {
            layers.append(Dense(model: model, scope: scope + "/linear_" + String(i)))
        }
        return layers
    }

    // TODO: operator
    // void MultiHeadAttention::operator()(const StorageView& queries,
    //                                     const StorageView* memory,
    //                                     const StorageView* memory_lengths,
    //                                     StorageView& output,
    //                                     StorageView* cached_keys,
    //                                     StorageView* cached_values,
    //                                     StorageView* attention,
    //                                     const Padder* padder) const {

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

class TransformerDecoderLayer {
    var _self_attention: MultiHeadAttention
    var _encoder_attention: MultiHeadAttention
    var _ff: TransformerFeedForward

    init(model: TransformerModel, scope: String, with_encoder_attention: Bool = true) {
        self._self_attention = 
            MultiHeadAttention(model: model, scope: scope + "/self_attention", 
                num_heads: model.num_heads(), self_attention: true)
        self._encoder_attention =
            MultiHeadAttention(model: model, scope: scope + "/attention", 
                num_heads: model.num_heads(), self_attention: false)
        self._ff = TransformerFeedForward(model: model, scope: scope + "/ffn")
    }

    // TODO: operator()
    // void TransformerDecoderLayer::operator()(const StorageView& input,
    //                                          const StorageView* memory,
    //                                          const StorageView* memory_lengths,
    //                                          StorageView& cached_self_attn_keys,
    //                                          StorageView& cached_self_attn_values,
    //                                          StorageView* cached_attn_keys,
    //                                          StorageView* cached_attn_values,
    //                                          StorageView& output,
    //                                          StorageView* attention,
    //                                          const Padder* padder) const {
    //   PROFILE("TransformerDecoderLayer");
    //   StorageView context(input.dtype(), input.device());
    //   if (_encoder_attention) {
    //     _self_attention(input, nullptr, nullptr, output,
    //                     &cached_self_attn_keys, &cached_self_attn_values);
    //     (*_encoder_attention)(output, memory, memory_lengths, context,
    //                           cached_attn_keys, cached_attn_values, attention, padder);
    //   } else {
    //     _self_attention(input, nullptr, nullptr, context,
    //                     &cached_self_attn_keys, &cached_self_attn_values);
    //   }
    //   _ff(context, output);
    // }
}

class TransformerEncoder : Encoder {
    var _embeddings: Embeddings
    var _position_encoder: PositionEncoder?
    var _output_norm: LayerNorm
    var _layers: [TransformerEncoderLayer] = []

    init(model: TransformerModel, scope: String) {
        self._embeddings = Embeddings(model: model, scope: scope + "/embeddings")
        self._position_encoder = model.with_relative_position()
            ? nil
            : PositionEncoder(model: model, scope: scope + "/position_encodings")
        self._output_norm = LayerNorm(model: model, scope: scope + "/layer_norm")
        for i in 0..<99 {
            do {
                self._layers.append(TransformerEncoderLayer(model: model, scope: scope + "/layer_" + String(i)))
            } catch {
                break
            }
        }
    }

    // TODO: operator()
    // void TransformerEncoder::operator()(const StorageView& ids,
    //                                     const StorageView& lengths,
    //                                     StorageView& output) {
    //   PROFILE("TransformerEncoder");
    //   StorageView input(output.dtype(), output.device());
    //   _embeddings(ids, input);
    //   if (_position_encoder)
    //     (*_position_encoder)(input);

    //   // Remove padding to reduce the amount of computation.
    //   std::unique_ptr<Padder> padder;
    //   if (Padder::allow_padding_removal(output.device(), _compute_type)) {
    //     padder.reset(new Padder(lengths, input.dim(1)));
    //     padder->remove_padding(input);
    //   }

    //   for (size_t l = 0; l < _layers.size(); ++l) {
    //     (*_layers[l])(input, lengths, output, padder.get());
    //     if (l + 1 < _layers.size())
    //       input = std::move(output);
    //   }
    //   _output_norm(output, output);
    //   if (padder)
    //     padder->add_padding(output);
    // }

}

class TransformerDecoder : Decoder {
    var _embeddings: Embeddings
    var _position_encoder: PositionEncoder?
    var _output_norm: LayerNorm
    var _layers: [TransformerDecoderLayer] = []
    var _with_encoder_attention: Bool
    // var _proj: Dense

    init(model: TransformerModel, scope: String, with_encoder_attention: Bool = true) {
        self._with_encoder_attention = with_encoder_attention
        self._embeddings = Embeddings(model: model, scope: scope + "/embeddings")
        self._position_encoder = model.with_relative_position()
            ? nil
            : PositionEncoder(model: model, scope: scope + "/position_encodings")
        self._output_norm = LayerNorm(model: model, scope: scope + "/layer_norm")
        // self._proj = Dense(model: model, scope: scope + "/projection")
        for i in 0..<99 {
            do {
                self._layers.append(
                    TransformerDecoderLayer(
                        model: model, scope: scope + "/layer_" + String(i),
                        with_encoder_attention: with_encoder_attention))
            } catch {
                break
            }
        }
    }

    // func set_vocabulary_mask(ids: StorageView) {
    //     self._proj.mask_weights(ids)
    // }

    // func reset_vocabulary_mask() {
    //     self._proj.reset_mask()
    // }

    func initial_state() -> DecoderState {
        var state = DecoderState()
        for i in 0..<self._layers.count {
            let i_str = String(i)
            state["self_keys_" + i_str] = StorageView(shape:[])
            state["self_values_" + i_str] = StorageView(shape:[])
            if self._with_encoder_attention {
                state["memory_keys_" + i_str] = StorageView(shape:[])
                state["memory_values_" + i_str] = StorageView(shape:[])
            }
        }
        return state
    }

    func should_reorder_state(name: String) -> Bool {
        return !self._with_encoder_attention || !name.hasPrefix("memory")
    }

    // TODO: operator()
    // void TransformerDecoder::operator()(dim_t step,
    //                                     const StorageView& ids,
    //                                     layers::DecoderState& state,
    //                                     StorageView* logits,
    //                                     StorageView* attention) {

}