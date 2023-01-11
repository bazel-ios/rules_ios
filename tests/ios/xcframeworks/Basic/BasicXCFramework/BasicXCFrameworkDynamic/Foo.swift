//
//  BasicTypes.swift
//  BasicXCFramework
//
//  Created by Luis Padron on 7/25/22.
//

import Foundation

public final class FooDynamic {
    let num: Int

    public init(num: Int = 1) {
        self.num = num
    }

    public func bar() {
        print(num)
    }
}
