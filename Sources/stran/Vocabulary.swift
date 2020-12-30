import Foundation

public class Vocabulary {
    static public let pad_token: String = "<blank>"
    static public let unk_token: String = "<unk>"
    static public let bos_token: String = "<s>"
    static public let eos_token: String = "</s>"

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
        if self._token_to_id[Self.unk_token] == nil {
            self._token_to_id[Self.unk_token] = Int32(self._id_to_token.count)
            self._id_to_token.append(Self.unk_token)
        }
    }

    func to_id(token: String) -> Int {
        if let it = self._token_to_id[token] {
            return Int(it)
        } else {
            return Int(self._token_to_id[Self.unk_token]!)
        }
    }

    func size() -> Int {
        return self._id_to_token.count
    }
}

public class VocabularyMap {
    var _vocabulary_size: Int = 0
    var _fixed_candidates: [Int] = []
    var _map_rules: [[String: Int]] = []

    init() {}

    init (map_file: FileHandle, vocabulary: Vocabulary) {
        self._vocabulary_size = vocabulary.size()
        let contents = map_file.readDataToEndOfFile()
        let contentString = String(data: contents, encoding: .utf8)!
        let lines = contentString.lines
        for (index, line) in lines.enumerated() {
            var token = ""
            var key = ""
            var values:[Int] = []
            var target = false
            var ngram = 1
            for s in line {
                if s == "\t" {
                    target = true
                    (key, token) = (token, key)
                } else if s == " " {
                    if target {
                        values.append(vocabulary.to_id(token: token))
                        token = ""
                    } else {
                        // TODO: 高速化が必要
                        token = token + String(s)
                        ngram += 1
                    }
                } else {
                    // TODO: 高速化が必要
                    token = token + String(s)
                }
            }
            if !token.isEmpty {
                values.append(vocabulary.to_id(token: token))
            }
            // TODO
            //self._map_rules[ngram - 1][key] = values
        }

        self._fixed_candidates.append(vocabulary.to_id(token: Vocabulary.unk_token))
        self._fixed_candidates.append(vocabulary.to_id(token: Vocabulary.bos_token))
        self._fixed_candidates.append(vocabulary.to_id(token: Vocabulary.eos_token))
        self._fixed_candidates.append(vocabulary.to_id(token: Vocabulary.pad_token))
        
        // The field marked by the empty string are common tokens that are always candidates.
        if let it = self._map_rules[0][""] {
            self._fixed_candidates.append(it)
        }
    }

    func empty() -> Bool {
        return self._map_rules.isEmpty
    }

    func get_candidates(batch_tokens: [[String]]) -> [Int] {
        var candidates = self._fixed_candidates
        var accu = ""
        for tokens in batch_tokens {
            var i = 0
            for token in tokens {
                accu = ""
                for h in 0..<self._map_rules.count {
                    if i + h > tokens.count {
                        break
                    }
                    if h > 0 {
                        accu += " "
                    }
                    accu += tokens[i + h]

                    // TODO
                    // if let m = self._map_rules[h] {
                    //     // candidates.append(m)
                    //     candidates + m
                    // }
                }
                i += 1
            }
        }
        return candidates
    }

}
