# StringStyles

```swift
let string = """
    <b>MacBook Pro</b>. Power, Moves. <a href='https://apple.com'>Learn more.</a>
"""

let style = FormattedStringStyle(attributes: [
    "body": [
        .font: UIFont.systemFont(ofSize: 16),
        .foregroundColor: UIColor.darkGray
    ],
    "b": [
        .font: UIFont.boldSystemFont(ofSize: 16),
    ],
])

let attr = NSAttributedString(formatting: string, style: style)

let label = UITextView()
label.attributedText = attr
```

![alt text](https://i.imgur.com/xNOdnld.png "image")

<sup>thx for @kean<sup>
