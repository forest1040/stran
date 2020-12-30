import Foundation

public class ModelReader {
    var _model_dir: String = ""
    var _path_separator: String = "/"

    init(model_dir: String, path_separator: String) {
        self._model_dir = model_dir
        self._path_separator = path_separator
    }

    func get_model_id() -> String {
        return self._model_dir
    }

    func get_file(filename: String) -> FileHandle? {
        let path = self._model_dir + self._path_separator + filename
        return FileHandle(forReadingAtPath: path)
    }
}
