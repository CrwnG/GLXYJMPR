import SwiftUI

/// Un botón que detecta cuando se mantiene presionado (onPressDown) y cuando se suelta (onPressUp).
struct PressableButton<Label: View>: View {
    let onPressDown: () -> Void
    let onPressUp: () -> Void
    let label: () -> Label
    
    @GestureState private var isPressed = false
    
    var body: some View {
        label()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        if !state {
                            state = true
                            onPressDown()
                        }
                    }
                    .onEnded { _ in
                        onPressUp()
                    }
            )
    }
}
