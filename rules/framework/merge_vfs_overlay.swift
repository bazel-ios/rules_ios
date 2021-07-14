

import Foundation

let output = ProcessInfo.processInfo.arguments[1]
let args = ProcessInfo.processInfo.arguments[2...]

func loadVFS(path: String) -> [String: Any] {
   do {
          let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
          let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
          return jsonResult as? [String: Any] ?? [:]
      } catch {
          print("ERR\(error)")
          return [:]
      }
}

var outputVFS: [String: Any] = [:]
let VFSJSON = args.reduce(into: outputVFS) {
    accum, next in
    let nextVFS = loadVFS(path: next)
    guard let nextRoots = nextVFS["roots"] as? [Any] else {
        print("invalid VFS", next, nextVFS["roots"])
        exit(1)
        return
    }
    if accum.count == 0 {
        accum = nextVFS
        return
    }

    // Naievely add the roots
    guard let accumRoots = accum["roots"] as? [Any] else {
        print("NoRoots", accum["roots"])
        return
    }

    // This intentionally is an NSMutableDictionary, there's a problem using
    // NSJSONSerailization with this value. Consider comparing to performance of
    // codeable.
    var rootsByName = NSMutableDictionary()
    for _root in accumRoots {

        guard let root = _root as? [String: Any] else {
            print("Invalid", _root)
            continue
        }
        let name = root["name"] as! String
        rootsByName[name] = root
    }

    for _nextRoot in nextRoots {
        guard let nextRoot = _nextRoot as? [String: Any] else {
            print("Invalid", _nextRoot)
            continue
        }

        let name = nextRoot["name"] as! String
        if var prev = rootsByName[name] as? [String: Any] {
           let contents = nextRoot["contents"] as? [Any] ?? []
           let prevContents = prev["contents"] as? [Any] ?? []
           prev["contents"] = prevContents + contents

           let externalContents = nextRoot["external-contents"] as? [Any] ?? []
           let prevexternalContents = prev["external-contents"] as? [Any] ?? []
           prev["external-contents"] = prevexternalContents + externalContents

           rootsByName[name] =  prev
        }
        rootsByName[name] = nextRoot
    }
    accum["roots"] = rootsByName.allValues
}

let debug = false
if debug {
   print("__VFS", output, VFSJSON)
}
if let encodedData = try?JSONSerialization.data(withJSONObject: VFSJSON,
                                                options: .init(rawValue: 0))
{
    let pathAsURL = URL(fileURLWithPath: output)
    do {
        try encodedData.write(to: pathAsURL)
        if debug {
             print("-WROTE", pathAsURL.absoluteString)
        }
    } 
    catch {
        print("Failed to write JSON data: \(error.localizedDescription)")
        exit(1)
    }
}
