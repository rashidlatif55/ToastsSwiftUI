//
//  Toast.swift
//  ToastsSwiftUI
//
//  Created by Rashid Latif on 27/08/2024.
//

import SwiftUI

struct RootView<Content:View>: View {
    
    @ViewBuilder var content:Content
    @State private var overlayWindow: UIWindow?
    
    var body: some View {
        content
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, overlayWindow == nil {
                    let window = PasstroughWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    
                    let rootController = UIHostingController(rootView: ToastGroup())
                    rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
                    rootController.view.backgroundColor = .clear
                    window.rootViewController = rootController
                    
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.tag = 1009
                    
                    overlayWindow = window
                }
            }
    }
}

fileprivate class PasstroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {return nil}
        
        return rootViewController?.view == view ? nil : view
    }
}

@Observable
class Toast {
    static let shared = Toast()
    fileprivate var toasts =  [ToastItem]()
    
    func showToast(title:String, icon: String?, tintColor:Color = .primary, isUserInteractionEnabled:Bool = true, time:ToastTime = .medium, direction:ToastDirection = .top){
        withAnimation(.snappy) {
            toasts.append(.init(title: title, icon: icon, tintColor: tintColor, isUserInteractionEnabled: isUserInteractionEnabled, time: time, direction: direction))
        }
    }
}

struct ToastItem: Identifiable {
    let id = UUID()
    var title:String
    var icon:String?
    var tintColor:Color
    var isUserInteractionEnabled:Bool = true
    var time:ToastTime = .medium
    var direction: ToastDirection = .top
    
}

enum ToastTime:Double {
    case short = 1.0
    case medium = 2.0
    case long = 3.5
}

enum ToastDirection:String {
    case top = "⬇️"
    case bottom = "⬆️"
}

fileprivate struct ToastGroup : View {
    var dataModel = Toast.shared
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeSize = $0.safeAreaInsets
            
            ZStack {
                ForEach(dataModel.toasts) { toast in
                    ToastView(size: size, item: toast)
                        .offset(y: offsetY(toast))
                        .scaleEffect(scale(toast))
                        .zIndex(
                            Double(
                                dataModel.toasts.firstIndex(where: {
                                    $0.id == toast.id
                                }) ?? 0
                            )
                        )
                        .padding(.top, safeSize.top == .zero ? 15 : 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: toast.direction == .top ? .top : .bottom)
                }
            }
        }
    }
    
    func offsetY(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(dataModel.toasts.firstIndex(where: {
            $0.id == item.id
        }) ?? 0)
        let totalCount = CGFloat(dataModel.toasts.count) - 1
        
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
    }
    
    func scale(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(dataModel.toasts.firstIndex(where: {
            $0.id == item.id
        }) ?? 0)
        let totalCount = CGFloat(dataModel.toasts.count) - 1
        
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
    }
}

fileprivate struct ToastView:View {
    var size:CGSize
    var item:ToastItem
    @State private var delayTask:DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 0){
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.title3)
                    .padding(.trailing, 10)
            }
            
            Text(item.title)
                .lineLimit(1)
        }
        .foregroundStyle(item.tintColor)
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            .background
                .shadow(.drop(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5))
                .shadow(.drop(color: .primary.opacity(0.06), radius: 5, x: -5, y: -5)),
            in: .capsule
        )
        .containerShape(.capsule)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded({ value in
                    guard item.isUserInteractionEnabled else {return}
                    let endY = value.translation.height
                    let velocityY = value.velocity.height

                    if item.direction == .bottom {
                        if (endY + velocityY) > 100 {
                            removeToast()
                        }
                    }else {
                        if (endY + velocityY) < -100 {
                            removeToast()
                        }
                    }
                })
            
        )
        
        .onAppear {
            guard delayTask == nil else {return}
            delayTask = .init(block: {
                removeToast()
            })
            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + item.time.rawValue, execute: delayTask)
            }
        }
        .frame(maxWidth: size.width * 0.7)
        .transition(.offset(y: item.direction == .top ? -150 : 150))
    }
    
    func removeToast(){
        if let delayTask {
            delayTask.cancel()
        }
        withAnimation(.snappy) {
            Toast.shared.toasts.removeAll(where: {
                $0.id == item.id
            })
        }
        
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
