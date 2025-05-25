import SwiftUI

struct DraggableInputCardView: View {
    @Binding var newTodoText: String
    var onSubmit: () -> Void
    @Binding var errorMessage: String?
    @Binding var todos: [TodoItem]

    @StateObject private var keyboardResponder = KeyboardResponder()

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var gestureOffset: CGFloat = 0
    @FocusState private var inputFieldIsFocused: Bool
    
    private let topSectionFixedSHeight: CGFloat = 100
    private let cardCornerRadius: CGFloat = 30

    private var shouldShowCalendarContent: Bool {
        // Only show calendar if explicitly pulled up and keyboard is not active.
        // If input is focused, we generally don't want the calendar.
        if inputFieldIsFocused {
            return false
        }
        return dragOffset < (geometrySizeHeight() - topSectionFixedSHeight) * 0.9
    }
    
    private func geometrySizeHeight() -> CGFloat {
        UIScreen.main.bounds.height
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // --- Fixed Top Section (Non-Scrolling) ---
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 30)
                        .padding(.bottom, 10)

                    HStack(alignment: .center, spacing: 8) {
                        TodoInputBarView(newTodoText: $newTodoText, onSubmit: onSubmit, isInputActive: $inputFieldIsFocused)
                    }
                    .padding(.horizontal)

                    if let message = errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(Color("TextColor"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.destructiveRed.opacity(0.9))
                            .clipShape(Capsule())
                            .transition(.scale(scale: 0.9, anchor: .top).animation(.spring(response: 0.3, dampingFraction: 0.6)))
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                    Spacer()
                }
                .frame(height: topSectionFixedSHeight)
                .background(Color.clear)

                // --- Scrollable Bottom Section (Calendar) ---
                if shouldShowCalendarContent {
                    ScrollView(showsIndicators: false) {
                        CalendarTodosView(todos: $todos)
                            .padding(.top, 35)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Spacer()
                }
            }
            .frame(width: geometry.size.width)
            .frame(maxHeight: .infinity)
            .background(
                ZStack {
                //    Color.clear
                      //  .background(.ultraThinMaterial)
                    Color("DraggableCard")
                }
            )
            .cornerRadius(cardCornerRadius, corners: [.topLeft, .topRight])
            .clipped()
            .offset(y: calculateOffset(geometry: geometry, keyboardHeight: keyboardResponder.currentHeight) + (isDragging ? gestureOffset : 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if inputFieldIsFocused {
                            inputFieldIsFocused = false // Dismiss keyboard immediately on drag
                        }
                        isDragging = true
                        gestureOffset = value.translation.height
                    }
                    .onEnded { value in
                        isDragging = false
                        gestureOffset = 0

                        if inputFieldIsFocused {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                self.dragOffset = geometry.size.height - topSectionFixedSHeight
                            }
                            return
                        }

                        let predictedEndOffset = value.predictedEndTranslation.height + dragOffset
                        if predictedEndOffset < (geometry.size.height - topSectionFixedSHeight) * 0.6 {
                            self.dragOffset = 0 // Snap Up
                        } else {
                            self.dragOffset = geometry.size.height - topSectionFixedSHeight // Snap Down
                        }
                    }
            )
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2), value: dragOffset)
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                self.dragOffset = geometry.size.height - topSectionFixedSHeight
            }
            .onChange(of: inputFieldIsFocused) { _, focused in
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                    if focused {
                        // When keyboard appears, set dragOffset to "collapsed" state to hide calendar.
                        // The actual visual positioning is handled by calculateOffset's keyboard logic.
                        self.dragOffset = geometry.size.height - topSectionFixedSHeight
                    } else {
                        // When keyboard dismisses, if card wasn't manually pulled up for calendar,
                        // ensure it returns to the "top section visible" state.
                        // If dragOffset is 0 (calendar was fully shown), leave it there.
                        // This logic remains, as shouldShowCalendarContent will become true if dragOffset is 0
                        if self.dragOffset != 0 { // If not fully expanded to show calendar
                           self.dragOffset = geometry.size.height - topSectionFixedSHeight
                        }
                    }
                }
            }
            .onChange(of: keyboardResponder.currentHeight) { _, newKeyboardHeight in
                 // This onChange is primarily to trigger a re-calculation of offset via calculateOffset
                 // if the keyboard height changes *while* the input field is already focused.
                 // The dragOffset itself, if input is focused, should remain to keep calendar hidden.
                if inputFieldIsFocused {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                        // Ensure dragOffset reflects "collapsed" state for calendar visibility
                        self.dragOffset = geometry.size.height - topSectionFixedSHeight
                        // The view will re-render and calculateOffset will use the newKeyboardHeight
                    }
                }
            }
        }
    }

    private func calculateOffset(geometry: GeometryProxy, keyboardHeight: CGFloat) -> CGFloat {
        let screenHeight = geometry.size.height
        let expandedHeight = geometry.size.height
        let minCardTopYWhenExpanded_Offset = screenHeight - expandedHeight
        let maxCardTopYWhenCollapsed_Offset = screenHeight - topSectionFixedSHeight

        if inputFieldIsFocused && keyboardHeight > 0 {
            // Calculate the desired top Y coordinate of the card in global space
            let desiredGlobalCardTopY = UIScreen.main.bounds.height - keyboardHeight - topSectionFixedSHeight - 20
            
            // Convert this global Y to an offset within our GeometryReader's coordinate space
            let geometryGlobalMinY = geometry.frame(in: .global).minY
            var keyboardAdjustedOffset = desiredGlobalCardTopY - geometryGlobalMinY
            
            // Ensure the card doesn't go higher than its fully expanded state
            keyboardAdjustedOffset = max(minCardTopYWhenExpanded_Offset, keyboardAdjustedOffset)
            return keyboardAdjustedOffset
        } else {
            // Original logic for when keyboard is not active or not visible
            let currentVisibleHeight = expandedHeight - dragOffset
            let newOffset = screenHeight - currentVisibleHeight
            return max(minCardTopYWhenExpanded_Offset, min(newOffset, maxCardTopYWhenCollapsed_Offset))
        }
    }
}
