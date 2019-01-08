//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

func MakeDate(Year: Int, Month: Int, Day: Int, Hour: Int, Minute: Int) -> Date
{
    var Components = DateComponents()
    Components.year = Year
    Components.month = Month
    Components.day = Day
    Components.hour = Hour
    Components.minute = Minute
    Components.timeZone = TimeZone.current
    let Cal = Calendar.current
    return Cal.date(from: Components)!
}

func ToString(_ Now: Date) -> String
{
    let Formatter = DateFormatter()
    Formatter.timeStyle = .medium
    Formatter.dateStyle = .medium
    Formatter.timeZone = TimeZone.current
    return Formatter.string(from: Now)
}

func TimeWithOffset(Start: Date, Duration: Int) -> Date
{
    let Cal = Calendar.current
    let NewDate: Date = Cal.date(byAdding: .second, value: Duration, to: Start)!
    return NewDate
}

func DurationBetween(Start: Date, End: Date) -> Int
{
    let Cal = Calendar.current
    let Components = Cal.dateComponents([.second], from: Start, to: End)
    return abs(Components.second!)
}

func InRange(Start: Date, Duration: Int, Now: Date) -> Bool
{
    let Ending = TimeWithOffset(Start: Start, Duration: Duration)
    print("Range is: \(ToString(Start)) to \(ToString(Ending)), Target is: \(ToString(Now))")
    return (Start ... Ending).contains(Now)
}

func SimpleStringToDate(_ Raw: String, PopulateDate: Bool = true) -> Date
{
    let Formatter = DateFormatter()
    if PopulateDate
    {
        Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    }
    else
    {
        Formatter.dateFormat = "HH:mm"
    }
    Formatter.timeZone = TimeZone.current
    let Final = Formatter.date(from: Raw)
    return Final!
}

let First = MakeDate(Year: 2018, Month: 8, Day: 14, Hour: 18, Minute: 0)
let Second = MakeDate(Year: 2018, Month: 8, Day: 15, Hour: 6, Minute: 0)
let Seconds = DurationBetween(Start: First, End: Second)
print("Duration: \(Seconds) seconds")

let Test = MakeDate(Year: 2018, Month: 8, Day: 15, Hour: 5, Minute: 1)
if InRange(Start: First, Duration: Seconds, Now: Test)
{
    print("Is in range")
}
else
{
    print("Is not in range")
}


func CountSetBits(_ Number: UInt64) -> Int
{
    let Bits = MemoryLayout<UInt64>.size * 8
    var Count: Int = 0
    var Mask: UInt64 = 1
    for _ in 0 ... Bits
    {
        if Number & Mask != 0
        {
            Count = Count + 1
        }
        Mask <<= 1
    }
    return Count
}

let BigNum: UInt64 = 0xffffff
let BigNumSetBits = CountSetBits(BigNum)
let Chksum = BigNumSetBits % 31
print("Bignum(\(BigNum)) set bit count: \(BigNumSetBits), Checksum: \(Chksum)")

func StartOfNextDay() -> Date
{
    return Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
}

func TimeFromMidnight() -> Int
{
    let MSInDay = Double(24 * 60 * 60 * 1000)
    print("MSInDay = \(MSInDay)")
    let Interval = StartOfNextDay().timeIntervalSince(Date()) * 1000
    return Int((MSInDay) - Interval)
}

print("TimeFromMidnight: \(TimeFromMidnight())")

let testnumber = "100.100"
let testvalue = CGFloat(Double(testnumber)!)
print("Test number value: \(testvalue)")


print("Thin")
for x in 0 ... 15
{
    print("\(x): \(pow(2, x))")
}
print("Thick")
var Sum: Decimal = 0
for x in 0 ... 15
{
    let Val = pow(2, x) * 2
    Sum = Sum + Val
    print("\(x): \(Val)")
}
print("Sum=\(Sum)")


func Pharma(Value: Int) -> [Int]
{
    if Value < 3
    {
        return [Int]()
    }
    if Value > 131070
    {
        return [Int]()
    }
    
    var Final = [Int]()
    var Z = Value
    
    while Z > 0
    {
        if Z % 2 == 0
        {
            Final.append(2)
            Z = (Z - 2) / 2
        }
        else
        {
            Final.append(1)
            Z = (Z - 1) / 2
        }
    }
    return Final.reversed()
}

let Test1 = Pharma(Value: 100)
print(Test1)
let Test2 = Pharma(Value: 1000)
print(Test2)
let Test3 = Pharma(Value: 65535)
print(Test3)
let Test4 = Pharma(Value: 65536)
print(Test4)


let TestNum = 493875993.0
let z = TestNum.exponent
print("\(z)")
let y = log10(TestNum)
print("\(y)")

