import Foundation

public struct CarInfo {
  private let number: Int
  private let color: String


  public init(number: Int, color: String) {
    self.number = number
    self.color = color
  }

  public func description() -> String {
    "\(color) \(number)"
  }
}
