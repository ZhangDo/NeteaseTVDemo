import Foundation


extension Int {
    // MARK: 转换万单位
    func toTenThousandString(scale: Int = 1) -> String {
        if self < 0 {
            return "0"
        } else if self <= 9999 {
            return "\(self)"
        } else {
            let doub = CGFloat(self) / 10000
            let str = String(format: "%.\(scale)f", doub)
            let start_index = str.index(str.endIndex, offsetBy: -1)
            let suffix = String(str[start_index ..< str.endIndex])
            if suffix == "0" {
                let toIndex = str.index(str.endIndex, offsetBy: -2)
                return String(str[str.startIndex ..< toIndex]) + "万"
            } else {
                return str + "万"
            }
        }
    }
}
