//
//  DictionaryKeyPath.swift
//  demo
//  键路径查找字典
//  Created by holla on 2018/10/30.
//  Copyright © 2018 xiaoxiang. All rights reserved.
// https://segmentfault.com/a/1190000008267829

import Foundation

/* use as
 :dict[keyPath: "translations.characters.Magica De Spell"] = "Gundel Gaukeley"
 :dict[keyPath: "translations.characters.Scrooge McDuck"]?.append(" Duck")
 :dict[dict: "translations.places"]?.removeAll()
 */

struct KeyPath {
    var segments: [String]
    
    var isEmpty: Bool { return segments.isEmpty }
    var path: String {
        return segments.joined(separator: ".")
    }
    
    /// 分离首路径并且
    /// 返回一组值，包含分离出的首路径以及余下的键路径
    /// 如果键路径没有值的话返回nil。
    func headAndTail() -> (head: String, tail: KeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        let head = tail.removeFirst()
        return (head, KeyPath(segments: tail))
    }
}

///使用 "this.is.a.keypath" 这种格式的字符串初始化一个 KeyPath
extension KeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension KeyPath: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

//因为 Swift 3.0 不支持根据具体类型进行扩展 (extension Dictionary where Key == String)
//所以这样做是必须的。
protocol StringProtocol {
    init(string s: String)
}

extension String: StringProtocol {
    init(string s: String) {
        self = s
    }
}

extension Dictionary where Key: StringProtocol {
    subscript(keyPath keyPath: KeyPath) -> Any? {
        get {
            switch keyPath.headAndTail() {
            case nil:
                // 键路径为空。
                return nil
            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
                // 到达了路径的尾部。
                let key = Key(string: head)
                return self[key]
            case let (head, remainingKeyPath)?:
                // 键路径有一个尾部，我们需要遍历。
                let key = Key(string: head)
                switch self[key] {
                case let nestedDict as [Key: Any]:
                    // 嵌套的下一层是一个字典
                    // 用剩下的路径作为下标继续取值
                    return nestedDict[keyPath: remainingKeyPath]
                default:
                    // 嵌套的下一层不是字典
                    // 键路径无效，中止。
                    return nil
                }
            }
        }
        
        set {
            switch keyPath.headAndTail() {
            case nil:
                // 键路径为空。
                return
            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
                // 直达键路径的末尾。
                let key = Key(string: head)
                self[key] = newValue as? Value
            case let (head, remainingKeyPath)?:
                let key = Key(string: head)
                let value = self[key]
                switch value {
                case var nestedDict as [Key: Any]:
                    // 键路径的尾部需要遍历
                    nestedDict[keyPath: remainingKeyPath] = newValue
                    self[key] = nestedDict as? Value
                default:
                    // 无效的键路径
                    return
                }
            }
        }
    }
}

extension Dictionary where Key: StringProtocol {
    subscript(string keyPath: KeyPath) -> String? {
        get { return self[keyPath: keyPath] as? String }
        set { self[keyPath: keyPath] = newValue }
    }
    
    subscript(dict keyPath: KeyPath) -> [Key: Any]? {
        get { return self[keyPath: keyPath] as? [Key: Any] }
        set { self[keyPath: keyPath] = newValue }
    }
}

