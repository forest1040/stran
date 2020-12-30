import Foundation

public class Vocabulary {
    static let pad_token: String = "<blank>"
    static let unk_token: String = "<unk>"
    static let bos_token: String = "<s>"
    static let eos_token: String = "</s>"

    var _id_to_token: [String] = []
    var _token_to_id: [String: Int32] = [:]

    init() {}

    init(fin: FileHandle) {
        let contents = fin.readDataToEndOfFile()
        let contentString = String(data: contents, encoding: .utf8)!
        let lines = contentString.lines
        for (index, line) in lines.enumerated() {
            print("\(line)")
            self._token_to_id[line] = Int32(index)
            self._id_to_token.append(line)
        }
        // add unk_token
        if (self._token_to_id[Self.unk_token] == nil){
            self._token_to_id[Self.unk_token] = Int32(self._id_to_token.count)
            self._id_to_token.append(Self.unk_token)
        }
    }
}

// public class VocabularyMap {

// }
