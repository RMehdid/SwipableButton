// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct SwipableButton: View {
    @Environment(\.isEnabled) private var isEnabled
    
    private let title: String
    private let action: () async -> Void
    
    private let style: Style
    
    @GestureState private var offset: CGFloat
    @State private var swipeState: SwipeState = .start
    
    public init(_ title: String, style: Style = .default, action: @escaping () async -> Void) {
        self.title = title
        self.action = action
        self.style = style
        
        self._offset = .init(initialValue: style.indicatorSpacing)
    }
    
    public var body: some View {
        GeometryReader { reading in
            let calculatedOffset: CGFloat = swipeState == .swiping ? offset : (swipeState == .start ? style.indicatorSpacing : (reading.size.width - style.indicatorSize + style.indicatorSpacing))
            ZStack(alignment: .leading) {
                style.backgroundColor
                    .saturation(isEnabled ? 1 : 0)
                
                ZStack {
                    if style.textAlignment == .center {
                        Text(title)
                            .multilineTextAlignment(style.textAlignment.textAlignment)
                            .foregroundColor(style.textColor)
                            .frame(maxWidth: max(0, reading.size.width - 2 * style.indicatorSpacing), alignment: .center)
                            .padding(.horizontal, style.indicatorSize)
                            .shimmerEffect(isEnabled && style.textShimmers)
                    } else {
                        Text(title)
                            .multilineTextAlignment(style.textAlignment.textAlignment)
                            .foregroundColor(style.textColor)
                            .frame(maxWidth: max(0, reading.size.width - 2 * style.indicatorSpacing), alignment: Alignment(horizontal: style.textAlignment.horizontalAlignment, vertical: .center))
                            .padding(.trailing, style.indicatorSpacing)
                            .padding(.leading, style.indicatorSize)
                            .shimmerEffect(isEnabled && style.textShimmers)
                    }
                }
                .opacity(style.textFadesOpacity ? (1 - progress(from: style.indicatorSpacing, to: reading.size.width - style.indicatorSize + style.indicatorSpacing, current: calculatedOffset)) : 1)
                .animation(.interactiveSpring(), value: calculatedOffset)
                .mask {
                    if style.textHiddenBehindIndicator {
                        Rectangle()
                            .overlay(alignment: .leading) {
                                Color.red
                                    .frame(width: calculatedOffset + (0.5 * style.indicatorSize - style.indicatorSpacing))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .animation(.interactiveSpring(), value: swipeState)
                                    .blendMode(.destinationOut)
                            }
                    } else {
                        Rectangle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Circle()
                    .frame(width: style.indicatorSize - 2 * style.indicatorSpacing, height: style.indicatorSize - 2 * style.indicatorSpacing)
                    .foregroundColor(isEnabled ? style.indicatorColor : .gray)
                    .overlay(content: {
                        ZStack {
                            // Replace `.circular` with `.linear`
                            ProgressView().progressViewStyle(.linear)
                                .foregroundColor(.white)
                                .opacity(swipeState == .end ? 1 : 0)
                            Image(systemName: isEnabled ? style.indicatorSystemName : style.indicatorDisabledSystemName)
                                .foregroundColor(.white)
                                .font(.system(size: max(0.4 * style.indicatorSize, 0.5 * style.indicatorSize - 2 * style.indicatorSpacing), weight: .semibold))
                                .opacity(swipeState == .end ? 0 : 1)
                        }
                    })
                    .offset(x: calculatedOffset)
                    .animation(.interactiveSpring(), value: swipeState)
                    .gesture(
                        DragGesture()
                            .updating($offset) { value, state, transaction in
                                guard swipeState != .end else { return }
                                
                                if swipeState == .start {
                                    DispatchQueue.main.async {
                                        swipeState = .swiping
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .light).prepare()
                                        #endif
                                    }
                                }
                                state = clampValue(value: value.translation.width, min: style.indicatorSpacing, max: reading.size.width - style.indicatorSize + style.indicatorSpacing)
                            }
                            .onEnded { value in
                                guard swipeState == .swiping else { return }
                                swipeState = .end
                                
                                if value.predictedEndTranslation.width > reading.size.width
                                    || value.translation.width > reading.size.width - style.indicatorSize - 2 * style.indicatorSpacing {
                                    Task {
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        #endif
                                        
                                        await action()
                                        
                                        swipeState = .start
                                    }
                                } else {
                                    swipeState = .start
                                    #if os(iOS)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    #endif
                                }
                            }
                    )
            }
            .mask { Capsule() }
        }
        .frame(height: style.indicatorSize)
    }
    
    private func clampValue(value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        return max(minValue, min(maxValue, value))
    }
    
    private func progress(from start: Double, to end: Double, current: Double) -> Double {
        let clampedCurrent = max(min(current, end), start)
        return (clampedCurrent - start) / (end - start)
    }
    
    private enum SwipeState {
        case start, swiping, end
    }
}

#if DEBUG
@available(iOS 16.0, *)
@available(macOS 16.0, *)
struct SwipableButton_Previews: PreviewProvider {
    struct ContentView: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    HStack{
                        SwipableButton("Button text here", action: buttonAction)
                        SwipableButton("Swipe to delete", style: .init(indicatorColor: .red, indicatorSystemName: "trash", textAlignment: .center, textShimmers: true), action: buttonAction)
                    }
                    HStack{
                        SwipableButton("Spacing 15", style: .init(indicatorSpacing: 15), action: buttonAction)
                        SwipableButton("Big", style: .init(indicatorSize: 100), action: buttonAction)
                    }
                    HStack{
                        SwipableButton("Disabled green", style: .init(indicatorColor: .green), action: buttonAction)
                            .disabled(true)
                        SwipableButton("Disabled", action: buttonAction)
                            .disabled(true)
                    }
                }.padding(.horizontal)
            }
        }
        
        private func buttonAction() async {
            try? await Task.sleep(for: .seconds(2))
        }
    }

    static var previews: some View {
        ContentView()
            .padding()
    }
}
#endif
