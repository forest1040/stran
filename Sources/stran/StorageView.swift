public class StorageView {
    var _data: [Float] = []
    // TODO _own_dataは不要？
    var _own_data: Bool = true
    var _allocated_size: dim_t = 0
    var _size: dim_t = 0
    var _shape: Shape = []

    // init() {
    //     self._own_data = true
    //     self._allocated_size = 0
    //     self._size = 0
    //     self._shape = []
    // }

    init(shape: Shape) {
        // self.init()
        self.resize(new_shape: shape)
    }

    // Create from a Array (copy).
    // TODO: Generic
    init(shape: Shape, value: [Float]) {
        self.resize(new_shape: shape)
        self.fill(value: value)
    }

    // Create from a buffer (no copy).
    init(shape: Shape, refv: inout [Float]) {
        self.resize(new_shape: shape)
        self.view(refv: &refv, shape: shape)
    }

    func resize(new_shape: Shape) -> StorageView {
        let new_size = self.compute_size(shape: new_shape)
        self.reserve(size: new_size)
        self._size = new_size
        self._shape = new_shape
        return self
    }

    func compute_size(shape: Shape) -> dim_t {
        var size: dim_t = 1
        for dim in shape {
            size *= dim
        }
        return size
    }

    func clear() -> StorageView {
        self._size = 0
        // TODO
        // self._shape.clear()
        return self
    }

    func release() -> StorageView {
        // TODO
        _data = []
        self._allocated_size = 0
        return self.clear()
    }

    func reserve(size: dim_t) -> StorageView {
        if (size <= self._allocated_size) {
            return self
        }
        self.release()
        let required_bytes = 0
        self._own_data = true
        self._allocated_size = size
        return self
    }

//   void primitives<Device::CPU>::fill(T* x, T a, dim_t size) {
//     std::fill(x, x + size, a);
//   }

    func fill(value: [Float]) -> StorageView {
        // TODO: deviceへのコピー
        // DEVICE_DISPATCH(_device, primitives<D>::fill(data<T>(), value, _size));
        // TODO: 所有権の移動ではダメか？ Ownership
        self._data = value
        return self
    }

    // TODO: generic
    func view(refv: inout [Float], shape: Shape) -> StorageView {
        self.release()
        // TODO
        // self._data = static_cast<void*>(data);
        self._own_data = false;
        self._allocated_size = self.compute_size(shape: shape)
        self._size = self._allocated_size
        return self.reshape(new_shape: shape)
    }

    func reshape(new_shape: Shape) -> StorageView {
        var unknown_dim: dim_t = -1
        var known_size: dim_t = 1

        for i in 0..<new_shape.count {
            let dim = new_shape[i]
            if (dim >= 0) {
                known_size *= dim
            } else if (dim == -1) {
                if (unknown_dim >= 0) {
                    // THROW_INVALID_ARGUMENT("only one dimension can be set to -1, got -1 for dimensions "
                    //                         + std::to_string(unknown_dim) + " and " + std::to_string(i));
                    unknown_dim = Int64(i)
                }
            } else {
                // THROW_INVALID_ARGUMENT("invalid value " + std::to_string(dim)
                //                     + " for dimension " + std::to_string(i));
            }
        }

        if (unknown_dim >= 0) {
            if (self._size % known_size != 0) {
                // THROW_INVALID_ARGUMENT("current size (" + std::to_string(_size)
                //                     + ") is not divisible by the known size ("
                //                     + std::to_string(known_size) + ")");
                
                // TODO: 所有権の移動 Ownership
                // let new_shape_copy(new_shape)
                // new_shape_copy[unknown_dim] = self._size / known_size;
                // self._shape = std::move(new_shape_copy);

            } else {
                if (self._size != known_size) {
                    // THROW_INVALID_ARGUMENT("new shape size (" + std::to_string(known_size)
                    //                     + ") is incompatible with current size ("
                    //                     + std::to_string(_size) + ")");
                    self._shape = new_shape
                }
            }
        }

        return self
    }

}