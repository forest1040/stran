import Foundation

public class Model {
    lazy var _variable_index: [String: StorageView] = [:]
    func get_variable(name: String) -> StorageView? {
        return self._variable_index[name]
    }

    static func getFileData(filePath: String) -> Data? {
        let fileData: Data?
        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            fileData = try Data(contentsOf: fileUrl)
        } catch {
            fileData = nil
        }
        return fileData
    }

    func register_variable(name: String, variable: StorageView) {
        // if var vs = self._variable_index[name] {
        //     vs = variable
        // } else {
        //     self._variable_index[name] = variable
        // }
        self._variable_index[name] = variable
    }

    func finalize() {
        // TODO: ベンチマーク用のモデルで決め打ちのdevice(METAL)/dataType(Float)は特に処理不要
        // 取り急ぎquantizeもやらない
    }

    func process_linear_weights() {
        // TODO: ベンチマーク用のモデルではdevice(METAL)なので特に処理不要の予定
    }

    static func load() -> Model {
        let data = self.getFileData(filePath: "../../Model/model.bin")!
        let readStream = DataReadStream(data: data)
        do {
            let binary_version = try readStream.read() as UInt32
            print("binary_version: \(binary_version)")
            let spec = try readStream.readString()
            print("spec: \(spec)")

            let spec_revision = try readStream.read() as UInt32
            print("spec_revision: \(spec_revision)")

            let model_reader = ModelReader(model_dir: "", path_separator: "/")
            var model = create_model(model_reader: model_reader, spec: spec, spec_revision: Int(spec_revision))

            // num_variables
            let num_variables = try readStream.read() as UInt32
            print("num_variables: \(num_variables)")
            // TODO: ちょっと4個だけ見る
            // for i in 0..<4 {
            for i in 0..<num_variables {
                let name = try readStream.readString()
                print("name: \(name)")
                let rank = try readStream.read() as UInt8
                print("rank: \(rank)")

                // rank回数呼び出している。
                // TODO: まとめて取れるようにしたい。。
                var dimensions: Array<UInt32> = []
                for k in 0..<rank {
                    let dim = try readStream.read() as UInt32
                    dimensions.append(dim)
                }
                print("dimensions: \(dimensions)")
                // let dimensions = try readStream.readUInt32Array(count: Int(rank))
                // print("dimensions: \(dimensions)")

                // type_idは読み捨てる
                let type_id = try readStream.read() as UInt8
                let num_bytes = try readStream.read() as UInt32
                print("num_bytes: \(num_bytes)")

                // TODO: StorageViewをきれいにしたい
                // StorageView variable({dimensions, dimensions + rank}, dtype);
                // consume<char>(model_file, num_bytes, static_cast<char*>(variable.buffer()));

                let buf = try readStream.read(count: Int(num_bytes))
                var shape: Array<dim_t> = []
                for k in 0..<rank {
                    shape.append(dim_t(dimensions[Int(k)]))
                }
                let variable = StorageView(shape: shape)
                // buf(Data)を[Float]に変換
                let fltData = buf.withUnsafeBytes {
                    Array(
                        UnsafeBufferPointer(
                            start   : $0.baseAddress!.assumingMemoryBound( to: Float.self ),
                            count   : $0.count / MemoryLayout<Float>.size
                        )
                    )
                }
                variable.fill(value: fltData)
                model.register_variable(name: name, variable: variable)

                // TODO: メモリの開放
            }

            model.finalize()

            // // Register aliases, which are shallow copies of finalized variables.
            // if (binary_version >= 3) {
            //     const auto num_aliases = consume<uint32_t>(model_file);
            //     for (uint32_t i = 0; i < num_aliases; ++i) {
            //     const auto alias = consume<std::string>(model_file);
            //     const auto variable_name = consume<std::string>(model_file);
            //     model->register_variable_alias(alias, variable_name);
            //     // Also alias the quantization scale that could be associated to variable_name.
            //     model->register_variable_alias(alias + "_scale", variable_name + "_scale");
            //     }
            // }

            model.process_linear_weights()

            return model

        } catch {
            // TODO 異常終了させる
            print("err");
        }
        return Model()
    }

    static func create_model(model_reader: ModelReader, spec: String, spec_revision: Int) -> Model {
        // var model = Model()
        // if spec.isEmpty || spec == "TransformerBase" {
        //     model = TransformerModel(model_reader, spec_revision, 8);
        // } else if spec == "TransformerBig" {
        //     model = TransformerModel(model_reader, spec_revision, 16);
        // } else if spec == "TransformerSpec" {
        //     model = TransformerModel(model_reader, spec_revision);
        // } else {
        //     // TODO
        //     // throw std::invalid_argument("Unsupported model spec " + spec);
        // }
        // return model
        return TransformerModel(model_reader: model_reader, spec_revision: spec_revision)
    }
}
