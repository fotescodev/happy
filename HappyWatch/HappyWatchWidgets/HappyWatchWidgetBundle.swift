import SwiftUI
import WidgetKit

@main
struct HappyWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        CircularComplication()
        RectangularComplication()
        CornerComplication()
        InlineComplication()
    }
}
