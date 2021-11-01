//
//  Helper.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import Foundation

extension Collection where Element: Identifiable {
    func findIndex(of element: Element) -> Self.Index? {
        firstIndex(where: {$0.id == element.id })
    }
}
