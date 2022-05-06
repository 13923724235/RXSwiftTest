

import CommonCrypto
import Foundation
import SystemConfiguration
import UIKit

// MARK: - - 字符串功能扩展 --

extension String {
    var legalUrlString: String? {
        if hasPrefix("http:") {
            return replacingOccurrences(of: "http:", with: "https:")
        }
        return nil
    }

    enum SHAType: Int {
        case SHA1
        case SHA224
        case SHA256
        case SHA384
        case SHA512
    }

    // MARK: - - 编码解码加密 --

    static func base64Encoding(_ plainString: String) -> String {
        if let plainData = plainString.data(using: String.Encoding.utf8) {
            let encodedString = plainData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            return encodedString
        }
        //  CustomLog.e("base64编码失败")
        return plainString
    }

    static func base64Decoding(_ plainString: String) -> String {
        if let decodedData = Data(base64Encoded: plainString, options: Data.Base64DecodingOptions(rawValue: 0)) {
            if let decodedString = String(data: decodedData, encoding: String.Encoding.utf8) {
                return decodedString
            }
        }
        // CustomLog.e("base64解码失败")
        return plainString
    }

    static func MD5Encrypt(_ plainString: String) -> String {
        let str = plainString.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(plainString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        CC_MD5(str!, strLen, result)

        var hash = ""
        for i in 0 ..< digestLen {
            hash = hash.appendingFormat("%02x", result[i])
        }

        result.deallocate()

        return hash
    }

    static func SHAEncrypt(_ plainString: String, _ shaType: SHAType) -> String {
        let str = plainString.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(plainString.lengthOfBytes(using: String.Encoding.utf8))

        var digestLen = 0
        switch shaType {
        case .SHA1:
            digestLen = Int(CC_SHA1_DIGEST_LENGTH)
            break
        case .SHA224:
            digestLen = Int(CC_SHA224_DIGEST_LENGTH)
            break
        case .SHA256:
            digestLen = Int(CC_SHA256_DIGEST_LENGTH)
            break
        case .SHA384:
            digestLen = Int(CC_SHA384_DIGEST_LENGTH)
            break
        case .SHA512:
            digestLen = Int(CC_SHA512_DIGEST_LENGTH)
            break
        }

        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        switch shaType {
        case .SHA1:
            CC_SHA1(str!, strLen, result)
            break
        case .SHA224:
            CC_SHA224(str!, strLen, result)
            break
        case .SHA256:
            CC_SHA256(str!, strLen, result)
            break
        case .SHA384:
            CC_SHA384(str!, strLen, result)
            break
        case .SHA512:
            CC_SHA512(str!, strLen, result)
            break
        }

        var hash = ""
        for i in 0 ..< digestLen {
            hash = hash.appendingFormat("%02x", result[i])
        }

        result.deallocate()

        return hash
    }

    // Int类型转换成汉字 1 -> 一
    static func intIntoString(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style(rawValue: UInt(CFNumberFormatterRoundingMode.roundHalfDown.rawValue))!
        let string: String = formatter.string(from: NSNumber(value: number as Int))!
        return string
    }

    // 获取文字的宽高
    static func getTextRectSize(_ text: NSString, font: UIFont, fontNumber: CGFloat) -> CGRect {
        let attributes = [NSAttributedString.Key.font: font]

        let option = NSStringDrawingOptions.usesLineFragmentOrigin

        let size = CGSize(width: CGFloat(MAXFLOAT), height: fontNumber)

        let rect: CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)

        return rect
    }

    // 测量多行字符串宽高
    func getTextRectSize(_ font: UIFont, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]

        let option = NSStringDrawingOptions.usesLineFragmentOrigin

        let size = CGSize(width: maxWidth, height: maxHeight)

        let rect: CGRect = boundingRect(with: size, options: option, attributes: attributes, context: nil)

        return rect.size
    }

    // 测量单行字符串
    func sizeWithFont(_ font: UIFont) -> CGSize {
        let attrs = [NSAttributedString.Key.font: font]
        let string: NSString = self as NSString
        return string.size(withAttributes: attrs)
    }

    // 子字符串位置
    func positionOf(_ sub: String) -> Int {
        var pos = -1
        if let range = self.range(of: sub) {
            if !range.isEmpty {
                pos = distance(from: startIndex, to: range.lowerBound)
            }
        }
        return pos
    }

    // 子字符串[pos, end)
    func subStringFrom(_ pos: Int) -> String {
        var substr = ""
        let start = index(startIndex, offsetBy: pos)
        let end = endIndex
        let range = start ..< end
        substr = String(self[range])
        return substr
    }

    // 子字符串[0, pos)
    func subStringTo(_ pos: Int) -> String {
        var substr = ""
        let end = index(startIndex, offsetBy: pos - 1)
        let range = startIndex ... end
        substr = String(self[range])
        return substr
    }

    // 子字符串[start, end)
    func subStringFromTo(_ start: Int, _ end: Int) -> String {
        var substr = ""
        let start1 = index(startIndex, offsetBy: start)
        let end = index(start1, offsetBy: end - start)
        let range = start1 ..< end
        substr = String(self[range])
        return substr
    }

    // 截取字符串到某个位置
    func subString(to index: Int) -> String {
        var result: String = ""
        var count: Int = 0
        let range = startIndex ..< endIndex
        enumerateSubstrings(in: range, options: NSString.EnumerationOptions.byComposedCharacterSequences) { (substring, _, _, _) -> Void in
            count += substring!.unicodeScalars.count
            if count <= index {
                result += substring!
            }
        }
        return result
    }

    // 特殊字符编码处理
    func urlEncoded() -> String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }

    // 特殊字符解码处理
    func urlDecoded() -> String {
        return removingPercentEncoding ?? ""
    }

    // 字符串的起始位置
    func range() -> Range<String.Index> {
        return startIndex ..< endIndex // Range<String.Index>(start:startIndex, end:endIndex)
    }

    // 字符串转换为时间  默认格式为：年-月-日 时:分
    func convertToTime(format: String = "yyyy-MM-dd HH:mm") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }

    // 到某个时间的天数（当天除外）
    func daysToTime() -> Int {
        var days = 0 // 天数
        if let date = convertToTime(format: "yyyy-MM-dd") {
            if date > Date() {
                let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)
                days = dateComponents.day!
                if days < 1 && (dateComponents.hour! > 0 || dateComponents.minute! > 0 || dateComponents.second! > 0) {
                    days += 1
                }
            }
        }
        return days
    }

    // 字符串转换倒计时
    func stringToEndTime() -> String {
        var timeResult: String = ""
        if let endTimeDate = convertToTime(format: "yyyy-MM-dd HH:mm:ss") {
            // 显示倒计时.若超时,则显示"00:00:00"
            if Date() > endTimeDate {
                timeResult = "00:00:00"
            } else {
                // 计算时间差 NSCalendarUnit.Year, NSCalendarUnit.Month,
                let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: endTimeDate)
                if dateComponents.day! > 0 {
                    timeResult = "\(dateComponents.day!)天\(dateComponents.hour!)小时"
                } else {
                    let hour = dateComponents.hour! >= 10 ? "\(dateComponents.hour!)" : "0\(dateComponents.hour!)"
                    let minute = dateComponents.minute! >= 10 ? "\(dateComponents.minute!)" : "0\(dateComponents.minute!)"
                    let second = dateComponents.second! >= 10 ? "\(dateComponents.second!)" : "0\(dateComponents.second!)"
                    timeResult = hour + ":" + minute + ":" + second
                }
            }
        }
        return timeResult
    }

    // 判断是否全是空白
    func isBlank() -> Bool {
        return trimmingCharacters(in: CharacterSet.whitespaces) == ""
    }

    /// 去掉字符串首尾的空格
    func trimming() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    // 字符串转CGFloat
    func convertToFloat() -> (CGFloat) {
        let string = self
        var cgFloat: CGFloat = 0

        if let doubleValue = Double(string) {
            cgFloat = CGFloat(doubleValue)
        }

        return cgFloat
    }

    // 字符串转整形
    func convertToInt() -> (Int) {
        let string = self
        var int: Int?

        if let doubleValue = Int(string) {
            int = Int(doubleValue)
        }

        if int == nil {
            return 0
        }
        return int!
    }

    // 提取首字母 比如："张三" -> "Z"
    func getPinyinFirst() -> String {
        if count > 0 {
            let mutableStr = NSMutableString(string: self)
            CFStringTransform(mutableStr, nil, kCFStringTransformMandarinLatin, false)
            CFStringTransform(mutableStr, nil, kCFStringTransformStripDiacritics, false)
            return (mutableStr as String).subStringTo(1).uppercased()
        } else {
            return ""
        }
    }

    // 判断学号是否合法
    func isStuNo() -> Bool {
        let format = "^\\d{1,32}$" // 1-32数字
        let number = NSPredicate(format: "SELF MATCHES %@", format)
        return number.evaluate(with: self)
    }

    // 仅字母
    func isOnlyLetter() -> Bool {
        let regex = "^[A-Za-z]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    // 仅数字
    func isOnlyDigital() -> Bool {
        let regex = "^[0-9]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    // 判断是否是手机号码
    func isMobileNumber() -> Bool {
        let telNumber = "^[1](([3][0-9])|([4][5-9])|([5][0-3,5-9])|([6][5,6])|([7][0-8])|([8][0-9])|([9][1,8,9]))[0-9]{8}$"
        let tel = NSPredicate(format: "SELF MATCHES %@", telNumber)
        return tel.evaluate(with: self)
    }

    // 替换字符串 例："13880000789".replacingCharacters((3, 4), with: "****"), 结果:138****0789
    func replacingCharacters(_ bounds: (startIndex: Int, length: Int), with newElements: String) -> String {
        let s = index(startIndex, offsetBy: bounds.startIndex, limitedBy: endIndex)
        if nil != s {
            let e = index(s!, offsetBy: bounds.length, limitedBy: endIndex)
            if nil != e {
                return replacingCharacters(in: s! ..< e!, with: newElements)
            }
        }
        return self
    }

    // 剪切板过滤非数字字符，并限制显示长度
    func filterAndLimitDigitsNum(_ limitDigitsNum: Int) -> String {
        // 若限制长度小于等于0
        if limitDigitsNum <= 0 {
            return self
        }

        // 过滤非数字字符，并限制显示长度
        let setToRemove = CharacterSet(charactersIn: "0123456789").inverted
        var newString = components(separatedBy: setToRemove).joined(separator: "")
        if newString.count > limitDigitsNum - 1 {
            newString = newString.subStringTo(limitDigitsNum)
        }
        return newString
    }

    /// 生成二维码
    func generateQRCode(size: CGSize, qrImageName: String? = nil) -> UIImage? {
        let stringData = data(using: String.Encoding.utf8, allowLossyConversion: false)

        // 创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter?.outputImage

        // 创建一个颜色滤镜,黑白色
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")

        // 返回二维码image
        let outImage = colorFilter.outputImage
        let scale = size.width / outImage!.extent.size.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let codeImage = UIImage(ciImage: colorFilter.outputImage!.transformed(by: transform))

        // 中间一般放logo
        if qrImageName != nil, let iconImage = UIImage(named: qrImageName!) {
            let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)

            UIGraphicsBeginImageContext(rect.size)
            codeImage.draw(in: rect)
            let avatarSize = CGSize(width: rect.size.width * 0.25, height: rect.size.height * 0.25)

            let x = (rect.width - avatarSize.width) * 0.5
            let y = (rect.height - avatarSize.height) * 0.5
            iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            return resultImage
        }
        return codeImage
    }

    // 过滤表情符号
    var removeHeadAndTailSpace: String {
        let whitespace = NSCharacterSet.whitespaces
        return trimmingCharacters(in: whitespace)
    }

    /// 返回字数
    var count: Int {
        var cnt: Int = 0
        let range = startIndex ..< endIndex
        enumerateSubstrings(in: range, options: NSString.EnumerationOptions.byComposedCharacterSequences) { (_, _, _, _) -> Void in
            cnt += 1
        }
        return cnt
    }

    /// 使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, count),
                                              withTemplate: with)
    }

    // 获取当前时间
    static func currentTimeStr() -> String {
        let now = Date()
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dformatter.string(from: now)
    }

    // 获取今天
    static func todayStr() -> String {
        let now = Date()
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        return dformatter.string(from: now)
    }

    // 获取昨天
    static func yesterStr() -> String {
        let now = Date()
        let yesterDay = Date(timeInterval: -24 * 60 * 60, since: now)
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd"
        return dformatter.string(from: yesterDay)
    }

    //
    static func currentYMDStr() -> String {
        let now = Date()
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy/MM/dd"
        return dformatter.string(from: now)
    }

    /// 获取当前设备IP
    static func getOperatorsIP() -> String? {
        var addresses = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first ?? "0.0.0.0"
    }

    // 获取本机无线局域网ip
    static func getWifiIP() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }

        freeifaddrs(ifaddr)
        return address ?? "0.0.0.0"
    }

    // 判断字符串是否全部都是空格
    static func isEmpty(str: NSString) -> Bool {
        if str == " " {
            return true
        } else {
            let set = NSCharacterSet.whitespacesAndNewlines
            let trimedString = str.trimmingCharacters(in: set)
            if trimedString.count == 0 {
                return true
            } else {
                return false
            }
        }
    }
}
