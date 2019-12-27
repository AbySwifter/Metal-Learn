//
//  ContentView.swift
//  MetalCodeSwift
//
//  Created by aby.wang on 2019/11/20.
//  Copyright © 2019 aby.wang. All rights reserved.
//

import SwiftUI
import MetalKit

struct ContentView: View {
    var body: some View {
        ZStack {
            MentalView().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            Text("Hello, World!")
        }
    }
}

struct MentalView: UIViewRepresentable {
    let view: MTKView = {
        let view = MTKView.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        let render = AbyRender.init(mtkView: view)
        view.delegate = render
        return view
    }()

    
    func makeUIView(context: UIViewRepresentableContext<MentalView>) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MentalView>) {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
